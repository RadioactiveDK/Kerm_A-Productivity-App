// Daily Quest Tab
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:kerm/scores.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

class MyDailyQuest extends StatefulWidget {
  const MyDailyQuest({Key? key}) : super(key: key);

  @override
  State<MyDailyQuest> createState() => MyDailyQuestState();
}
class MyDailyQuestState extends State<MyDailyQuest> {
  bool isLocked = false;
  var prefs;

  @override
  void initState(){
    super.initState();
    loadBool();
  }

  Future<void> loadBool() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      isLocked = prefs.getBool('isLocked')!;
    });
  }

  void updateQuests()async{
    KermDatabase kdb = KermDatabase();
    await kdb.updateQuestData();
    await kdb.updateScoreData();
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLocked', isLocked);
    setState(() {});
  }
  updateState(){
    return ()=>updateQuests();
  }

  refreshState(bool isLock){
    isLocked=isLock;
    setState(() {});
  }
  createQuestWidgets(){
    var questWidgets = <Widget>[];
    questList.forEach((key, value) {
      questWidgets.add(
        MyQuestWidget(
          isLocked: isLocked,
          questName: key,
          updateState: updateState(),
        )
      );
    });
    return questWidgets;
  }

  final myController = TextEditingController();
  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: (isLocked)?Container():FloatingActionButton(
          child: const Icon(Icons.add,size: 25,),
          onPressed: (){
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Manage your Quests'),
                  content: !isLocked ?
                  TextField(
                    controller: myController,
                    decoration: const InputDecoration(
                      labelText: 'Add a Quest',
                    ),
                  ):
                  const Text(''),
                  actions: [
                    // if(!isLocked)TextButton(
                    //   onPressed: (){},
                    //   onLongPress: (){
                    //     if(scoreList[timeInfo.weekday+51]==9) {
                    //       DateTime endTime = DateTime.parse(
                    //           prefs.getString('endTime'));
                    //       DateTime newTime = DateTime(
                    //           timeInfo.year, timeInfo.month, timeInfo.day,
                    //           endTime.hour, endTime.minute);
                    //       if (scoreList[timeInfo.weekday + 51] == 9) {
                    //         prefs.setString('endTime', newTime.toString());
                    //       }
                    //       else {
                    //         newTime = newTime.add(const Duration(days: 1));
                    //         prefs.setString('endTime', newTime.toString());
                    //       }
                    //       isLocked = true;
                    //       questList.forEach((key, value) {
                    //         questList[key] = '0${value[1]}';
                    //       });
                    //       updateQuests();
                    //       Navigator.pop(context);
                    //     }
                    //   },
                    //   child: (scoreList[timeInfo.weekday+51]==9)?
                    //     const Text('Start Quests'):
                    //     const Text('Start Quests',style: TextStyle(color:Colors.red,)),
                    // ),
                    // if(isLocked) TextButton(
                    //     onPressed: (){},
                    //     onLongPress: (){
                    //       double totalMarks = 0;
                    //       double myMarks = 0;
                    //       questList.forEach((key, value) {
                    //         totalMarks = totalMarks + int.parse(value[1]);
                    //         myMarks = myMarks + int.parse(value[1])*int.parse(value[0]);
                    //       });
                    //       if(true || scoreList[timeInfo.weekday+51]==9){
                    //         isLocked=false;
                    //         scoreList[51 + timeInfo.weekday] = totalMarks == 0
                    //             ? 0
                    //             : (myMarks *8 / totalMarks).round();
                    //         KermDatabase kdb = KermDatabase();
                    //         kdb.updateScoreData();
                    //         updateQuests();
                    //         Navigator.pop(context);
                    //
                    //         Navigator.push(
                    //           context,
                    //           MaterialPageRoute(builder: (context) => ElevatedButton(
                    //             style: ElevatedButton.styleFrom(backgroundColor:Colors.black38),
                    //             onPressed: () {
                    //               Navigator.pop(context);
                    //             },
                    //             child: const MyScores(),
                    //           ),
                    //           ),
                    //         );
                    //       }
                    //     },
                    //     child: (true)?const Text('End Quests'):const Text('End Quests',style: TextStyle(color:Colors.red,))
                    // ),
                    IconButton(
                        onPressed: (){
                          myController.text='';
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close_sharp)
                    ),
                    if(!isLocked)IconButton(
                      icon: const Icon(Icons.done_outline_sharp),
                      onPressed: (){
                        if(myController.text!='') {
                          questList[myController.text]='00';
                          myController.text='';
                          updateQuests();
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                );
              },
            );
          }
      ),
      body: Container(
        padding: const EdgeInsets.all(5),
        child: SingleChildScrollView(
          child: Column(
            children: createQuestWidgets(),
          ),
        ),
      ),
    );
  }
}

class MyQuestWidget extends StatefulWidget {
  String questName;
  bool isLocked;
  VoidCallback updateState;

  MyQuestWidget({Key? key, required this.questName,required this.isLocked,required this.updateState}) : super(key: key);

  @override
  State<MyQuestWidget> createState() => _MyQuestWidgetState();
}
class _MyQuestWidgetState extends State<MyQuestWidget> {

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(3),child:ElevatedButton(
      onPressed: (){
        if(!widget.isLocked) {
          showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Are you sure you want to delete this quest?'),
              actions: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:[
                      if(!widget.isLocked)TextButton(
                          onPressed: (){},
                          onLongPress:(){
                            questList.remove(widget.questName);
                            if(questList.isEmpty)questList['Add a Quest']='00';
                            widget.updateState();
                            Navigator.pop(context);
                          },
                          child: const Text('Delete Quest')
                      ),
                      // if(widget.isLocked )TextButton(
                      //     child: (questList[widget.questName]![0]=='0')?const Text('Mark as done'):const Text('Mark as undone'),
                      //     onPressed: (){},
                      //     onLongPress:(){
                      //       (questList[widget.questName]![0]=='0')?
                      //       questList[widget.questName]='1${questList[widget.questName]![1]}':
                      //       questList[widget.questName]='0${questList[widget.questName]![1]}';
                      //       widget.updateState();
                      //       Navigator.pop(context);
                      //     }
                      // ),
                      IconButton(
                          onPressed: (){Navigator.pop(context);},
                          icon: const Icon(Icons.close_sharp)
                      ),
                    ]
                )
              ],
            );
          },
        );
        }
      },
      onLongPress:()async{
        if(widget.isLocked) {
          if(questList[widget.questName]![0] == '0') {
            final AudioPlayer _audioPlayer = AudioPlayer();
            for(int i=0;i<int.parse(questList[widget.questName]![1]!);i++) {
              await _audioPlayer.play(AssetSource('coins.mp3'));
              await _audioPlayer.onPlayerComplete.first;
            }
          }
          (questList[widget.questName]![0] == '0') ?
          questList[widget.questName] = '1${questList[widget.questName]![1]}' :
          questList[widget.questName] = '0${questList[widget.questName]![1]}';
          widget.updateState();
          // Navigator.pop(context);
        }
      },
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor:  (questList[widget.questName]![0]=='0')?Colors.white:Colors.black,
      ),
      child: Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.all(5),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.questName,style: questList[widget.questName]![0] == '0' ? TextStyle(color: Colors.black) : TextStyle(color:Colors.white, decoration: TextDecoration.lineThrough)),
              DropdownButton<String>(
                value: questList[widget.questName]![1],
                icon: const Icon(Icons.arrow_drop_down,color: Colors.cyan,),
                elevation: 16,
                underline: Container(
                  color: Colors.cyan,
                  height: 2,
                ),
                onChanged: widget.isLocked? null:(String? value) {
                  questList[widget.questName] = questList[widget.questName]![0] + value!;
                  widget.updateState();
                },
                items: ['0','1','2','3','4','5'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value,style: const TextStyle(color: Colors.cyan)),
                  );
                }).toList(),
              )
            ]
        ),
      ),
    ));
  }
}
