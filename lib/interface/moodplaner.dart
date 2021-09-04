import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moodplaner/constants/language.dart';
//import 'package:provider/provider.dart';

import 'package:moodplaner/core/configuration.dart';
import 'package:moodplaner/core/synchronization.dart';

import 'changenotifiers.dart';
import 'home.dart';

final visualProvider=ChangeNotifierProvider<Visuals>(
 (context) => Visuals(
accent: configuration.accent,
themeMode: configuration.themeMode,
platform: configuration.platform,
));

final homeAddressProvider=ChangeNotifierProvider<Server>(
  (context) => Server(homeAddress: configuration.homeAddress),
);

final newVersionSnackBar = SnackBar(content: Text(language!.NEW_VERSION_AVAILABLE));


class Moodplaner extends StatelessWidget {



  @override
  Widget build(BuildContext context) {
    return Consumer(
        builder: (context, ScopedReader watch, _) {
          var visuals = watch(visualProvider);

          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: visuals.theme,
            darkTheme: visuals.darkTheme,
            themeMode: visuals.themeMode,
            home:  Home(),


          );
        }
    );
  }
}

