import 'package:assets_audio_player/assets_audio_player.dart' as AudioPlayer;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:path/path.dart';

import '../login.dart';
import 'download.dart';
import 'mediatype.dart';


final AudioPlayer.AssetsAudioPlayer audioPlayer = new AudioPlayer.AssetsAudioPlayer.withId('moodplaner')
..current.listen((AudioPlayer.Playing? current) async {
  if (current != null) {
    try {
      const AndroidNotificationDetails settings = AndroidNotificationDetails(
        'com.alexmercerind.harmonoid',
        'Moodplaner',
        '',
        icon: 'mipmap/ic_launcher',
        importance: Importance.max,
        priority: Priority.max,
        showWhen: false,
        onlyAlertOnce: true,
        playSound: false,
        enableVibration: false,
        showProgress: true,
        indeterminate: true,
      );

    }
    catch(exception) {
      Future.delayed(
        Duration(seconds: 2),
        () => notification.cancel(
          100000,
        ),
      );
    }
  }
});


abstract class Playback {

  static Future<void> play({required int index, required List<Track> tracks}) async {


    List<Track> _tracks = tracks;
    List<AudioPlayer.Audio> audios = <AudioPlayer.Audio>[];
    _tracks.forEach((Track track) async {
      if (track.filePath==null) {

        audios.add(
          new AudioPlayer.Audio.liveStream(
              '$SERVER_IP/songs/${track.hash}',
              headers: {"Authorization": (await storage.read(key: "token"))!},
              metas: new AudioPlayer.Metas(
                title: track.getName(),
                album: track.albumArtistName ?? 'Unknown artist',
              )
          ),
        );


      } else {
        audios.add(
          new AudioPlayer.Audio.file(
              track.filePath!,
              metas: new AudioPlayer.Metas(

                title: track.getName(),
                album: track.albumArtistName ?? 'Unknown artist',
              )
          ),
        );
      }
    });
    audioPlayer.open(
      new AudioPlayer.Playlist(
        audios: audios,
        startIndex: index,
      ),
      showNotification: true,
      loopMode: AudioPlayer.LoopMode.playlist,
      notificationSettings: new AudioPlayer.NotificationSettings(
        playPauseEnabled: true,
        nextEnabled: true,
        prevEnabled: true,
        seekBarEnabled: true,
        stopEnabled: false,   
      ),
    );
  }
}
