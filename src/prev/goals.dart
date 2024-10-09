// Goals tab
import 'package:flutter/material.dart';
import 'main.dart';

class MyGoals extends StatefulWidget {
  const MyGoals({Key? key}) : super(key: key);

  @override
  State<MyGoals> createState() => _MyGoalsState();
}
class _MyGoalsState extends State<MyGoals> {
  // Map< String , List<String>? > goalsMap = {};

  void updateGoals()async{
    KermDatabase kdb = KermDatabase();
    await kdb.updateGoalData();
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.add,),
          onPressed: (){
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text(
                    'Add a Long-term Goal'
                  ),
                  content: TextField(
                    controller: myController,
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
          SizedBox(
              width: double.infinity,
              child: MyMilestones(
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

  goalColor(String goalName){
    if(goalsMap[goalName]!.isEmpty) {
      return Colors.grey;
    } else{
      if(goalsMap[goalName]!.firstWhere((element) => element[0]!='!',orElse: ()=>'0')=='0') {
        return Colors.grey;
      } else {
        return Colors.yellowAccent;
      }
    }
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
      // decoration: BoxDecoration(
      //   color: goalColor(widget.goalName!),
      //   borderRadius: BorderRadius.circular(10),
      // ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            // style: TextButton.styleFrom(
            //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            //   backgroundColor:  Colors.black54,
            //   textStyle: const TextStyle(fontSize: 20,fontWeight: FontWeight.bold)
            // ),
            onPressed: (){
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text(
                      'Add a Measurable Time-bound Milestone',
                    ),
                    content: TextField(
                      controller: myController
                    ),
                    actions: [
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
            child: Text(widget.goalName!),
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

class MyMilestones extends StatefulWidget {
  String? myTask;
  Map< String , List<String>? >? goalsMap;
  String? goalName;
  VoidCallback updateState;
  MyMilestones({Key? key,this.myTask,this.goalsMap,this.goalName,required this.updateState}) : super(key: key);

  @override
  State<MyMilestones> createState() => _MyMilestonesState();
}
class _MyMilestonesState extends State<MyMilestones> {

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: (){
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Options'),
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
                      if(widget.myTask![0] != '!')TextButton(
                          child: const Text('Achieved',),
                          onPressed: (){},
                          onLongPress:(){
                            goalsMap[widget.goalName]![goalsMap[widget.goalName]!.indexOf(widget.myTask!)]='! ${widget.myTask}';
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
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: (widget.myTask![0]=='!')?Colors.black54:Colors.orange,
        shadowColor: Colors.cyanAccent,
        elevation: 7,
      ),
      child: Container(
        alignment: Alignment.centerLeft,
        child: Text(
          widget.myTask!,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
