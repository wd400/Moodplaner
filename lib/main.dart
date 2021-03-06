import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hive/hive.dart';
import "package:hive_flutter/hive_flutter.dart" ;
import 'package:moodplaner/utils/methods.dart';
import 'package:path_provider/path_provider.dart';


import 'constants/language.dart';
import 'core/collection.dart';
import 'core/configuration.dart';
import 'core/download.dart';
import 'core/fileintent.dart';
import 'core/mediatype.dart';
import 'core/synchronization.dart';
import 'interface/moodplaner.dart';
import 'login.dart';



const String TITLE   = 'moodPlaner';
const String VERSION = '0.1';
const String AUTHOR  = 'dev';
const String LICENSE = 'GPL-3.0';

class OffsetXvalues extends ChangeNotifier {
  int value;
  OffsetXvalues({required this.value});
  void update({required int value}) {
    this.value = value;
    this.notifyListeners();
  }
}

final offsetXvaluesProvider=ChangeNotifierProvider.autoDispose<OffsetXvalues>(
      (context) => OffsetXvalues(value: 20),
);



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

//  debugPrintHitTestResults = true;

 // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
 // try {


  final appDocumentDir = await getApplicationDocumentsDirectory();

  Hive.init(appDocumentDir.path);
  //TODO:gerer les deux cas
 // Hive.initFlutter();

  Hive.registerAdapter(TrackAdapter());
  Hive.registerAdapter(PlaylistAdapter());
  Hive.registerAdapter(GeneratorAdapter());

  final tracksBox = await Hive.openBox<Track>('tracks');
  final playlistsBox = await Hive.openBox<Playlist>('playlists');
  final generatorsBox = await Hive.openBox<Generator>('generators');
  if (! await storage.containsKey(key: 'token')) {
    storage.write(key: 'token', value: null);
  }

    await Methods.askStoragePermission();
    await Configuration.init();
    await Collection.init(
      collectionDirectory: configuration.collectionDirectory!,
      cacheDirectory: configuration.cacheDirectory!,
      collectionSortType: configuration.collectionSortType!,
    );

    await Language.init(
      languageRegion: configuration.languageRegion!,
    );
    await FileIntent.init();
    await Download.init();

  Timer.periodic(Duration(seconds: 60), (timer) async {
    await syncAll();



  });



    runApp(
        ProviderScope(child:  Moodplaner())
    );
//  }
//  catch(exception) {
//    runApp(
//      new ExceptionMaterialApp(
//        exception: exception,
//      ),
//    );
//  }
}

final snackBar = SnackBar(content: Text('Yay! A SnackBar!'));

// Find the ScaffoldMessenger in the widget tree
// and use it to show a SnackBar.


