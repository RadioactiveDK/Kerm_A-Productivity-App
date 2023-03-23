import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:week_of_year/date_week_extensions.dart';

Map< String, List<String>? > goalsMap = {};
Map< String, String > questList = {};
List< int > scoreList = [];

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  KermDatabase kdb = KermDatabase();
  // await kdb.initialiseDB();

  if( !(await databaseFactory.databaseExists('KermDB.db')) ) {
    await kdb.initialiseDB();
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLocked', false);
  }

  goalsMap = await kdb.getGoalData();
  questList = await kdb.getQuestData();
  scoreList = await kdb.getScoreData();

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
        length: 3,
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
              Tab(
                child: Text(
                  'Scores',
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
            MyScores(),
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
  bool isLocked = false;

  @override
  void initState(){
    super.initState();
    loadBool();
  }

  Future<void> loadBool() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isLocked = prefs.getBool('isLocked')!;
    });
  }

  void updateQuests()async{
    KermDatabase kdb = KermDatabase();
    await kdb.updateQuestData();
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLocked', isLocked);
    setState(() {});
  }
  updateState(){
    return ()=>updateQuests();
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
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          child: const Icon(Icons.add,color: Colors.black,size: 25,),
          onPressed: (){
            showDialog(
              context: context,
              builder: (context) {
                DateTime timeInfo = DateTime.now();
                return AlertDialog(
                  title: const Text(
                    'Manage your Quests',
                    style: TextStyle(color: Colors.black),
                  ),
                  content: !isLocked ? TextField(
                    controller: myController,
                    style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w400
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Add a Quest',
                    ),
                  ):const Text('End Quests',style: TextStyle(color: Colors.black),),
                  actions: [
                    if(!isLocked)TextButton(
                      onPressed: (){},
                      onLongPress: (){
                        isLocked = true;
                        questList.forEach((key, value) {questList[key] ='0${value[1]}';});
                        DateTime timeInfo = DateTime.now();
                        if(timeInfo.weekday==7 && scoreList[58]!=9){
                          int weekScore=0;
                          for(int i = 0;i<7;i++){
                            if(scoreList[52+i]!=9) {
                                weekScore += scoreList[52 + i];
                                scoreList[52 + i] = 9;
                            }
                          }
                          if(timeInfo.isLeapYear){
                            if(timeInfo.month!=1 || (timeInfo.day!= 1 && timeInfo.day!=2)){
                              scoreList[timeInfo.weekOfYear]=(weekScore/7).round();
                            }
                          } else {
                            if(timeInfo.month!=1 || timeInfo.day!= 1){
                              print(timeInfo.weekOfYear);
                              scoreList[timeInfo.weekOfYear-1]=(weekScore/7).round();
                            }
                          }
                        }
                        KermDatabase kdb = KermDatabase();
                        kdb.updateScoreData();
                        updateQuests();
                        Navigator.pop(context);
                      },
                      child: const Text('Start Quests'),
                    ),
                    if(isLocked)TextButton(
                        onPressed: (){},
                        onLongPress: (){
                          double totalMarks = 0;
                          double myMarks = 0;
                          questList.forEach((key, value) {
                            totalMarks = totalMarks + int.parse(value[1]);
                            myMarks = myMarks + int.parse(value[1])*int.parse(value[0]);
                          });
                            if(scoreList[timeInfo.weekday+51]==9){
                              isLocked=false;
                              scoreList[51 + timeInfo.weekday] = totalMarks == 0
                                  ? 0
                                  : (myMarks * 8 / totalMarks).round();
                              updateQuests();
                              KermDatabase kdb = KermDatabase();
                              kdb.updateScoreData();
                            }
                            Navigator.pop(context);
                        },
                        child: Text('End Quests',style: TextStyle(color: scoreList[timeInfo.weekday+51]==9?Colors.blue:Colors.red,)
                        )
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
      onPressed: (){},
      onLongPress:(){
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Options',style: TextStyle(color: Colors.black),),
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
                    if(widget.isLocked )TextButton(
                        child: (questList[widget.questName]![0]=='0')?const Text('Mark as done'):const Text('Mark as undone'),
                        onPressed: (){},
                        onLongPress:(){
                          (questList[widget.questName]![0]=='0')?
                            questList[widget.questName]='1${questList[widget.questName]![1]}':
                          questList[widget.questName]='0${questList[widget.questName]![1]}';
                          widget.updateState();
                          Navigator.pop(context);
                        }
                    ),
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
      },
      style: ElevatedButton.styleFrom(
        primary: questList[widget.questName]![0] == '0' ?Colors.tealAccent:Colors.grey,
        shadowColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0)
        ),
      ),
      child: Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.all(5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.questName,textAlign: TextAlign.start,style: const TextStyle(color: Colors.black)),
          DropdownButton<String>(
            value: questList[widget.questName]![1],
            icon: const Icon(Icons.arrow_drop_down),
            elevation: 16,
            style: const TextStyle(color: Colors.deepPurple),
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
            onChanged: widget.isLocked? null:(String? value) {
              questList[widget.questName] = questList[widget.questName]![0] + value!;
              widget.updateState();
            },
            items: ['0','1','2','3','4','5'].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          )
          ]
        ),
      ),
    ));
  }
}





// Goals tab
class MyGoals extends StatefulWidget {
  const MyGoals({Key? key}) : super(key: key);

  @override
  State<MyGoals> createState() => _MyGoalsState();
}
class _MyGoalsState extends State<MyGoals> {
  // Map< String , List<String>? > goalsMap = {};

  void updateGoals()async{
    KermDatabase kdb = KermDatabase();
    await kdb.updateGoalData(goalsMap);
    setState(() {});
  }
  updateState(){
    return ()=>updateGoals();
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

  final myController = TextEditingController();
  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.add,color: Colors.black,),
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
    for (var element in widget.milestones!) {
      milestoneWidgets.add(
          Container(
              width: double.infinity,
              child: MyTaskWidget(
                myTask: element,
                goalsMap: widget.goalsMap,
                updateState: widget.updateState,
                goalName: widget.goalName,
              )
          )
      );
    }
    return Column(children: milestoneWidgets);
  }

  final myController = TextEditingController();
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
            style: TextButton.styleFrom(primary:Colors.black,textStyle: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:[
                          TextButton(
                            onPressed:(){},
                            onLongPress: (){
                              widget.goalsMap!.remove(widget.goalName);
                              myController.text='';
                              if(widget.goalsMap!.isEmpty)goalsMap['Add a Goal']=['Add a Milestone'];
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
                          child: const Text('Achieved')
                      )
                        ],
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
                            widget.updateState();
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                        onPressed: (){},
                        onLongPress:(){
                          widget.goalsMap![widget.goalName!]!.remove(widget.myTask);
                          widget.updateState();
                          Navigator.pop(context);
                        },
                        child: const Text('Delete Milestone')
                    ),
                    IconButton(
                        onPressed: (){Navigator.pop(context);},
                        icon: const Icon(Icons.close_sharp)
                    ),
                    TextButton(
                        child: const Text('Achieved',),
                        onPressed: (){},
                        onLongPress:(){
                          widget.updateState();
                          Navigator.pop(context);
                        }
                    ),
                  ]
                )
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





// History
class MyScores extends StatefulWidget {
  const MyScores({Key? key}) : super(key: key);

  @override
  State<MyScores> createState() => _MyScoresState();
}
class _MyScoresState extends State<MyScores> {
  DateTime timeInfo = DateTime.now();
  setColor(int score){
    if(score<=1) {
      return Colors.red;
    }
    else if(score == 2){
      return Colors.amber[900];
    }
    else if(score == 3){
      return Colors.orange;
    }
    else if(score == 4){
      return Colors.yellow;
    }
    else if(score == 5){
      return Colors.lime;
    }
    else if(score == 6){
      return Colors.lightGreen;
    }
    else if(score == 7){
      return Colors.greenAccent[700];
    }
    else if(score == 8){
      return const Color.fromARGB(255, 0, 255, 0);
    }
    else if(score == 9){
      return Colors.black;
    }
  }
  createWeekBoxes(){
    var boxes = <Widget>[];
    List<String> week = ['M','T','W','T','F','S','S'];
    for(int i =0 ;i<7;i++) {
      boxes.add(
          Padding(
              padding: const EdgeInsets.all(4),
              child: Container(
                height: 45,width: 45,
                decoration: BoxDecoration(
                    color: setColor(scoreList[52+i]),
                    borderRadius: BorderRadius.circular(23)
                ),
                child: Center(
                  child:Text(week[i],style: TextStyle(color: scoreList[52+i]==9?Colors.white:Colors.black,fontWeight: FontWeight.bold,fontSize: 20),),
                )
              )
          )
      );
    }
    return Row(mainAxisAlignment:MainAxisAlignment.spaceEvenly,children: boxes);
  }

  createBoxes(int size,int init){
    var bubbles = <Widget>[];
    for(int i = 0 ; i<size ; i++){
      bubbles.add(
        Padding(
          padding: const EdgeInsets.all(4),
          child: Container(
            height: 45,width: 45,
            decoration: BoxDecoration(
                color: setColor(scoreList[init-1+7*i]),
                // gradient: scoreList[init-1+7*i]==9 ? const RadialGradient(
                //   colors: [Colors.white, Colors.black],
                //   radius: 0.75,
                // ):null,
                borderRadius: BorderRadius.circular(10)
            ),
            child: Center(
              child: Text(
                (init+7*i).toString(),
                style: TextStyle(
                    color: scoreList[init-1+7*i]==9?Colors.white:Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                ),
              ),
            ),
          )
        )
      );
    }
    return bubbles;
  }
  createScoreWidgets(int size){
    var scoreWidgets = <Widget>[];
    for(int i = 1;i<=size;i++) {
      scoreWidgets.add(
        Column(
          children: createBoxes((i<=3)?8:7,i)
        )
      );
    }
    return scoreWidgets;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Center(child:Text(timeInfo.year.toString(),style: const TextStyle(fontSize: 50,color: Colors.white),)),
          Container(child:Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:createScoreWidgets(7)
          )),
          createWeekBoxes()
        ]
      )
    );
  }
}

// Database
class KermDatabase {
  Future<Database> openDB()async{
    return openDatabase(
      join(await getDatabasesPath(), 'KermDB.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE KermData(id INTEGER PRIMARY KEY, ltg TEXT, stg TEXT)',
        );
      },
      version: 1,
    );
  }

  Future<void> initialiseDB()async{
    print('initialised');
    Database _db = await openDB();
    await _db.insert('KermData', {'id': 0, 'ltg': 'Add a Goal', 'stg': 'Add a Milestone'}, conflictAlgorithm: ConflictAlgorithm.replace);
    await _db.insert('KermData', {'id': 1, 'ltg': 'Add a Quest', 'stg': '00'}, conflictAlgorithm: ConflictAlgorithm.replace);
    await _db.insert('KermData', {'id': 2, 'ltg': '9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9', 'stg': ''}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateGoalData(Map<String,List<String>?> myGoalsMap)async{
    Database db = await openDB();
    Map<String,dynamic> myMap={'id':0};
    List<String?> ltg=[],stg=[];

    myGoalsMap.forEach((key, value) {
      ltg.add(key);
      if(value!.isEmpty) {
        stg.add('Egg');
      } else {
        stg.add(value.join('-'));
      }
    });

    myMap['ltg']=ltg.join('\n');
    myMap['stg']=stg.join('\n');

    print(myMap);

    await db.update(
      'KermData',
      myMap,
      where: 'id = ?',
      whereArgs: [0],
    );
  }
  Future< Map< String,List<String>? > > getGoalData() async {
    final db = await openDB();
    Map<String,List<String>?> goalMap={};

    final List<Map<String, dynamic>> dataList = await db.query('KermData');
    print(dataList);

    Map<String, dynamic> dataMap = dataList[0];
    print(dataMap);

    List<String>? ltg;
    List<String>? stg;

    ltg = dataMap['ltg'].split('\n');
    stg = dataMap['stg'].split('\n');


    print(ltg);
    print(stg);

    for (int i =0; i < ltg!.length ; i++) {
      if(stg![i]!='Egg'){
        goalMap[ltg[i]] = stg[i].split('-');
      } else {
        goalMap[ltg[i]] = [];
      }
    }

    print(goalMap);

    return goalMap;
  }

  Future<void> updateQuestData()async{
    Database db = await openDB();
    Map<String,dynamic> myMap = {'id':1};

    print(questList);

    List<String> ltg = [];
    List<String> stg = [];

    questList.forEach((key, value) {
      ltg.add(key);
      stg.add(value);
    });
    myMap['ltg']=ltg.join('\n');
    myMap['stg']=stg.join('\n');


    print(myMap);

    await db.update(
      'KermData',
      myMap,
      where: 'id = ?',
      whereArgs: [1],
    );
  }
  Future< Map<String,String> > getQuestData() async {
    final db = await openDB();

    final List<Map<String, dynamic>> dataList = await db.query('KermData');
    Map<String, dynamic> dataMap = dataList[1];

    print(dataList);
    print(dataMap);

    List<String> ltg = dataMap['ltg'].split('\n');
    List<String> stg = dataMap['stg'].split('\n');

    print(ltg);
    print(stg);

    Map<String,String> mp={};

    for(int i=0;i<ltg.length;i++){
      mp[ltg[i]]=stg[i];
    }
    print(mp);
    return mp;
  }

  Future<void> updateScoreData()async{
    Database db = await openDB();
    Map<String,dynamic> myMap={'id':2,'stg':''};
    List<String> ltg=[];

    for(var i in scoreList){
      ltg.add(i.toString());
    }

    myMap['ltg']=ltg.join('-');

    print(myMap);

    await db.update(
      'KermData',
      myMap,
      where: 'id = ?',
      whereArgs: [2],
    );
  }
  Future< List<int> > getScoreData() async {
    final db = await openDB();

    final List<Map<String, dynamic>> dataList = await db.query('KermData');
    Map<String, dynamic> dataMap = dataList[2];

    print(dataList);
    print(dataMap);

    List<String> ltg = dataMap['ltg'].split('-');
    print(ltg);

    List<int> myList = [];

    for(int i=0;i<ltg.length;i++){
      myList.add( int.parse(ltg[i]) );
    }
    print(myList);
    return myList;
  }
}
