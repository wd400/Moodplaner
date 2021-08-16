
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:moodplaner/core/mediatype.dart';
import 'package:moodplaner/core/metrictype.dart';
import 'package:moodplaner/core/synchronization.dart';
import 'package:moodplaner/utils/chips_widget.dart';
import 'package:moodplaner/utils/graph_widget.dart';
import 'package:multi_select_flutter/dialog/mult_select_dialog.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
final int _offsetXvaluesMin=6;
final int _offsetXvaluesMax=40;

//TODO:dupliquer playlists & generators
//TODO:rename


class CollectionGenerator extends StatefulWidget {
  Generator generator;


  CollectionGenerator({Key? key, required this.generator}) : super(key: key);

  @override
  _CollectionGeneratorState createState() => _CollectionGeneratorState();
}

class _CollectionGeneratorState extends State<CollectionGenerator> {

  @override
  void initState(){
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
   //   DeviceOrientation.portraitUp,
   //   DeviceOrientation.portraitDown,
    ]);
    context.read(graphDataProvider).useCustomData(widget.generator);



  }

  @override
  dispose(){
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
    widget.generator.lastModif=DateTime.now();
    this.widget.generator.save();
    syncGenerators();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

/*      appBar: AppBar(
        title: Text(this.widget.generator.generatorName??"Unamed"),
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
      ),*/
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
         SafeArea(child:   Text(this.widget.generator.generatorName??"Unamed",textAlign: TextAlign.center,)),
//             TextFormField(
//               maxLength: 30,
//
//               onChanged: null,
//               onEditingComplete: null,
//               onFieldSubmitted: null,
//               initialValue: this.widget.generator.generatorName,
// //  controller: new TextEditingController(text: 'INITIAL_TEXT_HERE'),
//
// //           controller: new TextEditingController.fromValue(new TextEditingValue(text: _username,selection: new TextSelection.collapsed(offset: _username.length-1))),
// //            onChanged: (val) => _username = val,
//
//               decoration: const InputDecoration(
//                 counterText: "",
//                 border: InputBorder.none,
//                 focusedBorder: InputBorder.none,
//                 enabledBorder: InputBorder.none,
//                 errorBorder: InputBorder.none,
//                 disabledBorder: InputBorder.none,
//                 contentPadding: EdgeInsets.only(left: 15),
//               ),
//             ),
            Flexible(
                child: Row(
//      mainAxisAlignment: MainAxisAlignment.center,
//     crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                SizedBox(width:   35,
                    child:Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            const Icon(Icons.zoom_in),
                          Flexible(child:
                            RotatedBox(
                                quarterTurns: -1,
                                child: Consumer(
                                builder: (BuildContext context, T Function<T>(ProviderBase<Object?, T>) watch, Widget? child) {
                                  var value=watch(offsetXvaluesProvider).value;
                                  return Slider(
                                    value:  (value-_offsetXvaluesMin)/(_offsetXvaluesMax-_offsetXvaluesMin),
                                    onChanged: (newValue) {
                                      context.read(offsetXvaluesProvider).update(value:(newValue*(_offsetXvaluesMax-_offsetXvaluesMin)+_offsetXvaluesMin).toInt());
                                    },
                                    onChangeEnd:  (newValue) {
                                      //TODO: code redondant
                                      context.read(offsetXvaluesProvider).update(value:(newValue*(_offsetXvaluesMax-_offsetXvaluesMin)+_offsetXvaluesMin).toInt());
                                    } ,
                                  );
                                },
                                ),
                            ),
                          ),
                            const Icon(Icons.zoom_out),

                          ])),

                      Flexible(
                          child: Container(
    margin: const EdgeInsets.all(15.0),
    padding: const EdgeInsets.all(3.0),
    decoration: BoxDecoration(
    border: Border.all(color: Colors.blueAccent)
    ),
    child: Stack(fit: StackFit.expand, children: <Widget>[

                            ClipRect(
                              //  borderRadius: BorderRadius.circular(10),
                                child:

                                Container(
//     color: Colors.tealAccent,
                                    child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          return DrawableBoard(constraints: constraints);

    }

    )

    )),
                            Align(
                              alignment: Alignment.topRight,
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: ToggleSwitch(

                                  minHeight: 30,
                                  minWidth: 40.0,
//       cornerRadius: 20.0,
//   activeBgColors: [[Colors.cyan], [Colors.redAccent]],
//   activeFgColor: Colors.white,
//  inactiveBgColor: Colors.grey,
//   inactiveFgColor: Colors.white,
                                  totalSwitches: 2,
                                  icons: const [
                                    FontAwesomeIcons.chartLine,
                                    FontAwesomeIcons.chartBar
                                  ],

                                  onToggle: (index) {
                                    context.read(paintSettingsProvider).updatebargraph(value: index==1);

                                  },
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: ToggleSwitch(
//     minWidth: 90.0,
//       cornerRadius: 20.0,
//   activeBgColors: [[Colors.cyan], [Colors.redAccent]],
//   activeFgColor: Colors.white,
//  inactiveBgColor: Colors.grey,
//   inactiveFgColor: Colors.white,
                                  initialLabelIndex: 1,
                                  totalSwitches: 2,
                                  icons: const [

                                    FontAwesomeIcons.eraser,
                                    FontAwesomeIcons.pen
                                  ],
                                  onToggle: (index) {
                                 context.read(eraseModeProvider).setEraser(value: index==0);

                                  },
                                ),
                              ),
                            ),
                          ]))),
                    ])
            ),

    SizedBox(height: 100,child:  Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children:  <Widget>[
                IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) =>     MultiSelectDialog(
    initialValue: context.read(graphDataProvider).generator.measures.keys.toList(),
    items: METRICS.map((value) => MultiSelectItem<int?>(value.metricId,value.name)).toList(),
    listType: MultiSelectListType.CHIP,
    onConfirm: (values) {
  //  if (values.isNotEmpty) {
    //  context.read(currentMetricIdProvider).update(metricId: values[0] as int);
  //  }
    context.read(graphDataProvider).updateMetricid(values);
    },
    ),
                        );
                      },
                    ),

             Flexible(child:       ChipWidget()),
//          ElevatedButton(onPressed: null,child: Icon(Icons.delete)),

       /*    IconButton(

                        icon: Icon(Icons.save),
             onPressed: () {
                          widget.generator.measures= context.read(graphDataProvider).data;
                          widget.generator.lastModif=DateTime.now();
                          widget.generator.save();
             },
           )

                 ,  */
                  ],
            )),
 //  Flexible(child:Container())
          ]
      ),
    );
  }
}



class EraseMode extends ChangeNotifier {
  bool eraser=false;

  void setEraser({required bool value}) {
    this.eraser = value;
  }
}

final eraseModeProvider=ChangeNotifierProvider<EraseMode>(
      (context) => EraseMode(),
);
