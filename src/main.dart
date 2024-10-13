import 'package:flutter/material.dart';
import 'package:kerm/goals.dart';
import 'package:kerm/quests.dart';
import 'package:kerm/scores.dart';
import 'package:kerm/settings.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:week_of_year/date_week_extensions.dart';


Map< String, List<String>? > goalsMap = {};
Map< String, String > questList = {};
List< int > scoreList = [];
DateTime timeInfo = DateTime.now();

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
    // print('initialised');
    Database db = await openDB();
    await db.insert('KermData', {'id': 0, 'ltg': 'Add a Goal', 'stg': 'Add a Milestone'}, conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert('KermData', {'id': 1, 'ltg': 'Add a Quest', 'stg': '00'}, conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert('KermData', {'id': 2, 'ltg': '9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9', 'stg': ''}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateGoalData()async{
    Database db = await openDB();
    Map<String,dynamic> myMap={'id':0};
    List<String?> ltg=[],stg=[];
    goalsMap.forEach((key, value) {
      ltg.add(key);
      if(value!.isEmpty) {
        stg.add('Egg');
      } else {
        stg.add(value.join('\t'));
      }
    });

    myMap['ltg']=ltg.join('\n');
    myMap['stg']=stg.join('\n');

    // print(myMap);

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
    // print(dataList);

    Map<String, dynamic> dataMap = dataList[0];
    // print(dataMap);

    List<String>? ltg;
    List<String>? stg;

    ltg = dataMap['ltg'].split('\n');
    stg = dataMap['stg'].split('\n');


    // print(ltg);
    // print(stg);

    for (int i =0; i < ltg!.length ; i++) {
      if(stg![i]!='Egg'){
        goalMap[ltg[i]] = stg[i].split('\t');
      } else {
        goalMap[ltg[i]] = [];
      }
    }

    // print(goalMap);

    return goalMap;
  }

  Future<void> updateQuestData()async{
    Database db = await openDB();
    Map<String,dynamic> myMap = {'id':1};
    // print(questList);

    List<String> ltg = [];
    List<String> stg = [];

    questList.forEach((key, value) {
      ltg.add(key);
      stg.add(value);
    });
    myMap['ltg']=ltg.join('\n');
    myMap['stg']=stg.join('\n');


    // print(myMap);

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

    //(dataList);
    // print(dataMap);

    List<String> ltg = dataMap['ltg'].split('\n');
    List<String> stg = dataMap['stg'].split('\n');

    // print(ltg);
    // print(stg);

    Map<String,String> mp={};

    for(int i=0;i<ltg.length;i++){
      mp[ltg[i]]=stg[i];
    }
    // print(mp);
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

    // print(myMap);

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

    // print(dataList);
    // print(dataMap);

    List<String> ltg = dataMap['ltg'].split('-');
    //(ltg);

    List<int> myList = [];

    for(int i=0;i<ltg.length;i++){
      myList.add( int.parse(ltg[i]) );
    }
    // print(myList);
    return myList;
  }
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  KermDatabase kdb = KermDatabase();

  // await kdb.initialiseDB();

  final prefs = await SharedPreferences.getInstance();

  if( !(await databaseFactory.databaseExists('KermDB.db')) ) {
    await kdb.initialiseDB();
    prefs.setString('endTime', '2023-03-25 23:55:00.000000'); //2023-03-25 00:53:02.110855
    prefs.setInt('year', timeInfo.year);
    prefs.setInt('week', timeInfo.weekOfYear);
    prefs.setBool('isLocked', false);
  }

  goalsMap = await kdb.getGoalData();
  questList = await kdb.getQuestData();
  scoreList = await kdb.getScoreData();
  DateTime endTime = DateTime.parse(prefs.getString('endTime')!);

  if(timeInfo.compareTo(endTime)==1 && prefs.getBool('isLocked')==true){
    double totalMarks = 0;
    double myMarks = 0;
    questList.forEach((key, value) {
      totalMarks = totalMarks + int.parse(value[1]);
      myMarks = myMarks + int.parse(value[1])*int.parse(value[0]);
    });

    if(scoreList[timeInfo.weekday+51]==9){
      prefs.setBool('isLocked', false);
      scoreList[51 + timeInfo.weekday] = totalMarks == 0
          ? 0
          : (myMarks *8 / totalMarks).round();
      //KermDatabase kdb = KermDatabase();
      kdb.updateScoreData();
    }
  }



  if(timeInfo.year!=prefs.getInt('year')){
    var temp = '9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9-9'.split('-');
    for(int i = 0;i<52;i++){
      scoreList[i]=int.parse(temp[i]);
    }
    await kdb.updateScoreData();
    prefs.setInt('year',timeInfo.year);
  }
  if(timeInfo.weekOfYear!=prefs.getInt('week')){
    int weekScore=0;
    for(int i = 0;i<7;i++){
      if(scoreList[52+i]!=9){
        weekScore+=scoreList[52+i];
        scoreList[52+i]=9;
      }
    }
    scoreList[prefs.getInt('week')!-1]=(weekScore/7).round();
    prefs.setInt('week',timeInfo.weekOfYear);
    await kdb.updateScoreData();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kerm',
      theme: ThemeData(colorScheme: const ColorScheme.dark()),
      home: const DefaultTabController(
        length: 3,
        child: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<MyDailyQuestState> childKey = GlobalKey<MyDailyQuestState>();


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
    childKey.currentState?.setState((){});
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Kerm'),
          actions: <Widget>[
            if(!isLocked)TextButton(
              onPressed: (){},
              onLongPress: (){
                // if(true||scoreList[timeInfo.weekday+51]==9) {
                if(scoreList[timeInfo.weekday+51]==9) {
                  DateTime endTime = DateTime.parse(
                      prefs.getString('endTime'));
                  DateTime newTime = DateTime(
                      timeInfo.year, timeInfo.month, timeInfo.day,
                      endTime.hour, endTime.minute);
                  if (scoreList[timeInfo.weekday + 51] == 9) {
                    prefs.setString('endTime', newTime.toString());
                  }
                  else {
                    newTime = newTime.add(const Duration(days: 1));
                    prefs.setString('endTime', newTime.toString());
                  }
                  isLocked = true;
                  questList.forEach((key, value) {
                    questList[key] = '0${value[1]}';
                  });
                  updateQuests();
                  childKey.currentState?.refreshState(true);
                  // Navigator.pop(context);
                }
              },
              child: (scoreList[timeInfo.weekday+51]==9)?
                const Text('Start Quests'):
                const Text('Start Quests',style: TextStyle(color:Colors.red,)),
            )
            else TextButton(
                onPressed: (){},
                onLongPress: (){
                  double totalMarks = 0;
                  double myMarks = 0;
                  questList.forEach((key, value) {
                    totalMarks = totalMarks + int.parse(value[1]);
                    myMarks = myMarks + int.parse(value[1])*int.parse(value[0]);
                  });
                  if(true || scoreList[timeInfo.weekday+51]==9){
                    isLocked=false;
                    scoreList[51 + timeInfo.weekday] = totalMarks == 0
                        ? 0
                        : (myMarks *8 / totalMarks).round();
                    KermDatabase kdb = KermDatabase();
                    kdb.updateScoreData();
                    updateQuests();
                    childKey.currentState?.refreshState(false);
                    // Navigator.pop(context);

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor:Colors.black38),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const MyScores(),
                      ),
                      ),
                    );
                  }
                },
                child: const Text('End Quests')
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(
                child: Text('Daily Quests'),
              ),
              Tab(
                child: Text('Goals'),
              ),
              Tab(
                child: Text('Scores'),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MyDailyQuest(key: childKey),
            const MyGoals(),
            const MyScores(),
          ],
        )
    );
  }
}
