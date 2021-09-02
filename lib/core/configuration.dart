import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:moodplaner/constants/language.dart';
import 'package:moodplaner/interface/changenotifiers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'collection.dart';


late Configuration configuration;


abstract class ConfigurationKeys {
  Directory? collectionDirectory;
  Directory? cacheDirectory;
  String? homeAddress;
  LanguageRegion? languageRegion;
  Accent? accent;
  ThemeMode? themeMode;
  CollectionSort? collectionSortType;
  bool? automaticAccent;
  TargetPlatform? platform;
  List<dynamic>? collectionSearchRecent;
  List<dynamic>? discoverSearchRecent;
  List<dynamic>? discoverRecent;
  String? mail;
}



 Map<String, dynamic> DEFAULT_CONFIGURATION = {
  'collectionDirectory': getApplicationDocumentsDirectory(),
  'homeAddress': '',
  'languageRegion': 0,
  'accent': 0,
  'themeMode': 0,
  'collectionSortType': 0,
  'automaticAccent': false,
  'platform': 2,
  'collectionSearchRecent': [],
  'discoverSearchRecent': [],
  'discoverRecent': [],
  'mail':'',
};


class Configuration extends ConfigurationKeys {

  late File configurationFile;

  static Future<void> init() async {
    configuration = new Configuration();

    await Hive.openBox('configuration');
    /*
    configuration.configurationFile = File(
      path.join(
        (await path.getExternalStorageDirectory())!.path,
        'configuration.JSON',
      ),
    );
    if (!await configuration.configurationFile.exists()) {
      await configuration.configurationFile.create(recursive: true);
      await configuration.configurationFile.writeAsString(convert.jsonEncode(DEFAULT_CONFIGURATION));
    }
      */
    await configuration.read();

    configuration.cacheDirectory = new Directory('/storage/emulated/0/Android/data/com.alexmercerind.harmonoid/files');
  }

  Future<void> save({
    Directory? collectionDirectory,
    String? homeAddress,
    LanguageRegion? languageRegion,
    Accent? accent,
    ThemeMode? themeMode,
    bool? showOutOfBoxExperience,
    CollectionSort? collectionSortType,
    bool? automaticAccent,
    TargetPlatform? platform,
    List<dynamic>? collectionSearchRecent,
    List<dynamic>? discoverSearchRecent,
    List<dynamic>? discoverRecent,
    String? mail,
    }) async {
    if (collectionDirectory != null) {
      this.collectionDirectory = collectionDirectory;
    }
    if (homeAddress != null) {
      this.homeAddress = homeAddress;
    }
    if (languageRegion != null) {
      this.languageRegion = languageRegion;
    }
    if (themeMode != null) {
      this.themeMode = themeMode;
    }
    if (accent != null) {
      this.accent = accent;
    }
    if (collectionSortType != null) {
      this.collectionSortType = collectionSortType;
    }
    if (collectionSearchRecent != null) {
      this.collectionSearchRecent = collectionSearchRecent;
    }
    if (discoverSearchRecent != null) {
      this.discoverSearchRecent = discoverSearchRecent;
    }
    if (collectionSearchRecent != null) {
      this.discoverRecent = discoverRecent;
    }
    if (automaticAccent != null) {
      this.automaticAccent = automaticAccent;
    }

    if (mail != null) {
      this.mail = mail;
    }

    if (platform != null) {
      this.platform = platform;
    }
    Box<dynamic> currentConfiguration=Hive.box('configuration');

      currentConfiguration.put(  'collectionDirectory', this.collectionDirectory!.path);
    currentConfiguration.put(  'homeAddress', this.homeAddress);
    currentConfiguration.put('languageRegion', this.languageRegion!.index);
      currentConfiguration.put( 'accent', accents.indexOf(this.accent));
    currentConfiguration.put(  'themeMode', this.themeMode!.index);
    currentConfiguration.put(  'collectionSortType', this.collectionSortType!.index);
    currentConfiguration.put(   'automaticAccent', this.automaticAccent);
    currentConfiguration.put(   'platform', this.platform!.index);
    currentConfiguration.put(   'collectionSearchRecent', this.collectionSearchRecent);
    currentConfiguration.put(   'discoverSearchRecent', this.discoverSearchRecent);
    currentConfiguration.put(   'discoverRecent', this.discoverRecent);
    currentConfiguration.put(   'mail', this.mail);
  }

  Future<dynamic> read() async {
    /*
    Map<String, dynamic> currentConfiguration = convert.jsonDecode(await this.configurationFile.readAsString());


    });

     */
    Box<dynamic> currentConfiguration=Hive.box('configuration');


    DEFAULT_CONFIGURATION.keys.forEach((String key) {
      if (!currentConfiguration.containsKey(key)) {
        currentConfiguration.put(key, DEFAULT_CONFIGURATION[key]);
      }
    });


    this.collectionDirectory = Directory(currentConfiguration.get('collectionDirectory'));
    this.homeAddress = currentConfiguration.get('homeAddress');
    this.languageRegion = LanguageRegion.values[currentConfiguration.get('languageRegion')];
    this.accent = accents[currentConfiguration.get('accent')];
    this.themeMode = ThemeMode.values[currentConfiguration.get('themeMode')];
    this.collectionSortType = CollectionSort.values[currentConfiguration.get('collectionSortType')];
    this.automaticAccent = currentConfiguration.get('automaticAccent');
    this.platform = TargetPlatform.values[currentConfiguration.get('platform')];
    this.collectionSearchRecent = currentConfiguration.get('collectionSearchRecent');
    this.discoverSearchRecent = currentConfiguration.get('discoverSearchRecent');
    this.discoverRecent = currentConfiguration.get('discoverRecent');
    this.mail = currentConfiguration.get('mail');
  }

}
