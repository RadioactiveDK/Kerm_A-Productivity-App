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
                  'Daily Quest',
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

class MyDailyQuest extends StatefulWidget {
  const MyDailyQuest({Key? key}) : super(key: key);

  @override
  State<MyDailyQuest> createState() => _MyDailyQuestState();
}
class _MyDailyQuestState extends State<MyDailyQuest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(7),
        child: Column(
          children: const [Text('data')],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.black54,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 50,
        ),
      ),
    );
  }
}

class MyGoals extends StatefulWidget {
  const MyGoals({Key? key}) : super(key: key);

  @override
  State<MyGoals> createState() => _MyGoalsState();
}
class _MyGoalsState extends State<MyGoals> {
  Map< String , List<String>? > goalsMap = {
    'Getting Started':[
      'Add your Long-term goals using the \'+\' button',
      'Add Short-term goals by tapping on Long-term goals'
    ]
  };

  void updateGoals() {
    setState(() {});
  }
  createGoalWidgets(){
    var goalWidgets = <Widget>[];
    goalsMap.forEach((key, value) {
      goalWidgets.add(MyTaskCard(taskName: key,));
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
                      onPressed: (){Navigator.pop(context);},
                      icon: const Icon(Icons.delete)
                  ),
                  IconButton(
                    icon: const Icon(Icons.done_outline_sharp),
                    onPressed: (){
                      if(myController.text!='' && goalsMap[myController.text]==null) {
                        goalsMap[myController.text]=[];
                      }
                      updateGoals();
                      Navigator.pop(context);
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
class MyTaskCard extends StatelessWidget {
  final String? taskName, desc;

  MyTaskCard({this.taskName, this.desc});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white30,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            taskName ?? 'Untitled Task',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Text(
              desc ?? 'Description',
              style: const TextStyle(fontWeight: FontWeight.w300),
            ),
          )
        ],
      ),
    );
  }
}

class KermDatabase {
  Future<Database> myDB()async{
    return openDatabase(
      join(await getDatabasesPath(), 'kermDB.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE goals(id INTEGER PRIMARY KEY, ltg TEXT, stg LIST<INTEGER>)',
        );
      },
    );
  }

  Future<void> updateGoals(Map<String,List<String>> myGoalsMap)async{
    Database mydb = await myDB();
    await mydb.update('goals', myGoalsMap);
  }
}


///////////////waste
class MyTaskEditor extends StatefulWidget {
  const MyTaskEditor({Key? key}) : super(key: key);

  @override
  State<MyTaskEditor> createState() => _MyTaskEditorState();
}
class _MyTaskEditorState extends State<MyTaskEditor> {
  KermDatabase mydb = KermDatabase();







  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: (){

            },
            icon: const Icon(Icons.done_outline_sharp),
          ),
        ],
        title: const TextField(
          decoration: InputDecoration(
              hintText: 'Long term goal',
              hintStyle: TextStyle(
                  fontWeight: FontWeight.w400, color: Colors.black38
              ),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
              )
          ),
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        child: const TextField(
          decoration: InputDecoration(
              hintText: 'Short term goals',
              hintStyle: TextStyle(
                  fontWeight: FontWeight.w400, color: Colors.white30
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              )
          ),
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
