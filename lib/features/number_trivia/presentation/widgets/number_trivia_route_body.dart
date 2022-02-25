import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart';
import '../bloc/number_trivia_bloc.dart';
import '../bloc/state/initial_number_trivia_state.dart';
import '../bloc/state/loaded_number_trivia_state.dart';
import '../bloc/state/loading_number_trivia_state.dart';
import '../bloc/state/number_trivia_retrieval_error_state.dart';
import 'widgets.dart';

class NumberTriviaRouteBody extends StatelessWidget {
  const NumberTriviaRouteBody({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator.get<NumberTriviaBloc>(),
      child: Container(
        padding: const EdgeInsets.all(10),
        alignment: Alignment.center,
        child: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
              builder: (context, state) {
                late final Widget widget;

                if (state is InitialNumberTriviaState) {
                  widget = const MessageDisplay(
                    message: 'Start searching!',
                  );
                } else if (state is LoadingNumberTriviaState) {
                  widget = const LoadingWidget();
                } else if (state is LoadedNumberTriviaState) {
                  widget = TriviaDisplay(
                    numberTrivia: state.trivia,
                  );
                } else if (state is NumberTriviaRetrievalErrorState) {
                  widget = MessageDisplay(
                    message: state.message,
                  );
                }
                return widget;
              },
            ),
            const SizedBox(
              height: 20,
            ),
            const TriviaControl(),
          ],
        ),
      ),
    );
  }
}
