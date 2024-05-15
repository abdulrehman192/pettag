import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:pettag/screens/my_map.dart';
import 'package:pettag/utilities/firebase_credentials.dart';

import '../constant.dart';
import 'app_colors.dart';
import 'controller/chat_controller.dart';
import 'repo/route_argument.dart';

class Chat extends StatefulWidget {
  static const String petChatScreenRoute = 'PetChatScreen';
  final RouteArgument routeArgument;

  const Chat({Key? key, required this.routeArgument}) : super(key: key);

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> with TickerProviderStateMixin {
  AnimationController? _controller;
  String? userId;
  num? userLat;
  num? userLng;

  getSharedLocationStatus() async {
    userId = FirebaseCredentials().auth.currentUser!.uid;
    FirebaseFirestore.instance
        .collection("User")
        .doc(userId)
        .snapshots()
        .listen((value) {
      if (value.data()!.containsKey("isLocationShared")) {
        if (value.data()!["isLocationShared"]) {
          setState(() {
            _controller!.repeat();
          });
        }
      }
      userLat = value.data()!['latitude'];
      userLng = value.data()!['longitude'];
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    getSharedLocationStatus();
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 1.0,
        backgroundColor: mainColor,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            borderRadius: const BorderRadius.all(Radius.circular(25.0)),
            clipBehavior: Clip.hardEdge,
            child: widget.routeArgument.param2 == 'default'
                ? const CircleAvatar(
                    backgroundColor: Colors.white,
                  )
                : CachedNetworkImage(
                    placeholder: (context, url) => Container(
                      padding: const EdgeInsets.all(15.0),
                      child: const CircularProgressIndicator(
                        strokeWidth: 1.0,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryColor),
                      ),
                    ),
                    imageUrl: widget.routeArgument.param2,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
        title: Text(
          widget.routeArgument.param3,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return MyMap(
                        isVisible: true,
                        isChatSide: true,
                        peerId: widget.routeArgument.param1,
                      );
                    }),
                  );
                },
                child: const Center(
                  child: Text(
                    "Find Nearest Park",
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              )),
        ],
      ),
      body: ChatScreen(
        peerId: widget.routeArgument.param1.toString(),
        peerAvatar: widget.routeArgument.param2.toString(),
        peerName: widget.routeArgument.param3.toString(),
        peerPetId: widget.routeArgument.param4.toString(),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerAvatar;
  final String peerName;
  final String peerPetId;

  const ChatScreen(
      {Key? key,
      required this.peerId,
      required this.peerAvatar,
      required this.peerName,
      required this.peerPetId})
      : super(key: key);

  @override
  State createState() => ChatScreenState(
      peerId: peerId,
      peerAvatar: peerAvatar,
      peerName: peerName,
      peerPetId: peerPetId);
}

class ChatScreenState extends StateMVC<ChatScreen> {
  String peerId;
  String peerAvatar;
  final String peerName;
  String peerPetId;
  ChatController? _con;

  ChatScreenState(
      {Key? key,
      required this.peerId,
      required this.peerAvatar,
      required this.peerName,
      required this.peerPetId})
      : super(ChatController()) {
    _con = controller as ChatController?;
  }

  updateStatus(status) async {
    await FirebaseCredentials()
        .db
        .collection('token')
        .doc(FirebaseCredentials().auth.currentUser!.uid)
        .set({
      "isOnline": status,
    }, SetOptions(merge: true));
  }

  @override
  void initState() {
    super.initState();
    _con!.focusNode.addListener(_con!.onFocusChange);
    _con!.listScrollController.addListener(_con!.scrollListener);
    _con!.init(peerId, peerPetId);
    updateStatus(true);
  }

  @override
  void dispose() async {
    super.dispose();
    updateStatus(false);

    _con!.onBackPress();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            // List of messages

            _con!.buildListMessage(peerAvatar),
            _con!.buildInput(peerId),
          ],
        ),
        _con!.buildLoading()
      ],
    );
  }
}
