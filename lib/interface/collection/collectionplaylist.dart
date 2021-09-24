import 'package:flutter/material.dart';

import 'package:hive/hive.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:moodplaner/constants/language.dart';
import 'package:moodplaner/core/collection.dart';
import 'package:moodplaner/core/mediatype.dart';
import 'package:moodplaner/core/playback.dart';
import 'package:moodplaner/core/synchronization.dart';


class CollectionPlaylistTab extends StatelessWidget {
  final TextEditingController _textFieldController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
            slivers: [
              SliverOverlapInjector(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                    context),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                    <Widget>[
                      Container(
                        margin: EdgeInsets.all(8),
                        child: Card(
                          elevation: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(
                                    left: 16, top: 16, bottom: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        language!.STRING_PLAYLISTS, style: Theme
                                        .of(context)
                                        .textTheme
                                        .headline1),
                                    Text(language!.STRING_PLAYLISTS_SUBHEADER,
                                        style: Theme
                                            .of(context)
                                            .textTheme
                                            .headline5),
                                  ],
                                ),
                              ),
                              PageStorage(
                                bucket: PageStorageBucket(),
                                child: ExpansionTile(
                                  maintainState: false,
                                  initiallyExpanded: false,
                                  childrenPadding: EdgeInsets.only(
                                      top: 12, bottom: 12, left: 16, right: 16),
                                  leading: Icon(
                                    Icons.queue_music,
                                    size: Theme
                                        .of(context)
                                        .iconTheme
                                        .size,
                                    color: Theme
                                        .of(context)
                                        .iconTheme
                                        .color,
                                  ),
                                  trailing: Icon(
                                    Icons.add,
                                    size: Theme
                                        .of(context)
                                        .iconTheme
                                        .size,
                                    color: Theme
                                        .of(context)
                                        .iconTheme
                                        .color,
                                  ),
                                  title: Text(language!.STRING_PLAYLISTS_CREATE,
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .headline2),
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .start,
                                      crossAxisAlignment: CrossAxisAlignment
                                          .center,
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: this
                                                ._textFieldController,
                                            cursorWidth: 1,
                                            autofocus: true,
                                            autocorrect: true,
                                            onSubmitted: (String value) async {
                                              if (value != '') {
                                                FocusScope.of(context)
                                                    .unfocus();
                                                Hive.box<Playlist>("playlists").add(
                                                    new Playlist(
                                                      playlistId: random.nextInt(intMaxValue),
                                                        playlistName: value));
                                                this._textFieldController
                                                    .clear();
                                              }
                                            },
                                            decoration: InputDecoration(
                                              labelText: language!
                                                  .STRING_PLAYLISTS_TEXT_FIELD_LABEL,
                                              hintText: language!
                                                  .STRING_PLAYLISTS_TEXT_FIELD_HINT,
                                              labelStyle: TextStyle(color: Theme
                                                  .of(context)
                                                  .accentColor),
                                              enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Theme
                                                          .of(context)
                                                          .accentColor,
                                                      width: 1)),
                                              border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Theme
                                                          .of(context)
                                                          .accentColor,
                                                      width: 1)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Theme
                                                          .of(context)
                                                          .accentColor,
                                                      width: 1)),
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: 56,
                                          width: 56,
                                          alignment: Alignment.center,
                                          child: IconButton(
                                            onPressed: () async {
                                              if (this._textFieldController
                                                  .text != '') {
                                                FocusScope.of(context)
                                                    .unfocus();
                                                Hive.box<Playlist>("playlists").add(
                                                    new Playlist(
                                                        playlistId: random.nextInt(intMaxValue),
                                                        playlistName: this
                                                            ._textFieldController
                                                            .text));
                                                this._textFieldController
                                                    .clear();
                                              }
                                            },
                                            icon: Icon(
                                              Icons.check,
                                              color: Theme
                                                  .of(context)
                                                  .primaryColor,
                                            ),
                                            iconSize: 24,
                                            splashRadius: 20,
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              ValueListenableBuilder(

                              valueListenable: Hive.box<Playlist>('playlists').listenable(),


    builder: (BuildContext context, Box<dynamic> box, Widget? child) {
      var playlistsKeys = box.keys.toList();
      playlistsKeys.removeWhere((element) =>
      (box.get(element) as Playlist).todel == true);
      return ListView.builder(
          itemCount: playlistsKeys.length,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemBuilder: (BuildContext context,
              int index) {
            return ListTile(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) =>
                        CollectionPlaylist(
                          playlist: box.get(playlistsKeys[index]),
                        ),
                  ),
                );
              },
              onLongPress: () =>
                  showDialog(
                    context: context,
                    builder: (subContext) =>
                        AlertDialog(
                          title: Text(
                            language!
                                .STRING_LOCAL_ALBUM_VIEW_PLAYLIST_DELETE_DIALOG_HEADER,
                            style: Theme
                                .of(subContext)
                                .textTheme
                                .headline1,
                          ),
                          content: Text(
                            language!
                                .STRING_LOCAL_ALBUM_VIEW_PLAYLIST_DELETE_DIALOG_BODY,
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

                                ((box.get(playlistsKeys[index]) as Playlist)..todel=true..lastModif=DateTime.now()).save();
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
                  ),
              leading: Icon(
                Icons.queue_music,
                size: Theme
                    .of(context)
                    .iconTheme
                    .size,
                color: Theme
                    .of(context)
                    .iconTheme
                    .color,
              ),
              title: Text(box
                  .get(playlistsKeys[index])
                  .playlistName!),
              trailing: IconButton(
                onPressed: () =>
                    Playback.play(
                      index: 0,
                      tracks: box
                          .get(playlistsKeys[index])
                          .tracks,
                    ),
                icon: Icon(
                  Icons.play_arrow,
                  color: Theme
                      .of(context)
                      .iconTheme
                      .color,
                ),
                iconSize: Theme
                    .of(context)
                    .iconTheme
                    .size!,
                splashRadius: Theme
                    .of(context)
                    .iconTheme
                    .size! - 8,
              ),
            );
          });
    }),
                      ]
          )
          )
                ),

            ],
          ))]);
        }

  }



class CollectionPlaylist extends StatefulWidget {
  Playlist playlist;


  CollectionPlaylist({Key? key, required this.playlist}) : super(key: key);

  @override
  _CollectionPlaylistState createState() => _CollectionPlaylistState(playlist: playlist);
}

class _CollectionPlaylistState extends State<CollectionPlaylist> {
  Playlist playlist;


  _CollectionPlaylistState({required this.playlist});

  @override
  Widget build(BuildContext context) {


    //TODO: fetch infos


    return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.close),
                iconSize: Theme
                    .of(context)
                    .iconTheme
                    .size!,
                splashRadius: Theme
                    .of(context)
                    .iconTheme
                    .size! - 8,
                onPressed: Navigator
                    .of(context)
                    .pop,
              ),


              title:             TextFormField(
                maxLength: 30,

                onFieldSubmitted: (String s){
                  widget.playlist.lastModif=DateTime.now();
                  widget.playlist.playlistName=s;
                  widget.playlist.save();
                },
                initialValue: this.widget.playlist.playlistName,
//  controller: new TextEditingController(text: 'INITIAL_TEXT_HERE'),

//           controller: new TextEditingController.fromValue(new TextEditingValue(text: _username,selection: new TextSelection.collapsed(offset: _username.length-1))),
//            onChanged: (val) => _username = val,

                decoration: const InputDecoration(
                  counterText: "",
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: EdgeInsets.only(left: 15),
                ),
              ),



            ),
            body: ReorderableListView(
              onReorder: (int oldIndex, int newIndex) {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                setState(() {
                  final item = playlist.tracks.removeAt(oldIndex);
                  playlist.tracks.insert(newIndex, item);
                });
                playlist.lastModif=DateTime.now();
                playlist.save();
                //TODO this.widget.playlist.save();
              },


              children: <Widget>[
                for (int index = 0; index <
                    this.widget.playlist.tracks.length; index++)
                  ListTile(
                    onTap: () =>
                        Playback.play(
                          index: index,
                          tracks: this.widget.playlist.tracks,
                        ),
                    isThreeLine: true,
                    // leading: CircleAvatar(
                    //   child: Text(
                    //       '${this.widget.playlist.tracks[index].trackNumber ?? 1}'),
                    //   backgroundImage: FileImage(
                    //       this.widget.playlist.tracks[index].albumArt),
                    // ),
                    title: Text(this.widget.playlist.tracks[index].getName()),
                    subtitle: Text(this.widget.playlist.tracks[index].albumArtistName??''),

                    key: Key('$index'),
                    trailing: IconButton(
                      onPressed: () {

                            this.widget.playlist.tracks.removeAt(index);
                            this.widget.playlist.lastModif=DateTime.now();
                            this.widget.playlist.save();
                            setState(() {

                            });
                      },

                      icon: Icon(
                        Icons.remove,
                        color: Theme
                            .of(context)
                            .iconTheme
                            .color,
                      ),
                      iconSize: Theme
                          .of(context)
                          .iconTheme
                          .size!,
                      splashRadius: Theme
                          .of(context)
                          .iconTheme
                          .size! - 8,
                    ),
                  ),


              ],
            ),
          );
        }


  @override
  void dispose()  {
    super.dispose();
    syncPlaylists();
  }

  }
