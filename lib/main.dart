import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import 'package:hive/hive.dart';
import 'package:moodplaner/utils/methods.dart';
import 'package:path_provider/path_provider.dart';

import 'constants/language.dart';
import 'core/collection.dart';
import 'core/configuration.dart';
import 'core/download.dart';
import 'core/fileintent.dart';
import 'core/mediatype.dart';
import 'interface/harmonoid.dart';



const String TITLE   = 'moodPlaner';
const String VERSION = '0.0.8';
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

 // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.top]);

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
 // try {


  final appDocumentDir = await getApplicationDocumentsDirectory();
  print(appDocumentDir.path);
  Hive.init(appDocumentDir.path);

  Hive.registerAdapter(TrackAdapter());
  Hive.registerAdapter(PlaylistAdapter());
  Hive.registerAdapter(GeneratorAdapter());

  final tracksBox = await Hive.openBox<Track>('tracks');
  final playlistsBox = await Hive.openBox<Playlist>('playlists');
  final generatorsBox = await Hive.openBox<Generator>('generators');


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
