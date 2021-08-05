import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:moodplaner/constants/language.dart';
import 'package:moodplaner/interface/collection/blacklisttracks.dart';
import 'package:moodplaner/interface/settings/settings.dart';
//import 'package:provider/provider.dart';

import '../../login.dart';
import '../harmonoid.dart';


class MiscellaneousSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return SettingsTile(
      title: language!.STRING_SETTING_MISCELLANEOUS_TITLE,
      subtitle: language!.STRING_SETTING_MISCELLANEOUS_SUBTITLE,
      child: Column(
        children: [
          Consumer(

            builder: (context, ScopedReader watch, _) {
              var visuals = watch(visualProvider);
              return SwitchListTile(
                title: Text(
                    language!.STRING_SETTING_MISCELLANEOUS_ENABLE_IOS_TITLE),
                subtitle:
                Text(
                    language!.STRING_SETTING_MISCELLANEOUS_ENABLE_IOS_SUBTITLE),
                value: visuals.platform == TargetPlatform.iOS,
                onChanged: (bool isiOS) =>
                    visuals.update(
                      platform: isiOS ? TargetPlatform.iOS : TargetPlatform
                          .android,
                    ),
              );
            }
          ),
    ListTile(
    title: Text('Access blacklist'),
    subtitle: Text('All unsynchronized songs of the device'),
    onTap: (){

    Navigator.of(context).push(
    MaterialPageRoute(
    //GeneratorDrawerWidget
    builder: (
    BuildContext context) {
    return   BlacklistTracks();

    }
    ),
    );

    }, ),



    ],
      ),
      margin: EdgeInsets.only(bottom: 8.0),
    );
  }
}
