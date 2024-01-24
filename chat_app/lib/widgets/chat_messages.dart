import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authentivatedUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('created At', descending: true)
          .snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No messages found.'),
          );
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('Something went wrong'),
          );
        }
        final loadedMessages = snapshot.data!.docs;
        return ListView.builder(
          reverse: true,
          padding: EdgeInsets.only(bottom: 40, left: 13, right: 13),
          itemCount: loadedMessages.length,
          itemBuilder: (ctx, idx) {
            final chatMessage = loadedMessages[idx].data();
            final nextChatMsg = idx + 1 < loadedMessages.length
                ? loadedMessages[idx + 1].data()
                : null;
            final currentmsgUserId = chatMessage['user id'];
            final nextmsgUserId =
                nextChatMsg != null ? nextChatMsg['user id'] : null;
            final nextUserIsSame = currentmsgUserId == nextmsgUserId;

            if (nextUserIsSame) {
              return MessageBubble.next(
                  message: chatMessage['text'],
                  isMe: authentivatedUser.uid == currentmsgUserId);
            } else {
              return MessageBubble.first(
                  userImage: chatMessage['userImage'],
                  username: chatMessage['username'],
                  message: chatMessage['text'],
                  isMe: authentivatedUser.uid == currentmsgUserId);
            }
          },
        );
      },
    );
  }
}
