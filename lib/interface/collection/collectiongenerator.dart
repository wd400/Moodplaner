import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
//import 'package:provider/provider.dart';

import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:moodplaner/constants/language.dart';
import 'package:moodplaner/core/collection.dart';
import 'package:moodplaner/core/mediatype.dart';
import 'package:moodplaner/core/synchronization.dart';

import '../../login.dart';
import '../editGenerator.dart';



class CollectionGeneratorTab extends StatelessWidget {
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
                                    crossAxisAlignment: CrossAxisAlignment
                                        .start,
                                    children: [
                                      Text(
                                          language!.STRING_GENERATORS,
                                          style: Theme
                                              .of(context)
                                              .textTheme
                                              .headline1),
                                      Text(language!.STRING_GENERATORS_SUBHEADER,
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
                                        top: 12,
                                        bottom: 12,
                                        left: 16,
                                        right: 16),
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
                                    title: Text(
                                        language!.STRING_GENERATORS_CREATE,
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
                                              onSubmitted: (
                                                  String value) async {
                                                if (value != '') {
                                                  FocusScope.of(context)
                                                      .unfocus();

                                                  Hive.box<Generator>('generators').add(
                                                      new Generator(
                                                        generatorId: random.nextInt(intMaxValue),
                                                          generatorName: value,
                                                      measures:  {}));
                                                  this._textFieldController
                                                      .clear();
                                                }
                                              },
                                              decoration: InputDecoration(
                                                labelText: language!
                                                    .STRING_GENERATORS_TEXT_FIELD_LABEL,
                                                hintText: language!
                                                    .STRING_GENERATORS_TEXT_FIELD_HINT,
                                                labelStyle: TextStyle(
                                                    color: Theme
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

                                                  Hive.box<Generator>('generators').add(
                                                      new Generator(
                                                          generatorId: random.nextInt(intMaxValue),
                                                          generatorName: this
                                                              ._textFieldController
                                                              .text,
                                                      measures: {}));

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

                                    valueListenable: Hive.box<Generator>('generators').listenable(),


                                  builder: (BuildContext context, Box<Generator> box, Widget? child) {
                                      var generatorsKeys = box.keys.toList();
                                      generatorsKeys.removeWhere((element) => (box.get(element) as Generator).todel==true);
                                      return ListView.builder(
                                          itemCount: generatorsKeys.length,
                                          scrollDirection: Axis.vertical,
                                          shrinkWrap: true,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            Generator generator = box.get(
                                                generatorsKeys[index])!;
                                            print(generator.measures);
                                            return ListTile(
                                              onTap: () {



                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    //GeneratorDrawerWidget
                                                    builder: (
                                                        BuildContext context) {
                                                      context.read(eraseModeProvider).setEraser(value: false);

                                                     // context.read(paintSettingsProvider).updatebargraph(value: false);

                                                   return   CollectionGenerator(
                                                        generator: generator);

                                                    }
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
                                                                .STRING_GENERATOR_DELETE_DIALOG_HEADER,
                                                            style: Theme
                                                                .of(subContext)
                                                                .textTheme
                                                                .headline1,
                                                          ),
                                                          content: Text(
                                                            language!
                                                                .STRING_GENERATOR_DELETE_DIALOG_BODY,
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

                                                                (generator..todel=true..lastModif=DateTime.now()).save();

                                                                Navigator.of(
                                                                    subContext)
                                                                    .pop();
                                                              },
                                                              child: Text(
                                                                  language!
                                                                      .STRING_YES),
                                                            ),
                                                            MaterialButton(
                                                              textColor: Theme
                                                                  .of(context)
                                                                  .primaryColor,
                                                              onPressed: Navigator
                                                                  .of(
                                                                  subContext)
                                                                  .pop,
                                                              child: Text(
                                                                  language!
                                                                      .STRING_NO),
                                                            ),
                                                          ],
                                                        ),
                                                  ),
                                              title:  Text(
                                                  generator.generatorName!),
                                              trailing: IconButton(

                                                //TODO: build request
                                                onPressed: ()  {

                                                  authNeeded().then((value)
                                                  {
                                                    switch (value) {
                                                      case 2:

                                                        Navigator.of(context).push(
                                                          MaterialPageRoute(
                                                            //GeneratorDrawerWidget
                                                              builder: (
                                                                  BuildContext context) {
                                                                return LoginPage();
                                                              }
                                                          ),
                                                        );

                                                        break;
                                                      case 1:
                                                        ScaffoldMessenger.of(context).showSnackBar(noInternet);
                                                        break;
                                                      case 0:

                                                        generatePlaylist(generator).then(
                                                                (value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(generator.generatorName!+' Done!'))));

                                                        break;
                                                  }

                                                  });
                                                },
                                                icon: Icon(
                                                  Icons.play_arrow,
                                                  color: Theme
                                                      .of(context)
                                                      .iconTheme
                                                      .color,
                                                ),
                                              ),
                                            );
                                          });



                                  },



                                    )


                              ]),
                        ),
                      )
                    ]
                ),
              ),
            ],
          );
        }

  }


