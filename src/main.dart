import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kerm',
      theme: ThemeData(
          textTheme: Theme.of(context).textTheme.apply(
                bodyColor: Colors.white,
              ),
          scaffoldBackgroundColor: Colors.black,
          iconTheme: const IconThemeData(
            color: Colors.black,
          ),
          appBarTheme: const AppBarTheme(
            color: Colors.white,
            titleTextStyle: TextStyle(color: Colors.black),
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
          )
      ),
      home: const DefaultTabController(
        length: 2,
        child: MyHomePage(),
      ),
    );
  }
}
class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Kerm',
            style: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 25),
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MySettings()),
                );
              },
              icon: const Icon(Icons.settings),
            )
          ],
          bottom: const TabBar(
            tabs: [
              Tab(
                child: Text(
                  'Daily Quests',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              Tab(
                child: Text(
                  'Goals',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MyDailyQuest(),
            MyGoals(),
          ],
        ));
  }
}
class MySettings extends StatefulWidget {
  const MySettings({Key? key}) : super(key: key);

  @override
  State<MySettings> createState() => _MySettingsState();
}
class _MySettingsState extends State<MySettings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.black),
        ),
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(),
    );
  }
}

// Daily Quest Tab
class MyDailyQuest extends StatefulWidget {
  const MyDailyQuest({Key? key}) : super(key: key);

  @override
  State<MyDailyQuest> createState() => _MyDailyQuestState();
}
class _MyDailyQuestState extends State<MyDailyQuest> {
  bool inProgress = true;

  dailyQuestScreen(){
    if(inProgress){
      return DailyQuestScreen();
    } else {
      return HistoryScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return dailyQuestScreen();
  }
}

class DailyQuestScreen extends StatefulWidget {
  const DailyQuestScreen({Key? key}) : super(key: key);

  @override
  State<DailyQuestScreen> createState() => _DailyQuestScreenState();
}
class _DailyQuestScreenState extends State<DailyQuestScreen> {
  bool isLocked = false;
  List<String> questList = ['1'];

  updateState(){
    return ()=>setState((){});
  }

  createQuestWidgets(){
    var questWidgets = <Widget>[];
    questList.forEach((element) {
      questWidgets.add(
          MyQuestWidget(
            questList: questList,
            questName: element,
            updateState: updateState(),
          )
      );
    });
    return questWidgets;
  }

  final myController = new TextEditingController();
  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add,color: Colors.white,),
          onPressed: (){
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text(
                    'Daily Quest',
                    style: TextStyle(color: Colors.black),
                  ),
                  content: TextField(
                    controller: myController,
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w400
                    ),
                  ),
                  actions: [
                    if(!isLocked)TextButton(
                      onPressed: (){},
                      onLongPress: (){
                        isLocked = true;
                        Navigator.pop(context);
                      },
                      child: const Text('Lock Quests'),
                    ),
                    if(isLocked)TextButton(
                        onPressed: (){},
                        onLongPress: (){
                          isLocked=false;
                          Navigator.pop(context);
                        },
                        child: const Text('End Quest')
                    ),
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
                          questList.add(myController.text);
                          setState((){});
                          myController.text='';
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
  String? questName;
  List<String>? questList;
  VoidCallback updateState;

  MyQuestWidget({Key? key, this.questName,this.questList,required this.updateState}) : super(key: key);

  @override
  State<MyQuestWidget> createState() => _MyQuestWidgetState();
}
class _MyQuestWidgetState extends State<MyQuestWidget> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (){},
      onLongPress:(){
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Options',style: TextStyle(color: Colors.black),),
              actions: [
                TextButton(
                    onPressed: (){},
                    onLongPress:(){
                      widget.questList!.remove(widget.questName);
                      widget.updateState();
                      Navigator.pop(context);
                    },
                    child: const Text('Delete milestone')
                ),
                IconButton(
                    onPressed: (){Navigator.pop(context);},
                    icon: const Icon(Icons.close_sharp)
                ),
                TextButton(
                    child: const Text('Mark as done',),
                    onPressed: (){},
                    onLongPress:(){
                      setState((){});
                      Navigator.pop(context);
                    }
                ),
              ],
            );
          },
        );
      },
      style: ElevatedButton.styleFrom(
        primary: Colors.tealAccent,
        shadowColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0)
        ),
      ),
      child: Container(
        alignment: Alignment.centerLeft,
        child: Text(
          widget.questName!,
          textAlign: TextAlign.start,
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}


class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}
class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// Goals tab
class MyGoals extends StatefulWidget {
  const MyGoals({Key? key}) : super(key: key);

  @override
  State<MyGoals> createState() => _MyGoalsState();
}
class _MyGoalsState extends State<MyGoals> {
  KermDatabase kdb = KermDatabase();
  Map< String , List<String>? > goalsMap = {'1':['1']};

  void updateGoals()async{
    setState(() {});
    await kdb.updateGoalData(goalsMap);
  }

  updateState(){
    return ()=>setState((){});
  }

  createGoalWidgets(){
    var goalWidgets = <Widget>[];
    goalsMap.forEach((key, value) {
      goalWidgets.add(
          MyGoalWidget(
            goalName: key,
            milestones: value,
            goalsMap: goalsMap,
            updateState: updateState(),
          )
      );
    });
    return goalWidgets;
  }

  final myController = new TextEditingController();
  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add,color: Colors.white,),
        onPressed: (){
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text(
                  'Add a Long-term Goal',
                  style: TextStyle(color: Colors.black),
                ),
                content: TextField(
                  controller: myController,
                  style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w400
                  ),
                ),
                actions: [
                  IconButton(
                      onPressed: (){myController.text='';Navigator.pop(context);},
                      icon: const Icon(Icons.close_sharp)
                  ),
                  IconButton(
                    icon: const Icon(Icons.done_outline_sharp),
                    onPressed: (){
                      if(myController.text!='' && goalsMap[myController.text]==null) {
                        goalsMap[myController.text]=[];
                        myController.text='';
                        updateGoals();
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
            children: createGoalWidgets(),
          ),
        ),
      ),
    );
  }
}

class MyGoalWidget extends StatefulWidget {
  String? goalName;
  List<String>? milestones;
  Map< String , List<String>? >? goalsMap;
  VoidCallback updateState;

  MyGoalWidget({
    Key? key,
    this.goalName,
    this.milestones,
    this.goalsMap,
    required this.updateState
  }) : super(key: key);

  @override
  State<MyGoalWidget> createState() => _MyGoalWidgetState();
}
class _MyGoalWidgetState extends State<MyGoalWidget> {
  createMilestoneWidgets(){
    var milestoneWidgets=<Widget>[];
    widget.milestones!.forEach((element) => milestoneWidgets.add(
        Container(
          width: double.infinity,
          child: MyTaskWidget(
            myTask: element,
            goalsMap: widget.goalsMap,
            updateState: widget.updateState,
            goalName: widget.goalName,
          )
        )
      )
    );
    return Column(children: milestoneWidgets);
  }

  final myController = new TextEditingController();
  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: Colors.cyanAccent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextButton(
            onLongPress: (){
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text(
                      'Options',
                      style: TextStyle(color: Colors.black),
                    ),
                    actions: [
                      TextButton(
                        onPressed:(){},
                        onLongPress: (){
                          widget.goalsMap!.remove(widget.goalName);
                          myController.text='';
                          widget.updateState();
                          Navigator.pop(context);
                        },
                        child: const Text('Delete Goal'),
                      ),
                      IconButton(
                          onPressed: (){myController.text='';Navigator.pop(context);},
                          icon: const Icon(Icons.close_sharp)
                      ),
                      TextButton(
                          onPressed: (){},
                          onLongPress:(){
                            Navigator.pop(context);
                          },
                          child: const Text('Mark as Done')
                      )
                    ],
                  );
                },
              );
            },
            onPressed: (){
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text(
                      'Add a Measurable Time-bound Milestone',
                      style: TextStyle(color: Colors.black),
                    ),
                    content: TextField(
                      controller: myController,
                      style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w400
                      ),
                    ),
                    actions: [
                      IconButton(
                          onPressed: (){myController.text='';Navigator.pop(context);},
                          icon: const Icon(Icons.close_sharp)
                      ),
                      IconButton(
                        icon: const Icon(Icons.done_outline_sharp),
                        onPressed: (){
                          if(myController.text!='') {
                            widget.goalsMap![widget.goalName]!.add(myController.text);
                            myController.text='';
                            setState((){});
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: Text(
                widget.goalName!,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 1),
            child: createMilestoneWidgets()
          )
        ],
      ),
    );
  }
}

class MyTaskWidget extends StatefulWidget {
  String? myTask;
  Map< String , List<String>? >? goalsMap;
  String? goalName;
  VoidCallback updateState;
  MyTaskWidget({Key? key,this.myTask,this.goalsMap,this.goalName,required this.updateState}) : super(key: key);

  @override
  State<MyTaskWidget> createState() => _MyTaskWidgetState();
}
class _MyTaskWidgetState extends State<MyTaskWidget> {

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (){},
      onLongPress:(){
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Options',style: TextStyle(color: Colors.black),),
              actions: [
                TextButton(
                    onPressed: (){},
                    onLongPress:(){
                      widget.goalsMap![widget.goalName!]!.remove(widget.myTask);
                      widget.updateState();
                      Navigator.pop(context);
                    },
                    child: const Text('Delete milestone')
                ),
                IconButton(
                    onPressed: (){Navigator.pop(context);},
                    icon: const Icon(Icons.close_sharp)
                ),
                TextButton(
                  child: const Text('Mark as done',),
                  onPressed: (){},
                  onLongPress:(){
                      setState((){});
                      Navigator.pop(context);
                  }
                ),
              ],
            );
          },
        );
      },
      style: ElevatedButton.styleFrom(primary: Colors.deepPurpleAccent),
      child: Container(
        alignment: Alignment.centerLeft,
        child: Text(
          widget.myTask!,
          textAlign: TextAlign.start,
        ),
      ),
    );
  }
}

// Database
class KermDatabase {
  Future<Database> openDB()async{
    return openDatabase(
      join(await getDatabasesPath(), 'kermDB.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE goals(id INTEGER PRIMARY KEY, ltg TEXT,stg TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> updateGoalData(Map<String,List<String>?> myGoalsMap)async{
    Database db = await openDB();
    Map<String,dynamic> myMap={'id':0};
    List<String?> ltg=[],stg=[];

    myGoalsMap.forEach((key, value) {
      ltg.add(key);
      if(value!.isEmpty) {
        stg.add('\t');
      } else {
        stg.add(value.join('\t'));
      }
    });

    myMap['ltg']=ltg.join('\n');
    myMap['stg']=stg.join('\n');

    await db.update('goals', myMap,where: 'id = ?',whereArgs: [0]);
  }
  Future< Map< String,List<String>? > > getGoalData() async {
    final db = await openDB();
    Map<String,List<String>?> goalMap={};

    final List<Map<String, dynamic>> dataList = await db.query('goals');
    Map<String, dynamic> dataMap = dataList[0];

    dataMap.forEach((key, value) {
      List<String> ltg = key.split('\n');
      List<String> stg = value.split('\n');
    });

    return goalMap;
  }
}
