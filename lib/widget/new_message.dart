import 'dart:developer';

import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key, required this.enteredMessage});

  final Function(String text) enteredMessage;

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _enteredChat = TextEditingController();

//function to dispose controllers
  @override
  void dispose() {
    _enteredChat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            decoration: const InputDecoration(hintText: 'Type a message...'),
            textCapitalization: TextCapitalization.sentences,
            controller: _enteredChat,
          ),
        ),
        IconButton(
          onPressed: () {
            if (_enteredChat.text.trim().isEmpty) {
              log('error');
              return;
            }

            widget.enteredMessage(_enteredChat.text);

            FocusScope.of(context).unfocus();
            _enteredChat.clear();
          },
          icon: const Icon(Icons.send),
          style: TextButton.styleFrom(
            iconColor: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
