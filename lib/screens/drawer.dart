import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:document_organizer/screens/videos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'faq.dart';
import 'feedback.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';

class DrawerScreen extends StatefulWidget {
  @override
  _DrawerScreenState createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
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
                    text: ["Doc Organizer"],
                    textStyle: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Audiowide",
                      letterSpacing: 0.9,
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
                      fontFamily: 'Acme',
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
                        onPressed: () async {
                          Navigator.push(
                              context, ScaleRoute(page: VideoPage()));
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.ondemand_video_outlined,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 7,
                            ),
                            Text(
                              'How to Videos',
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
                        onPressed: () async {
                          final ByteData bytes =
                              await rootBundle.load('Assets/doc_organizer.png');
                          await Share.file('Doc Organizer', 'DocOrganizer.png',
                              bytes.buffer.asUint8List(), 'image/png',
                              text:
                                  'This app has helped me organize my documents conveniently. Do check out the App here \nbit.ly/DocOrganizer');
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
                        onPressed: () {
                          Navigator.push(
                              context, ScaleRoute(page: UserFeedback()));
                        },
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
                        onPressed: () {
                          Navigator.push(context, ScaleRoute(page: FAQ()));
                        },
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
                        onPressed: () {
                          const url =
                              'mailto:naman.jn.dev@gmail.com?subject=Doc Organizer-User&body=';
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
                  'App version 2.0.1',
                  style: TextStyle(
                    color: Colors.blue[100],
                  ),
                  textScaleFactor: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ScaleRoute extends PageRouteBuilder {
  @override
  Duration get transitionDuration => const Duration(milliseconds: 900);

  final Widget page;
  ScaleRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              ScaleTransition(
            scale: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.fastOutSlowIn,
              ),
            ),
            child: child,
          ),
        );
}
