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
        super(InitialNumberTriviaState()) {
    on<GetTriviaForConcreteNumber>((event, emit) async {
      final stringNumber = event.numberString;

      final inputEither =
          this._inputConverter.stringToUnsignedInteger(stringNumber);

      await inputEither.fold(
        (_) async => emit(
          NumberTriviaRetrievalErrorState(
            message: INVALID_INPUT_FAILURE_MESSAGE,
          ),
        ),
        (parsedNumber) async {
          emit(LoadingNumberTriviaState());

          final params = Params(number: parsedNumber);
          final either = await this._getConcreteNumberTrivia(params);

          this._emitNumberTriviaRetrievalResult(either, emit);
        },
      );
    });

    on<GetTriviaForRandomNumber>((event, emit) async {
      emit(LoadingNumberTriviaState());

      final either = await this._getRandomNumberTrivia(NoParams());

      this._emitNumberTriviaRetrievalResult(either, emit);
    });
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

  void _emitNumberTriviaRetrievalResult(
    Either<Failure, NumberTrivia> either,
    Emitter<NumberTriviaState> emit,
  ) async {
    await either.fold(
      (failure) async {
        emit(
          NumberTriviaRetrievalErrorState(
            message: this._mapFailureToMessage(failure),
          ),
        );
      },
      (trivia) async {
        emit(
          LoadedNumberTriviaState(
            trivia: trivia,
          ),
        );
      },
    );
  }
}
