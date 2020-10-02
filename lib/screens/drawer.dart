import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class DrawerScreen extends StatefulWidget {
  @override
  _DrawerScreenState createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.blueGrey[800],
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 59.0, horizontal: 9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 45,
              ),
              SizedBox(
                width: 250.0,
                child: ColorizeAnimatedTextKit(
                    repeatForever: true,
                    pause: Duration(milliseconds: 6000),
                    onTap: () {},
                    text: ["DOC ORGANIZER"],
                    textStyle: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Audiowide",
                      //letterSpacing: 0.5,
                    ),
                    colors: [
                      Colors.blue[100],
                      Colors.yellow[100],
                      Colors.red[100],
                    ],
                    textAlign: TextAlign.start,
                    alignment:
                        AlignmentDirectional.topStart // or Alignment.topLeft
                    ),
              ),
              //Text('DOC ORGANIZER',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18),),
              Padding(
                padding: const EdgeInsets.only(left: 27.0),
                child: RotateAnimatedTextKit(
                  repeatForever: true,
                  duration: Duration(milliseconds: 3000),
                  pause: Duration(milliseconds: 0),
                  transitionHeight: 45,
                  onTap: () {},
                  text: ["  MANAGE", "  BROWSE", "ORGANIZE"],
                  textStyle: TextStyle(
                      fontSize: 19.0,
                      fontFamily: 'Fredrick',
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                      letterSpacing: 1),
                  textAlign: TextAlign.center,
                  // alignment: AlignmentDirectional.topStart // or Alignment.topLeft
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton(
                        onPressed: () {
                          Share.share('Download the App here \nbit.ly/myJournalApp');
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.share_outlined,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 7,
                            ),
                            Text(
                              'Share App',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'RedRose',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                  letterSpacing: 0.5),
                            ),
                          ],
                        )),
                    SizedBox(
                      height: 20,
                    ),
                    TextButton(
                        onPressed: null,
                        child: Row(
                          children: [
                            Icon(
                              Icons.feedback_outlined,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 7,
                            ),
                            Text(
                              'Feedback',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'RedRose',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                  letterSpacing: 0.5),
                            ),
                          ],
                        )),
                    SizedBox(
                      height: 20,
                    ),
                    TextButton(
                        onPressed: null,
                        child: Row(
                          children: [
                            Icon(
                              Icons.help_outline,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 7,
                            ),
                            Text(
                              'Help & FAQ',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'RedRose',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                  letterSpacing: 0.5),
                            ),
                          ],
                        )),
                    SizedBox(
                      height: 20,
                    ),
                    TextButton(
                        onPressed: (){
                          const url = 'mailto:naman.jn.dev@gmail.com?subject=Doc Organizer-User&body=';
                          launch(url);
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.mail_outline,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 7,
                            ),
                            Text(
                              'Contact Us',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'RedRose',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                  letterSpacing: 0.5),
                            ),
                          ],
                        )),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 29.0),
                child: Text(
                  'App version 1.0.0',
                  style: TextStyle(color: Colors.blue[100],),textScaleFactor: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
