import 'package:flutter/material.dart';

class MessageDisplay extends StatelessWidget {
  final String _message;

  const MessageDisplay({
    Key? key,
    required String message,
  })  : _message = message,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height / 3,
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Text(
          _message,
          style: const TextStyle(
            fontSize: 25,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
