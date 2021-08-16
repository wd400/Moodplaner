import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'interface/home.dart';

const SERVER_IP = 'http://10.0.2.2:5000';
final storage = FlutterSecureStorage();

void main() {
  runApp(CheckLogin());
}

class CheckLogin extends StatelessWidget {
  Future<String> get tokenOrEmpty async {
    var token = await storage.read(key: "token");
    if(token == null) return "";
    return token;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Authentication Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
          future: tokenOrEmpty,
          builder: (context, snapshot) {
            if(!snapshot.hasData) return CircularProgressIndicator();
            if(snapshot.data != "") {
                  return HomePage();
            } else {
              return LoginPage();
            }
          }
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController _mailController = TextEditingController(text:Hive.box('configuration').get('mail'));
  final TextEditingController _passwordController = TextEditingController();

  void displayDialog(context, title, text) => showDialog(
    context: context,
    builder: (context) =>
        AlertDialog(
            title: Text(title),
            content: Text(text)
        ),
  );

  Future<String?> attemptLogIn(String mail, String password) async {
    var res = await http.post(
      Uri.parse("$SERVER_IP/login"),
        body: {
          "mail": mail,
          "password": password
        }
    );
    if(res.statusCode == 200) {
      Hive.box('configuration').put("mail",mail);

      return res.body;
    }
      return null;
    }


  Future<int> attemptSignUp(String mail, String password) async {
    var res = await http.post(
     Uri.parse( '$SERVER_IP/signup'),
        body: {
          "mail": mail,
          "password": password
        }
    );
    return res.statusCode;

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Log In"),),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              TextField(

                controller: _mailController,
                decoration: InputDecoration(
                    labelText: 'Mail'
                ),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                    labelText: 'Password'
                ),
              ),
              TextButton(
                  onPressed: () async {
                    var mail = _mailController.text;
                    var password = _passwordController.text;
                    var token = await attemptLogIn(mail, password);
                    if(token != null) {
                      storage.write(key: "token", value: token);
                      await context.read(collectionProvider).refresh();
                      Navigator.pop(context);

                    } else {
                      displayDialog(context, "An Error Occurred", "No account was found matching that mail and password");
                    }
                  },
                  child: Text("Log In")
              ),
              TextButton(
                  onPressed: () async {
                    var mail = _mailController.text;
                    var password = _passwordController.text;

                    if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+$").hasMatch(mail))
                      displayDialog(context, "Invalid mail", "This is not a valid email format");
                    else if(password.length < 4)
                      displayDialog(context, "Invalid Password", "The password should be at least 4 characters long");
                    else if (!RegExp(r"(?=.*[a-z])(?=.*[A-Z])(?=.*[0-9])(?=.*[^A-Za-z0-9])(?=.{8,})").hasMatch(password))
                      displayDialog(context, "Invalid password", "Choose a stronger password");
                    else{
                      var res = await attemptSignUp(mail, password);
                      if(res == 201)
                        displayDialog(context, "Success", "The user was created. Log in now.");
                      else if(res == 409)
                        displayDialog(context, "That mail is already registered", "Please try to sign up using another mail or log in if you already have an account.");
                      else if(res == 408)
                        displayDialog(context, "Invalid mail", "This is not a valid email format");
                      else if(res == 407)
                        displayDialog(context,  "Invalid password", "Choose a stronger password");
                      else {
                        displayDialog(context, "Error", "An unknown error occurred.");
                      }
                    }
                  },
                  child: Text("Sign Up")
              )
            ],
          ),
        )
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Scaffold(
        appBar: AppBar(title: Text("Secret Data Screen")),
        body: Center(
          child: FutureBuilder(
              future: http.read(Uri.parse('$SERVER_IP/ping')),
              builder: (context, AsyncSnapshot<String> snapshot) =>
              snapshot.hasData ?
              Column(children: <Widget>[
                Text(snapshot.data.toString(), style: Theme.of(context).textTheme.headline4)
              ],)
                  :
              snapshot.hasError ? Text("An error occurred") : CircularProgressIndicator()
          ),
        ),
      );
}