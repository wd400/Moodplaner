import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moodplaner/constants/language.dart';
import 'package:moodplaner/core/mediatype.dart';
import 'package:moodplaner/core/playback.dart';
import 'package:moodplaner/utils/widgets.dart';
import 'package:path/path.dart';
//import 'package:provider/provider.dart';
import 'package:share/share.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'edittrackmetrics.dart';


class CollectionTrackTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    int elementsPerRow = MediaQuery
        .of(context)
        .size
        .width ~/ (156 + 8);
    double tileWidth = (MediaQuery
        .of(context)
        .size
        .width - 16 - (elementsPerRow - 1) * 8) / elementsPerRow;
    return CustomScrollView(

        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          SliverList(
            delegate: SliverChildListDelegate(

              Hive
                  .box<Track>('tracks')
                  .isNotEmpty ? () {
                List<Widget> children = <Widget>[];
                children.addAll([
           //       SubHeader(language!.STRING_LOCAL_TOP_SUBHEADER_TRACK),
         //         LeadingCollectionTrackTile(),
        //          SubHeader(language!.STRING_LOCAL_OTHER_SUBHEADER_TRACK),


                  ValueListenableBuilder(

                      valueListenable: Hive.box<Track>('tracks').listenable(),


                      builder: (BuildContext context, Box<dynamic> trackBox,
                          Widget? child) {
                        List tracksKeys = trackBox.keys.toList();
                        print(tracksKeys);
                        tracksKeys.removeWhere((element) =>
                        (trackBox.get(element) as Track).todel == true);
                        return ListView.builder(
                            itemCount: tracksKeys.length,
                            scrollDirection: Axis.vertical,

                            shrinkWrap: true,
                            itemBuilder: (BuildContext context,
                                int index) {
                              Track track=trackBox.get(tracksKeys[index]);
                              return CollectionTrackTile(
                                track: track,
                                index: index,
                                popupMenuButton: PopupMenuButton(
                                  elevation: 3,
                                  onSelected: (idx) {
                                    switch (idx) {
                                      case 0:
                                        showDialog(
                                          context: context,
                                          builder: (subContext) =>
                                              AlertDialog(
                                                title: Text(
                                                  language!.STRING_LOCAL_ALBUM_VIEW_TRACK_DELETE_DIALOG_HEADER,
                                                  style: Theme
                                                      .of(subContext)
                                                      .textTheme
                                                      .headline1,
                                                ),
                                                content: Text(
                                                  language!
                                                      .STRING_LOCAL_ALBUM_VIEW_TRACK_DELETE_DIALOG_BODY,
                                                  style: Theme
                                                      .of(subContext)
                                                      .textTheme
                                                      .headline5,
                                                ),
                                                actions: [
                                                  MaterialButton(
                                                    textColor: Theme
                                                        .of(context)
                                                        .primaryColor,
                                                    onPressed: () async {

                                                      ((trackBox.get(
                                                          tracksKeys[index]) as Track)
                                                        ..todel=true).save();
                                                      Navigator.of(subContext)
                                                          .pop();

                                                    },
                                                    child: Text(
                                                        language!.STRING_YES),
                                                  ),
                                                  MaterialButton(
                                                    textColor: Theme
                                                        .of(context)
                                                        .primaryColor,
                                                    onPressed: Navigator
                                                        .of(subContext)
                                                        .pop,
                                                    child: Text(
                                                        language!.STRING_NO),
                                                  ),
                                                ],
                                              ),
                                        );
                                        break;
                                      case 1:
                                        Share.shareFiles(
                                          [trackBox
                                              .get(tracksKeys[index])
                                              .filePath!
                                          ],
                                          subject:
                                          '${trackBox
                                              .get(tracksKeys[index])
                                              .trackName} - ${trackBox
                                              .get(tracksKeys[index])
                                              .albumArtistName}. Shared using Moodplaner!',
                                        );
                                        break;
                                      case 2:
                                        showDialog(
                                          context: context,
                                          builder: (subContext) =>
                                              AlertDialog(
                                                contentPadding: EdgeInsets.zero,
                                                actionsPadding: EdgeInsets.zero,
                                                title: Text(
                                                  language!
                                                      .STRING_PLAYLIST_ADD_DIALOG_TITLE,
                                                  style: Theme
                                                      .of(subContext)
                                                      .textTheme
                                                      .headline1,
                                                ),
                                                content: Container(
                                                  height: 280,
                                                  child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment
                                                          .start,
                                                      mainAxisAlignment: MainAxisAlignment
                                                          .start,
                                                      mainAxisSize: MainAxisSize
                                                          .min,
                                                      children: [
                                                        Padding(
                                                          padding: EdgeInsets
                                                              .fromLTRB(
                                                              24, 8, 0, 16),
                                                          child: Text(
                                                            language!
                                                                .STRING_PLAYLIST_ADD_DIALOG_BODY,
                                                            style: Theme
                                                                .of(subContext)
                                                                .textTheme
                                                                .headline5,
                                                          ),
                                                        ),
                                                        Container(
                                                          height: 236,
                                                          width: 280,
                                                          decoration: BoxDecoration(
                                                            border: Border
                                                                .symmetric(
                                                              vertical: BorderSide(
                                                                color: Theme
                                                                    .of(context)
                                                                    .dividerColor,
                                                                width: 1,
                                                              ),
                                                            ),
                                                          ),
                                                          child: ValueListenableBuilder(

                                                              valueListenable: Hive
                                                                  .box<Playlist>(
                                                                  'playlists')
                                                                  .listenable(),


                                                              builder: (
                                                                  BuildContext context,
                                                                  Box<
                                                                      dynamic> playlistBox,
                                                                  Widget? child) {
                                                                var playlistsKeys = playlistBox
                                                                    .keys
                                                                    .toList();
                                                                return ListView
                                                                    .builder(
                                                                  shrinkWrap: true,
                                                                  itemCount: playlistsKeys
                                                                      .length,
                                                                  itemBuilder: (
                                                                      context,
                                                                      playlistIndex) {
                                                                    return ListTile(
                                                                      title: Text(
                                                                        playlistBox
                                                                            .get(
                                                                            playlistsKeys[playlistIndex])
                                                                            .playlistName!,
                                                                        style:
                                                                        Theme
                                                                            .of(
                                                                            context)
                                                                            .textTheme
                                                                            .headline2,
                                                                      ),
                                                                      leading: Icon(
                                                                        Icons
                                                                            .queue_music,
                                                                        size: Theme
                                                                            .of(
                                                                            context)
                                                                            .iconTheme
                                                                            .size,
                                                                        color: Theme
                                                                            .of(
                                                                            context)
                                                                            .iconTheme
                                                                            .color,
                                                                      ),
                                                                      onTap: () async {
                                                                        (playlistBox
                                                                            .get(
                                                                            playlistsKeys[playlistIndex]) as Playlist)
                                                                            .tracks
                                                                            .add(
                                                                            trackBox
                                                                                .get(
                                                                                tracksKeys[index]) as Track);

                                                                        Navigator
                                                                            .of(
                                                                            subContext)
                                                                            .pop();
                                                                      },
                                                                    );
                                                                  },
                                                                );
                                                              }
                                                          ),
                                                        ),
                                                      ]),
                                                ),
                                                actions: [
                                                  MaterialButton(
                                                    textColor: Theme
                                                        .of(context)
                                                        .primaryColor,
                                                    onPressed: Navigator
                                                        .of(subContext)
                                                        .pop,
                                                    child: Text(language!
                                                        .STRING_CANCEL),
                                                  ),
                                                ],
                                              ),
                                        );
                                        break;
                                      case 3:
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            //GeneratorDrawerWidget
                                              builder: (
                                                  BuildContext context) {

                                                // context.read(paintSettingsProvider).updatebargraph(value: false);

                                                return   EditTrackMetrics(track:track);

                                              }
                                          ),
                                        );
                                        break;

                                    }
                                  },
                                  icon: Icon(Icons.more_vert,
                                      color: Theme
                                          .of(context)
                                          .iconTheme
                                          .color,
                                      size: Theme
                                          .of(context)
                                          .iconTheme
                                          .size),
                                  tooltip: language!.STRING_OPTIONS,
                                  itemBuilder: (_) =>
                                  <PopupMenuEntry>[
                                    PopupMenuItem(
                                      value: 0,
                                      child: Text(language!.STRING_DELETE),
                                    ),
                                    PopupMenuItem(
                                      value: 1,
                                      child: Text(language!.STRING_SHARE),
                                    ),
                                    PopupMenuItem(
                                      value: 2,
                                      child: Text(
                                          language!.STRING_ADD_TO_PLAYLIST),
                                    ),
                                      PopupMenuItem(
                                        value: 3,
                                        child: Text(
                                            language!.STRING_EDIT_MEASURES
                                        ),
                                    ),
                                  ],
                                ),
                              );
                            }
                        );
                      })
                ]
                );
                return children;
              }() : <Widget>[
                ExceptionWidget(
                  margin: EdgeInsets.only(
                    top: (MediaQuery
                        .of(context)
                        .size
                        .height - (MediaQuery
                        .of(context)
                        .padding
                        .top + MediaQuery
                        .of(context)
                        .padding
                        .bottom + tileWidth + 256.0)) / 2,
                    left: 8.0,
                    right: 8.0,
                  ),
                  height: tileWidth,
                  assetImage: 'assets/images/collection-album.jpg',
                  title: language!.STRING_NO_COLLECTION_TITLE,
                  subtitle: language!.STRING_NO_COLLECTION_SUBTITLE,
                  large: true,
                ),
              ],
            ),
          ),
        ]);
  }
  }




class CollectionTrackTile extends StatelessWidget {
  final Track track;
  final int? index;
  final PopupMenuButton popupMenuButton;
  const CollectionTrackTile({Key? key, required this.track, this.index, required this.popupMenuButton});

  @override
  Widget build(BuildContext context) {
    return Material(
            color: Colors.transparent,
            child: ListTile(
              onTap: () =>
              this.index != null
                  ? Playback.play(
                index: this.index!,
                tracks: Hive.box<Track>('tracks').values.toList(),
              )
                  : Playback.play(
                index: 0,
                tracks: <Track>[this.track],
              ),
              dense: false,
              title: Text(this.track.getName(),
                style: Theme
                    .of(context)
                    .textTheme
                    .headline2!,
                overflow: TextOverflow.fade,
                maxLines: 1,
                softWrap: false,
              ),
              subtitle: Text(this.track.albumArtistName??'Unknown artist',
                style: Theme
                    .of(context)
                    .textTheme
                    .headline5!,
                overflow: TextOverflow.fade,
                maxLines: 1,
                softWrap: false,
              ),
              leading: track.synced?Icon(Icons.cloud_done):Icon(Icons.cloud_off),
              trailing: popupMenuButton,

            ),
          );
        }
  }


