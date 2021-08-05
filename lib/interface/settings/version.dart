import 'dart:convert' as convert;
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:moodplaner/constants/language.dart';
import 'package:moodplaner/interface/settings/settings.dart';
import 'package:url_launcher/url_launcher.dart';


import '../../main.dart';





class VersionSetting extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      title: language!.STRING_SETTING_APP_VERSION_TITLE,
      subtitle: language!.STRING_SETTING_APP_VERSION_SUBTITLE,
      child: Text(language!.STRING_SETTING_APP_VERSION_INSTALLED+ ' v ' + VERSION),



    );
  }
}