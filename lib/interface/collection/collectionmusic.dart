import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:provider/provider.dart';
import 'dart:math' as math;

import 'package:moodplaner/constants/language.dart';
import 'package:moodplaner/core/mediatype.dart';

import '../moodplaner.dart';
import '../home.dart';
import 'collectiongenerator.dart';
import 'collectionplaylist.dart';
import 'collectiontrack.dart';


class CollectionMusic extends StatefulWidget {
  const CollectionMusic({Key? key}) : super(key: key);
  CollectionMusicState createState() => CollectionMusicState();
}


class CollectionMusicState extends State<CollectionMusic> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  bool _refreshLock = true;
  late double _refreshTurns;
  late Tween<double> _refreshTween;
  TabController? _tabController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    this._tabController = TabController(initialIndex: 0, length: 3, vsync: this);
    this._refreshTurns = 0;
    this._refreshTween = Tween<double>(begin: 0, end: this._refreshTurns);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
    //  resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).brightness == Brightness.light ? Theme.of(context).accentColor: Theme.of(context).appBarTheme.color,
        child: TweenAnimationBuilder(
          child: Icon(
            Icons.refresh,
            color: Theme.of(context).brightness == Brightness.light ? Colors.white: Theme.of(context).accentColor
          ),
          tween: this._refreshTween,
          duration: Duration(milliseconds: 800),
          builder: (_, dynamic value, child) => Transform.rotate(
            alignment: Alignment.center,
            angle: value,
            child: child,
          ),
        ),
        onPressed: this._refreshLock ? () async {
          this._refreshLock = false;
          this._refreshTurns += 2 * math.pi;
          this._refreshTween = Tween<double>(begin: 0, end: this._refreshTurns);
          await context.read(collectionProvider).refresh();
          this._refreshLock = true;
          this.setState(() {});
        }: () {},
      ),
      body: DefaultTabController(
        length: 3,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return <Widget>[
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverAppBar(
                  elevation: innerBoxIsScrolled ? 4.0 : 1.0,
                  forceElevated: true,
                  pinned: true,
                  floating: true,
                  snap: true,
                  title: Text('MoodPlaner'),
                  centerTitle: context.read(visualProvider).platform== TargetPlatform.iOS,
                  actions: [
                    IconButton(
                      icon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
                      iconSize: Theme.of(context).iconTheme.size!,
                      splashRadius: Theme.of(context).iconTheme.size! - 8,
                      tooltip: language!.STRING_SEARCH_COLLECTION,
                      onPressed: () {
                        Navigator.of(context).pushNamed('collectionSearch');
                      },
                    ),

                  ],
                  bottom:  TabBar(
                    controller: this._tabController,
                    indicatorColor: Theme.of(context).accentColor,
                    isScrollable: true,
                    tabs: [
                      Tab(
                        child: Text(
                          language!.STRING_TRACK.toUpperCase(),
                        ),
                      ),
                      Tab(
                        child: Text(
                          language!.STRING_PLAYLISTS.toUpperCase(),
                        ),
                      ),
                      Tab(
                        child: Text(
                          language!.STRING_GENERATORS.toUpperCase(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: Consumer(
            builder: (context, collection, _) => TabBarView(
              controller: this._tabController,
              children: <Widget>[
                Builder(
                  key: PageStorageKey(new Track(todel:false).type),
                  builder: (context) => CollectionTrackTab(),
                ),
                Builder(
                  key: PageStorageKey(new Playlist().type),
                  builder: (context) => CollectionPlaylistTab(),
                ),
                Builder(
                  key: PageStorageKey(new Generator().type),
                  builder: (context) => CollectionGeneratorTab(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
