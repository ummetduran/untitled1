import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:untitled1/quiz_app/ders_ekle.dart';
import 'package:untitled1/quiz_app/student_quiz_page.dart';

import 'model/Ders.dart';
import 'model/Question.dart';
import 'model/Quiz.dart';
FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
class StudentDersPage extends StatefulWidget {
  final Ders ders;

  const StudentDersPage({Key key, this.ders}) : super(key: key);
  @override
  _StudentDersPageState createState() => _StudentDersPageState();
}

class _StudentDersPageState extends State<StudentDersPage> {

  @override
  void initState() {
    //print(widget.ders.name);
    // TODO: implement initState
    fetchQuizzes();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        title: Text(
          widget.ders.name.toString(),
        ),
        backgroundColor: Colors.cyan.shade600,
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              child: Expanded(
                child: ListView.builder(itemBuilder: listeElemaniOlustur,
                  itemCount: widget.ders.quizList.length ,
                ),
              ),
            ),



          ],
        ),
      ),
    );
  }

  Future fetchQuizzes() async {
    widget.ders.quizList.clear();
    String teacherId = widget.ders.teacher.id;
    String dersId = widget.ders.name;

    var quizler =  await _fireStore.collection("Users").doc(teacherId).collection("dersler")
        .doc(dersId).collection("quizler");
    quizler.snapshots().listen((event) async {
      for(var element in event.docs) {
        Quiz quiz = new Quiz();
        quiz.quizName = element.id;
        quiz.startDate = element.get("startDate");
        quiz.time = element.get("zaman");

        var dbQuestions = await _fireStore.collection("Users").doc(teacherId).collection("dersler")
            .doc(dersId).collection("quizler").doc(element.id).collection("sorular");
        dbQuestions.snapshots().listen((event) {
          for(var element in event.docs) {

            Question q = new Question();
            q.question = element.get("question");
            q.answer = element.get("dogruCevap");
            q.point= element.get("point");
            q.imagePath = element.get("imagePath");

            q.options.clear();
            List qOptions = element.get("cevaplar");
            for(var element in qOptions){
              q.options.add(element.toString());
            }//her seçenek için
            quiz.addQuestion(q);
          }//her soru için


          });

        setState(() {
          widget.ders.quizList.add(quiz);
        });
        }

        });
  }

  Widget listeElemaniOlustur(BuildContext context, int index) {
    Color colorL;
    String entryText;
    DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm");
    DateTime quizStartDate = dateFormat.parse(widget.ders.quizList[index].startDate);
    DateTime quizEndDate = quizStartDate.add(Duration(minutes: widget.ders.quizList[index].time));
    if( (DateTime.now().isAfter(quizStartDate)) && DateTime.now().isBefore(quizEndDate)){
      colorL = Colors.tealAccent[700];
      entryText = "Enter!";
    }
    else if(DateTime.now().isAfter(quizEndDate) || widget.ders.quizList[index].hasSolved == true){
      colorL = Colors.redAccent[700];
      entryText = "Finished!";
    }

    else {
      colorL = Colors.orangeAccent[700];
      entryText = "Please wait!";
    }
      return SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
                color: colorL,
                border: Border.all(width: 2),
                borderRadius: BorderRadius.circular(20)),
            margin: EdgeInsets.all(5),
            child: ListTile(
              onTap: () {
                if(entryText=="Enter!"){
                Navigator.push(context, MaterialPageRoute( builder: (context) => StudentQuizPage(quiz: widget.ders.quizList[index], ders: widget.ders)));

                }
                else showAlertDialog(context);
              },

              title: Text(widget.ders.quizList[index].quizName, style: TextStyle(color: Colors.white),),
              subtitle: Text(entryText,style: TextStyle(color: Colors.white),),


            ),
          ));
    }



  void showAlertDialog(BuildContext context) {
     AlertDialog alert  = AlertDialog(
      content: Text("Quiz has not started or time is up!"),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop('dialog');
            // Navigator.pop(context, 'OK');
           // Navigator.push(context, MaterialPageRoute( builder: (context) => StudentDersPage(ders: widget.ders,)));
          },
          child: const Text('OK'),
        ),
      ],
    );
     showDialog(
       context: context,
       builder: (BuildContext context) {
         return alert;
       },

     );
  }


}

