import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures/cache_failure.dart';
import '../../../../core/error/failures/failure.dart';
import '../../../../core/error/failures/server_failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../../../core/utilities/input_converter.dart';
import '../../domain/use_cases/get_concrete_number_trivia.dart';
import '../../domain/use_cases/get_random_number_trivia.dart';
import 'events/get_trivia_for_concrete_number.dart';
import 'events/get_trivia_for_random_number.dart';
import 'state/initial_number_trivia_state.dart';
import 'state/loaded_number_trivia_state.dart';
import 'state/loading_number_trivia_state.dart';
import 'state/number_trivia_retrieval_error_state.dart';

part 'events/number_trivia_event.dart';
part 'state/number_trivia_state.dart';

const SERVER_FAILURE_MESSAGE = 'Server Failure';
const CACHE_FAILURE_MESSAGE = 'Cache Failure';

const INVALID_INPUT_FAILURE_MESSAGE =
    'Invalid Input - The number must be a positive integer or zero.';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia _getConcreteNumberTrivia;
  final GetRandomNumberTrivia _getRandomNumberTrivia;
  final InputConverter _inputConverter;

  NumberTriviaBloc({
    required GetConcreteNumberTrivia getConcreteNumberTrivia,
    required GetRandomNumberTrivia getRandomNumberTrivia,
    required InputConverter inputConverter,
  })  : this._getConcreteNumberTrivia = getConcreteNumberTrivia,
        this._getRandomNumberTrivia = getRandomNumberTrivia,
        this._inputConverter = inputConverter,
        super(InitialNumberTriviaState());

  @override
  Stream<NumberTriviaState> mapEventToState(
    NumberTriviaEvent event,
  ) async* {
    if (event is GetTriviaForConcreteNumber) {
      final stringNumber = event.numberString;

      final inputEither =
          this._inputConverter.stringToUnsignedInteger(stringNumber);

      yield* inputEither.fold(
        (_) async* {
          yield NumberTriviaRetrievalErrorState(
            message: INVALID_INPUT_FAILURE_MESSAGE,
          );
        },
        (parsedNumber) async* {
          yield LoadingNumberTriviaState();

          final params = Params(number: parsedNumber);
          final either = await this._getConcreteNumberTrivia(params);

          yield* this._emitNumberTriviaRetrievalResult(either);
        },
      );
    } else if (event is GetTriviaForRandomNumber) {
      yield LoadingNumberTriviaState();

      final params = NoParams();
      final either = await this._getRandomNumberTrivia(params);

      yield* this._emitNumberTriviaRetrievalResult(either);
    }
  }

  String _mapFailureToMessage(Failure failure) {
    late final String failureMessage;

    switch (failure.runtimeType) {
      case ServerFailure:
        failureMessage = SERVER_FAILURE_MESSAGE;

        break;

      case CacheFailure:
        failureMessage = CACHE_FAILURE_MESSAGE;

        break;

      default:
        failureMessage = 'Unexpected error';

        break;
    }

    return failureMessage;
  }

  Stream<NumberTriviaState> _emitNumberTriviaRetrievalResult(
    Either<Failure, NumberTrivia> either,
  ) async* {
    yield* either.fold(
      (failure) async* {
        yield NumberTriviaRetrievalErrorState(
          message: this._mapFailureToMessage(failure),
        );
      },
      (trivia) async* {
        yield LoadedNumberTriviaState(trivia: trivia);
      },
    );
  }
}
