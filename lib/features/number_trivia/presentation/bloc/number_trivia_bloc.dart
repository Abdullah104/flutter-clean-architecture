import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures/cache_failure.dart';
import '../../../../core/error/failures/failure.dart';
import '../../../../core/error/failures/server_failure.dart';
import '../../../../core/use_cases/use_case.dart';
import '../../../../core/utilities/input_converter.dart';
import '../../domain/entities/number_trivia.dart';
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

const serverFailureMessage = 'Server Failure';
const cacheFailureMessage = 'Cache Failure';

const invalidInputFailureMessage =
    'Invalid Input - The number must be a positive integer or zero.';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia _getConcreteNumberTrivia;
  final GetRandomNumberTrivia _getRandomNumberTrivia;
  final InputConverter _inputConverter;

  NumberTriviaBloc({
    required GetConcreteNumberTrivia getConcreteNumberTrivia,
    required GetRandomNumberTrivia getRandomNumberTrivia,
    required InputConverter inputConverter,
  })  : _getConcreteNumberTrivia = getConcreteNumberTrivia,
        _getRandomNumberTrivia = getRandomNumberTrivia,
        _inputConverter = inputConverter,
        super(InitialNumberTriviaState()) {
    on<GetTriviaForConcreteNumber>(_concreteTriviaEventHandler);

    on<GetTriviaForRandomNumber>(_randomTriviaEventHandler);
  }

  Future<void> _concreteTriviaEventHandler(
    GetTriviaForConcreteNumber event,
    Emitter<NumberTriviaState> emit,
  ) async {
    final stringNumber = event.numberString;

    final inputEither = _inputConverter.stringToUnsignedInteger(stringNumber);

    await inputEither.fold(
      (_) async => emit(
        const NumberTriviaRetrievalErrorState(
          message: invalidInputFailureMessage,
        ),
      ),
      (parsedNumber) async {
        emit(LoadingNumberTriviaState());

        final params = Params(number: parsedNumber);
        final either = await _getConcreteNumberTrivia(params);

        _emitNumberTriviaRetrievalResult(either, emit);
      },
    );
  }

  Future<void> _randomTriviaEventHandler(
    GetTriviaForRandomNumber event,
    Emitter<NumberTriviaState> emit,
  ) async {
    emit(LoadingNumberTriviaState());

    final either = await _getRandomNumberTrivia(NoParams());

    _emitNumberTriviaRetrievalResult(either, emit);
  }

  String _mapFailureToMessage(Failure failure) {
    late final String failureMessage;

    switch (failure.runtimeType) {
      case ServerFailure:
        failureMessage = serverFailureMessage;

        break;

      case CacheFailure:
        failureMessage = cacheFailureMessage;

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
            message: _mapFailureToMessage(failure),
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
