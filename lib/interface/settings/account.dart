import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
    title: Text(token==null?language!.STRING_LOG_IN:language!.STRING_LOG_OUT),
    onTap: () async {
    if (token!=null) {
    storage.write(key: "token", value: null);

    await Hive.box<Track>('tracks').clear();
    await Hive.box<Playlist>('playlists').clear();
    await Hive.box<Generator>('generators').clear();
    Hive.box('configuration').put('lastGeneratorSync',null);
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
          title: Text(language!.STRING_DELETE_ACCOUNT),
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
            title: Text(language!.DELETE_ACCOUNT_HEADER),

            content: Text( language!.DELETE_ACCOUNT_WARNING),
            actions: <Widget>[
              TextButton(
                child: Text( language!.STRING_YES),
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
                child: Text( language!.STRING_NO),
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



