import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage(
      {super.key, required this.peerId, required this.peerNickname});
  final String peerId;
  final String peerNickname;

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  static final GlobalKey formKey = GlobalKey();

  final Stream<QuerySnapshot> _messageStream = FirebaseFirestore.instance
      .collection('messages')
      .orderBy('time')
      .snapshots();
  final TextEditingController _textEditingController = TextEditingController();

  void _sendMessage() async {
    final text = _textEditingController.text.trim();
    if (text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('messages').add({
        'message': text,
        'time': DateTime.now(),
        'sender': FirebaseAuth.instance.currentUser!.uid,
        'reciever': widget.peerId,
      });
      _textEditingController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.peerNickname,
            style: const TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colors.red,
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: _messageStream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Text('Something went wrong');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Loading");
              }
              QuerySnapshot? querySnapshot = snapshot.data;
              return Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.white),
                      child: ClipRRect(
                        child: ListView.builder(
                            padding: const EdgeInsets.only(top: 15.0),
                            itemCount: querySnapshot?.docs.length ?? 0,
                            itemBuilder: (BuildContext context, index) {
                              var messageDataFunc =
                                  querySnapshot?.docs[index].data;
                              Map<String, dynamic> messageData =
                                  messageDataFunc!() as Map<String, dynamic>;
                              final String currentUserId =
                                  FirebaseAuth.instance.currentUser!.uid;
                              final bool isMe = messageData['sender'] ==
                                  FirebaseAuth.instance.currentUser!.uid;

                              if ((messageData['sender'] == widget.peerId &&
                                      messageData['reciever'] ==
                                          currentUserId) ||
                                  (messageData['sender'] == currentUserId &&
                                      messageData['reciever'] ==
                                          widget.peerId)) {
                                return _buildMessage(messageData, isMe);
                              } else {
                                return SizedBox(width: 0);
                              }
                            }),
                      ),
                    ),
                  ),
                  _buildMessageComposer(),
                ],
              );
            }));
  }

  Widget _buildMessage(Map<String, dynamic> messageData, bool isMe) {
    return Container(
      margin: isMe
          ? EdgeInsets.only(
              top: 8.0,
              bottom: 8.0,
              right: 5.0,
              left: 100.0,
            )
          : EdgeInsets.only(top: 8.0, bottom: 8.0, left: 5.0, right: 100.0),
      padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
      width: MediaQuery.of(context).size.width * 0.75,
      decoration: BoxDecoration(
          color: isMe ? Color(0xFFE9F1FF) : Color(0xFFFFEFEE),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10.0),
              bottomLeft: Radius.circular(10.0),
              topRight: Radius.circular(10.0),
              bottomRight: Radius.circular(10.0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(DateFormat('h:mm a').format(messageData['time'].toDate()),
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              )),
          SizedBox(
            height: 5.0,
          ),
          Text(messageData['message'],
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }

  _buildMessageComposer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      height: 70.0,
      color: Colors.white,
      child: Form(
        key: formKey,
        child: Row(
          children: [
            Expanded(
                child: TextFormField(
              controller: _textEditingController,
              decoration: InputDecoration.collapsed(
                hintText: 'Send a message...',
              ),
            )),
            IconButton(
                iconSize: 25.0,
                color: Colors.red,
                onPressed: _sendMessage,
                icon: Icon(Icons.send))
          ],
        ),
      ),
    );
  }
}
