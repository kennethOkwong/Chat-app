import 'package:chat_app/widget/chats.dart';
import 'package:chat_app/widget/new_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final _firebaseAuth = FirebaseAuth.instance;
final _firestore = FirebaseFirestore.instance;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
//funtion to send a chat
  void _submitChat(String text) async {
    final user = _firebaseAuth.currentUser;
    final userDetails =
        await _firestore.collection('users').doc(user!.uid).get();

    _firestore.collection('chats').add({
      'text': text,
      'user_name': userDetails.data()!['user_name'],
      'image_url': userDetails.data()!['image_url'],
      'time_stamp': Timestamp.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('My chats'),
          actions: [
            IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: Icon(
                Icons.exit_to_app,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.only(
            bottom: 5,
            left: 15,
            right: 15,
            top: 2,
          ),
          child: Column(
            children: [
              const Expanded(
                child: Chats(),
              ),
              NewMessage(
                enteredMessage: (text) {
                  _submitChat(text);
                },
              ),
            ],
          ),
        ));
  }
}
