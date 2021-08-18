import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:moodplaner/constants/language.dart';
import 'package:moodplaner/core/mediatype.dart';
import 'package:moodplaner/interface/settings/settings.dart';

import '../../login.dart';


class AccountSetting extends StatefulWidget {
  @override
  _AccountSettingState createState() => _AccountSettingState();
}

final AccountDeletedsnackBar = SnackBar(content: Text('Your account has been successfully deleted'));

final ErrorsnackBar = SnackBar(content: Text('Error, please try again later'));

final NotLoggedsnackBar = SnackBar(content: Text('You are not logged'));
// Find the ScaffoldMessenger in the widget tree
// and use it to show a SnackBar.


class _AccountSettingState extends State<AccountSetting> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: storage.read(key: "token"),
        builder: (context, AsyncSnapshot<String?> snapshot) {
    //      if(!snapshot.hasData) return CircularProgressIndicator();
          String? token=snapshot.data;



          return  SettingsTile(
    title: language!.STRING_SETTING_ACCOUNT_TITLE,
    subtitle:(token!=null) ? Hive.box('configuration').get('mail'):'',

    child: Column(children: [ListTile(
    title: Text(token==null?'Log in':'Log out'),
    onTap: () async {
    if (token!=null) {
    storage.write(key: "token", value: null);

    await Hive.box<Track>('tracks').clear();
    await Hive.box<Playlist>('playlists').clear();
    await Hive.box<Generator>('generators').clear();

    //logout

    } else {
    //login

    Navigator.of(context).push(
    MaterialPageRoute(
    //GeneratorDrawerWidget
    builder: (
    BuildContext context) {
    return LoginPage();
    }
    ),
    );
    setState(() {

    });


    }
    setState(() {

    });

    }),

          ListTile(
          title: Text('Delete account'),
          onTap: (){
            if (token==null || token=='') {

              ScaffoldMessenger.of(context).showSnackBar(NotLoggedsnackBar);

              return;
            }
          Navigator.of(context).push(
          MaterialPageRoute(
          //GeneratorDrawerWidget
          builder: (
          BuildContext context) {
          return   AlertDialog(
            title: Text('Are you sure?'),
            content: Text("All your data stored in the cloud will be permanently deleted"),
            actions: <Widget>[
              TextButton(
                child: Text("YES"),
                onPressed: () async {
                  //Put your code here which you want to execute on Yes button click.
                  var res = await get( Uri.parse( '$SERVER_IP/delete'),  headers: {"token": (await storage.read(key: "token"))??''});
                  if (res.statusCode==200){

                    storage.write(key: "token", value: null);

                    ScaffoldMessenger.of(context).showSnackBar(AccountDeletedsnackBar);

                  }
                  ScaffoldMessenger.of(context).showSnackBar(ErrorsnackBar);
                  Navigator.of(context).pop();
                },
              ),

              TextButton(
                child: Text("NO"),
                onPressed: () {
                  //Put your code here which you want to execute on No button click.
                  Navigator.of(context).pop();
                },
              )
            ],
          );

          }
          ),
          );

          }, ),

          ]));
        });}}



