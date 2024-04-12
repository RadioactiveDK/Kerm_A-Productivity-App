
import 'package:flutter/material.dart';
import 'package:kerm/main.dart';
import 'package:week_of_year/week_of_year.dart';

class MyScores extends StatefulWidget {
  const MyScores({Key? key}) : super(key: key);

  @override
  State<MyScores> createState() => _MyScoresState();
}
class _MyScoresState extends State<MyScores> {
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
              padding: const EdgeInsets.all(1),
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
    return Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children: boxes);
  }

  createBoxes(int size,int init){
    var bubbles = <Widget>[];
    for(int i = 0 ; i<size ; i++){
      bubbles.add(
          Padding(
              padding: const EdgeInsets.all(2),
              child: SizedBox(
                height: 45,width: 45,
                child: Center(
                  child: TextButton(
                    onPressed: (){},
                    style: TextButton.styleFrom(backgroundColor: init+7*i==timeInfo.weekOfYear? Colors.blueAccent:setColor(scoreList[init-1+7*i]),),
                    child: Text(
                      (init+7*i).toString(),
                      style: TextStyle(
                          color: scoreList[init-1+7*i]==9?Colors.white:Colors.black,
                          fontWeight: FontWeight.bold,
                          // fontSize: 20
                      ),
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
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Center(child:Text("${timeInfo.year} Scores",style: const TextStyle(fontSize: 50,color: Colors.white),)),

          createWeekBoxes(),

          Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children:createScoreWidgets(7)
          ),
        ]
    );
  }
}
