import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
//import 'package:provider/provider.dart';
import 'package:moodplaner/constants/language.dart';
import 'package:moodplaner/interface/settings/settings.dart';

import '../../login.dart';
import '../harmonoid.dart';


class AccountSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: storage.read(key: "token"),
        builder: (context, AsyncSnapshot<String?> snapshot) {
          if(!snapshot.hasData) return CircularProgressIndicator();
          String token=snapshot.data!;
          print("TOKEN");
          print(token);
          return  SettingsTile(
    title: language!.STRING_SETTING_ACCOUNT_TITLE,
    subtitle:(token=='') ? Hive.box('configuration').get('mail'):'',

    child: ListTile(
    title: Text(token==''?'Log in':'Log out'),
    onTap: () {
    print("ontap");
    if (token!='') {
    print("tokened");
    storage.write(key: "token", value: '');
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

    }

    }));});}}



