import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:provider/provider.dart';
import 'package:moodplaner/constants/language.dart';
import 'package:moodplaner/interface/settings/settings.dart';

import '../moodplaner.dart';


class ThemeSetting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      title: language!.STRING_SETTING_THEME_TITLE,
      subtitle: language!.STRING_SETTING_THEME_SUBTITLE,
      child: Consumer(
        builder: (context, ScopedReader watch, _) {
          var visuals = watch(visualProvider);
          return Column(
            children: [
              RadioListTile(
                value: ThemeMode.system,
                title: Text(language!.STRING_THEME_MODE_SYSTEM),
                groupValue: visuals.themeMode,
                onChanged: (dynamic themeMode) =>
                    visuals.update(
                      themeMode: themeMode,
                    ),
              ),
              RadioListTile(
                value: ThemeMode.light,
                title: Text(language!.STRING_THEME_MODE_LIGHT),
                groupValue: visuals.themeMode,
                onChanged: (dynamic themeMode) =>
                    visuals.update(
                      themeMode: themeMode,
                    ),
              ),
              RadioListTile(
                value: ThemeMode.dark,
                title: Text(language!.STRING_THEME_MODE_DARK),
                groupValue: visuals.themeMode,
                onChanged: (dynamic themeMode) =>
                    visuals.update(
                      themeMode: themeMode,
                    ),
              ),
            ],
          );

        }
      )
    );
  }
}
