import 'package:flutter/material.dart';

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
        iconTheme: const IconThemeData(color: Colors.black,),
        appBarTheme: const AppBarTheme(
          color: Colors.white,
          titleTextStyle: TextStyle(color: Colors.black),
          iconTheme: IconThemeData(color: Colors.black,),
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
        title: const Text('Kerm',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 25),),
        actions: <Widget> [
          IconButton(
            onPressed: (){
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
            Tab(child: Text('Daily Quest',style: TextStyle(color: Colors.black),),),
            Tab(child: Text('Goals',style: TextStyle(color: Colors.black),),),
          ],
        ),
      ),
      body: const TabBarView(
        children: [
          MyDailyQuest(),
          MyGoals(),
        ],
      )
    );
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
        title: const Text('Settings',style: TextStyle(color: Colors.black),),
        leading: BackButton(
          onPressed: (){
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(

      ),
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
          children: const [
            Text('data')
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){},
        backgroundColor: Colors.black54,
        child: const Icon(Icons.add,color: Colors.white,size: 50,),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(child: Text('hiiiiii'),),
    );
  }
}
