import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/events/get_trivia_for_concrete_number.dart';
import '../bloc/events/get_trivia_for_random_number.dart';
import '../bloc/number_trivia_bloc.dart';

class TriviaControl extends StatefulWidget {
  const TriviaControl({
    Key? key,
  }) : super(key: key);

  @override
  _TriviaControlState createState() => _TriviaControlState();
}

class _TriviaControlState extends State<TriviaControl> {
  final controller = TextEditingController();
  String input = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: this.controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Input a number',
          ),
          onChanged: (value) {
            this.input = value;
          },
          onSubmitted: (value) {
            dispatchConcrete();
          },
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                child: Text('Search'),
                style: ElevatedButton.styleFrom(
                  primary: Theme.of(context).accentColor,
                ),
                onPressed: this.dispatchConcrete,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: ElevatedButton(
                child: Text('Get random trivia'),
                onPressed: this.dispatchRandom,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void dispatchConcrete() {
    controller.clear();

    BlocProvider.of<NumberTriviaBloc>(context)
        .add(GetTriviaForConcreteNumber(this.input));
  }

  void dispatchRandom() {
    controller.clear();

    BlocProvider.of<NumberTriviaBloc>(context).add(GetTriviaForRandomNumber());
  }
}
