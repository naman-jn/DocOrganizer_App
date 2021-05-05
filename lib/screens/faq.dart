import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class FAQ extends StatefulWidget {
  @override
  _FAQState createState() => _FAQState();
}

class _FAQState extends State<FAQ> with TickerProviderStateMixin {
  final CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('FAQ');

  final CollectionReference questionReference =
      FirebaseFirestore.instance.collection('userFAQ');
  final FirebaseMessaging _fcm = FirebaseMessaging();

  TextEditingController userQuestion = TextEditingController();
  TextEditingController userEmail = TextEditingController();
  var _formKey = GlobalKey<FormState>();

  bool isAsking = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WillPopScope(
        // ignore: missing_return
        onWillPop: () {
          Navigator.pop(context);
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            centerTitle: true,
            title: Text(
              'FAQs',
              style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 23, letterSpacing: 1),
            ),
            backgroundColor: Colors.blue[300],
          ),
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: Form(
              key: _formKey,
              child: Container(
                  color: Colors.grey[100],
                  padding: EdgeInsets.all(5),
                  child: ListView(
                    children: [
                      SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 11.0),
                        child: SizedBox(
                          child: Image.asset('Assets/faq.png'),
                          height: 120,
                        ),
                      ),
                      SizedBox(height: 15),
                      Container(
                        height: isAsking ? 252 : 400,
                        child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection("FAQ")
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Text(
                                  'No Data...',
                                );
                              } else {
                                //<DocumentSnapshot> items = snapshot.data.documents;
                                return ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: snapshot.data.documents.length,
                                    itemBuilder: (context, index) {
                                      DocumentSnapshot ds =
                                          snapshot.data.documents[index];
                                      return Card(
                                        child: ExpansionTile(
                                          title: Row(
                                            children: [
                                              Icon(
                                                Icons.question_answer_outlined,
                                                size: 21,
                                                color: Colors.black87,
                                              ),
                                              SizedBox(
                                                width: 15,
                                              ),
                                              Expanded(
                                                  child: Text(ds["question"],
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 14,
                                                      ))),
                                            ],
                                          ),
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5.0,
                                                      horizontal: 15),
                                              child: Text(
                                                ds["answer"],
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      );
                                    });
                              }
                            }),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 15,
                            ),
                            Center(
                                child: Text(
                              'Still have a question?',
                              style: TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 18),
                            )),
                            SizedBox(
                              height: 3,
                            ),
                            if (!isAsking)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 15),
                                child: RaisedButton(
                                  onPressed: () {
                                    setState(() {
                                      isAsking = true;
                                    });
                                  },
                                  child: Text(
                                    'Ask here',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 15),
                                  ),
                                  padding: EdgeInsets.all(11),
                                  color: Colors.blue[400],
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(9)),
                                ),
                              ),
                            if (isAsking)
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 9),
                                    child: CustomTextField(
                                        controller: userEmail,
                                        hintText: "Your email"),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0, vertical: 9),
                                    child: CustomTextField(
                                        controller: userQuestion,
                                        hintText: "Your question"),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      if (isAsking)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 15),
                          child: RaisedButton(
                            onPressed: () {
                              setState(() {
                                if (_formKey.currentState.validate()) {
                                  _add();
                                  isAsking = false;
                                  _showAlertDialog(context);
                                }
                              });
                            },
                            child: Text(
                              'Submit',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                            padding: EdgeInsets.all(11),
                            color: Colors.blue[300],
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7)),
                          ),
                        ),
                    ],
                  )),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _add() async {
    String fcmToken = await _fcm.getToken();

    Map<String, dynamic> data = {
      "userEmail": userEmail.text.trim(),
      "userQuestion": userQuestion.text.trim(),
      'token': fcmToken,
      'createdAt': FieldValue.serverTimestamp(),
    };
    questionReference
        .add(data)
        .whenComplete(() => () {
              userQuestion.clear();
              userEmail.clear();
            })
        .catchError((e) => print(e));
  }

  void _showAlertDialog(BuildContext context) {
    Dialog dialog = Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Question Submitted',
              style: TextStyle(
                fontSize: 25.0,
                letterSpacing: 1,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 9,
            ),
            Text(
              'Your query will be resolved via email at the earliest',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white,
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
    showDialog(
        context: context,
        builder: (BuildContext context) => dialog,
        barrierDismissible: false);
    Future.delayed(Duration(milliseconds: 4300), () {
      Navigator.pop(context);
    });
  }
}

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    Key key,
    @required this.controller,
    @required this.hintText,
  }) : super(key: key);

  final TextEditingController controller;
  final String hintText;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.multiline,
      // ignore: missing_return
      validator: (String value) {
        if (value.trim().isEmpty) {
          return "Invalid Entry";
        }
      },
      maxLines: hintText == "Your email" ? 1 : 3,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hintText,
        errorStyle: TextStyle(color: Colors.deepOrangeAccent),
        errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepOrangeAccent)),
        focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepOrangeAccent)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: BorderSide(color: Colors.grey[400], width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: BorderSide(color: Colors.grey[400], width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(9),
          borderSide: BorderSide(color: Colors.blue[300]),
        ),
      ),
    );
  }
}
