import 'package:chat_app/pages/signaling.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
class VideoScreen extends StatefulWidget {
  var remoteRenderer;
  var localRenderer;
  var roomId;
  var msgId;
  var chatRoomId;
  final Signaling signaling ;

  VideoScreen({Key? key,required this.chatRoomId,required this.roomId, required this.msgId,required this.localRenderer,required this.remoteRenderer,required this.signaling}) : super(key: key);

  @override
  _VideoScreenState createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: SizedBox(
          child: Expanded(
            child: Column(
              children: [
                Container(
                  height: size.height * 0.45,
                  child: Expanded(child: RTCVideoView(widget.remoteRenderer)),
                ),
                Container(
                  height: size.height * 0.45,
                  child: Expanded(
                    child: RTCVideoView(widget.localRenderer, mirror: true),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                    ),
                    color: Colors.red,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FloatingActionButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            await widget.signaling.hangUp(widget.localRenderer);
                            await FirebaseFirestore.instance
                                .collection("chatrooms")
                                .doc(widget.chatRoomId)
                                .collection("messages")
                                .doc(widget.msgId).delete();
                          },
                          child: const Icon(
                            Icons.phone_disabled,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
