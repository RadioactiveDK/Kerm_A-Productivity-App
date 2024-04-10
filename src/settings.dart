import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

class MySettings extends StatefulWidget {
  const MySettings({Key? key}) : super(key: key);

  @override
  State<MySettings> createState() => _MySettingsState();
}
class _MySettingsState extends State<MySettings> {
  TimeOfDay _time = TimeOfDay.now();
  late TimeOfDay picked;
  DateTime time=DateTime.now();
  @override
  void initState() {
    super.initState();
    getTime();
  }

  Future<void> getTime() async {
    final prefs = await SharedPreferences.getInstance();
    final value =  prefs.getString('endTime')!;
    setState(() {
      time = DateTime.parse(value);
    });
  }

  Future<void> selectTime(BuildContext context) async {
    picked = (await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(time),
    ))!;
    DateTime now =  DateTime.now();
    _time=picked;
    time= DateTime(now.year, now.month, now.day, _time.hour, _time.minute);
    final prefs = await SharedPreferences.getInstance();
    if(scoreList[51+timeInfo.weekday]==9) {
      prefs.setString('endTime', time.toString());
    }
    else{
      time=time.add(const Duration(days: 1));
      prefs.setString('endTime', time.toString());
    }
    // print(time);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              height:80,width: double.infinity,
              child:Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text('Auto-end daily quests at', style: TextStyle(fontSize: 20)),
                  ElevatedButton(
                    onPressed:(){selectTime(context);},
                    child: Text(DateFormat.jm().format(time), style: const TextStyle(fontSize: 20)),
                  ),
                ],  // Children
              ),
            ),
          ],  // Children
        ),
      ),
    );
  }
}
