import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPage extends StatefulWidget {
  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  final CollectionReference videosCollection =
      FirebaseFirestore.instance.collection('videos');
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
              'How to Videos',
              style: TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 23, letterSpacing: 1),
            ),
            backgroundColor: Colors.blue[300],
          ),
          body: Container(
            padding: EdgeInsets.all(15),
            child: StreamBuilder(
                stream: videosCollection.orderBy("number").snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else {
                    QuerySnapshot querySnapshot = snapshot.data;
                    return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data.documents.length,
                        itemBuilder: (context, index) {
                          Map videoData = querySnapshot.docs[index].data();
                          String videoId =
                              YoutubePlayer.convertUrlToId(videoData['url']);
                          YoutubePlayerController _playerController =
                              YoutubePlayerController(
                            initialVideoId: videoId, //Add videoID.
                            flags: YoutubePlayerFlags(
                              hideControls: false,
                              controlsVisibleAtStart: true,
                              autoPlay: false,
                              mute: false,
                              forceHD: true,
                            ),
                          );
                          _playerController.fitHeight(Size.fromHeight(100));
                          return Container(
                            margin: EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        videoData['number'].toString() +
                                            '. ' +
                                            videoData['title'],
                                        style: TextStyle(
                                          fontFamily: 'RedRose',
                                          letterSpacing: 0.3,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Spacer(),
                                      InkWell(
                                        onTap: () {
                                          launch(videoData['url']);
                                        },
                                        child: Row(
                                          children: [
                                            Text(
                                              'Open with',
                                              style: TextStyle(
                                                fontSize: 12,
                                              ),
                                            ),
                                            Image.asset(
                                              "Assets/youtube.png",
                                              height: 24,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                YoutubePlayer(
                                    controller: _playerController,
                                    showVideoProgressIndicator: true,
                                    bottomActions: [
                                      const SizedBox(width: 14.0),
                                      CurrentPosition(),
                                      const SizedBox(width: 8.0),
                                      ProgressBar(
                                        isExpanded: true,
                                      ),
                                      RemainingDuration(),
                                      const PlaybackSpeedButton(),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10.0, top: 3),
                                        child: InkWell(
                                          onTap: () {
                                            launch(videoData['url']);
                                          },
                                          child: Image.asset(
                                            "Assets/youtube_icon.png",
                                            height: 20,
                                          ),
                                        ),
                                      ),
                                    ]),
                              ],
                            ),
                          );
                        });
                  }
                }),
          ),
        ),
      ),
    );
  }
}
