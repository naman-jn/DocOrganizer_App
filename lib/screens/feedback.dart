import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class UserFeedback extends StatefulWidget {
  @override
  _UserFeedbackState createState() => _UserFeedbackState();
}

class _UserFeedbackState extends State<UserFeedback> {
  final CollectionReference collectionReference =
      FirebaseFirestore.instance.collection('Feedback');
  final FirebaseMessaging _fcm = FirebaseMessaging();

  TextEditingController userName = TextEditingController();
  TextEditingController userFeedback = TextEditingController();
  double userRating = 3;
  var _formKey = GlobalKey<FormState>();

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
              'FeedBack',
              style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 23, letterSpacing: 1),
            ),
            backgroundColor: Colors.blueGrey,
          ),
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: Form(
              key: _formKey,
              child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(15),
                  child: ListView(
                    children: [
                      SizedBox(height: 11),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 11.0),
                        child: SizedBox(
                          child: Image.asset('Assets/feedback.png'),
                        ),
                      ),
                      SizedBox(height: 25),
                      Column(
                        children: [
                          Center(
                              child: Text(
                            'Please rate your experience',
                            textScaleFactor: 1.3,
                          )),
                          SizedBox(height: 15),
                          Center(
                            child: RatingBar(
                              initialRating: 3,
                              minRating: 1,
                              unratedColor: Colors.grey[200],
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemSize: 45,
                              itemPadding:
                                  EdgeInsets.symmetric(horizontal: 4.0),
                              // ignore: missing_return
                              itemBuilder: (context, index) {
                                switch (index) {
                                  case 0:
                                    return Icon(
                                      Icons.sentiment_very_dissatisfied,
                                      color: Colors.red,
                                    );
                                  case 1:
                                    return Icon(
                                      Icons.sentiment_dissatisfied,
                                      color: Colors.orange,
                                    );
                                  case 2:
                                    return Icon(
                                      Icons.sentiment_neutral,
                                      color: Colors.amber,
                                    );
                                  case 3:
                                    return Icon(
                                      Icons.sentiment_satisfied,
                                      color: Colors.lightGreen,
                                    );
                                  case 4:
                                    return Icon(
                                      Icons.sentiment_very_satisfied,
                                      color: Colors.green,
                                    );
                                }
                              },
                              onRatingUpdate: (rating) {
                                userRating = rating;
                              },
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextField(
                              controller: userName,
                              keyboardType: TextInputType.name,
                              maxLines: 1,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                hintText: "Your Name",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(9),
                                  borderSide: BorderSide(
                                      color: Colors.grey[400], width: 1.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(9),
                                  borderSide: BorderSide(
                                      color: Colors.grey[400], width: 1.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(9),
                                  borderSide:
                                      BorderSide(color: Colors.blue[300]),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: TextFormField(
                              controller: userFeedback,
                              keyboardType: TextInputType.multiline,
                              // ignore: missing_return
                              validator: (String value) {
                                if (value.trim().isEmpty) {
                                  return "Feedback field can't be empty";
                                }
                              },
                              maxLines: 6,
                              style: TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                hintText: "Tell us about your experience",
                                errorStyle:
                                    TextStyle(color: Colors.deepOrangeAccent),
                                errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.deepOrangeAccent)),
                                focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.deepOrangeAccent)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(9),
                                  borderSide: BorderSide(
                                      color: Colors.grey[400], width: 1.5),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(9),
                                  borderSide: BorderSide(
                                      color: Colors.grey[400], width: 1.5),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(9),
                                  borderSide:
                                      BorderSide(color: Colors.blue[300]),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 15),
                        child: RaisedButton(
                          onPressed: () {
                            setState(() {
                              if (_formKey.currentState.validate()) {
                                FocusScope.of(context)
                                    .requestFocus(new FocusNode());
                                _add();
                                _showAlertDialog(context);
                                Future.delayed(Duration(milliseconds: 3500),
                                    () {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                });
                              }
                            });
                          },
                          child: Text(
                            'Submit',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                          padding: EdgeInsets.all(11),
                          color: Colors.blueGrey,
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
      "name": userName.text.trim(),
      "rating": userRating,
      "comments": userFeedback.text.trim(),
      'token': fcmToken,
      'createdAt': FieldValue.serverTimestamp(),
    };
    collectionReference
        .add(data)
        .whenComplete(() => null)
        .catchError((e) => print(e));
  }

  void _showAlertDialog(BuildContext context) {
    Dialog dialog = Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'Assets/tick.gif',
              height: 240,
              width: 240,
            ),
            SizedBox(
              width: 250.0,
              child: TypewriterAnimatedTextKit(
                  onTap: () {
                    print("Tap Event");
                  },
                  text: [
                    "Thanks for your feedback",
                  ],
                  textStyle: TextStyle(
                    fontSize: 19.0,
                    fontFamily: "RedRose",
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.start,
                  alignment:
                      AlignmentDirectional.topStart // or Alignment.topLeft
                  ),
            ),
          ],
        ),
      ),
    );
    showDialog(
        context: context,
        builder: (BuildContext context) => dialog,
        barrierDismissible: false);
  }
}
