import 'package:clean_architecture/core/error/failures/cache_failure.dart';
import 'package:clean_architecture/core/error/failures/invalid_input_failure.dart';
import 'package:clean_architecture/core/error/failures/server_failure.dart';
import 'package:clean_architecture/core/use_cases/use_case.dart';
import 'package:clean_architecture/core/utilities/input_converter.dart';
import 'package:clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture/features/number_trivia/domain/use_cases/get_concrete_number_trivia.dart';
import 'package:clean_architecture/features/number_trivia/domain/use_cases/get_random_number_trivia.dart';
import 'package:clean_architecture/features/number_trivia/presentation/bloc/events/get_trivia_for_concrete_number.dart';
import 'package:clean_architecture/features/number_trivia/presentation/bloc/events/get_trivia_for_random_number.dart';
import 'package:clean_architecture/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:clean_architecture/features/number_trivia/presentation/bloc/state/initial_number_trivia_state.dart';
import 'package:clean_architecture/features/number_trivia/presentation/bloc/state/loaded_number_trivia_state.dart';
import 'package:clean_architecture/features/number_trivia/presentation/bloc/state/loading_number_trivia_state.dart';
import 'package:clean_architecture/features/number_trivia/presentation/bloc/state/number_trivia_retrieval_error_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

void main() {
  final testNumberString = '1';
  final testParsedNumber = 1;
  final testNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');
  NumberTriviaBloc? bloc;
  MockGetConcreteNumberTrivia? mockGetConcreteNumberTrivia;
  MockGetRandomNumberTrivia? mockGetRandomNumberTrivia;
  MockInputConverter? mockInputConverter;

  setUpAll(() {
    registerFallbackValue(Params(number: testParsedNumber));
    registerFallbackValue(NoParams());
  });

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(
      getConcreteNumberTrivia: mockGetConcreteNumberTrivia!,
      getRandomNumberTrivia: mockGetRandomNumberTrivia!,
      inputConverter: mockInputConverter!,
    );
  });

  void setUpMockInputConverterSuccess() {
    when(() => mockInputConverter!.stringToUnsignedInteger(any()))
        .thenReturn(Right(testParsedNumber));
  }

  void setUpMockGetConcreteNumberTriviaSuccess() {
    when(() => mockGetConcreteNumberTrivia!(any()))
        .thenAnswer((_) async => Right(testNumberTrivia));
  }

  void setUpMockGetRandomNumberTriviaSuccess() {
    when(() => mockGetRandomNumberTrivia!(any()))
        .thenAnswer((_) async => Right(testNumberTrivia));
  }

  test('bloc initial state should be InitialNumberTriviaState', () {
    // Assert
    expect(bloc!.state, equals(InitialNumberTriviaState()));
  });

  group('GetTriviaForConcreteNumber', () {
    test(
      'should call the InputConverter to validate and convert the number to an unsigned integer',
      () async {
        // Arrange
        setUpMockInputConverterSuccess();
        setUpMockGetConcreteNumberTriviaSuccess();

        // Act
        bloc!.add(GetTriviaForConcreteNumber(testNumberString));

        await untilCalled(
            () => mockInputConverter!.stringToUnsignedInteger(any()));

        // Assert
        verify(() =>
            mockInputConverter!.stringToUnsignedInteger(testNumberString));
      },
    );

    test(
      'should emit [NumberTriviaRetrievalErrorState] when the input is invalid',
      () {
        // Arrange
        when(() => mockInputConverter!.stringToUnsignedInteger(any()))
            .thenReturn(Left(InvalidInputFailure()));

        // Assert
        expectLater(
            bloc!.stream,
            emitsInOrder([
              NumberTriviaRetrievalErrorState(
                  message: INVALID_INPUT_FAILURE_MESSAGE)
            ]));

        // Act
        bloc!.add(GetTriviaForConcreteNumber(testNumberString));
      },
    );

    test('should get data from the concrete use case', () async {
      // arrange
      setUpMockInputConverterSuccess();
      setUpMockGetConcreteNumberTriviaSuccess();

      // act
      bloc!.add(GetTriviaForConcreteNumber(testNumberString));
      await untilCalled(() => mockGetConcreteNumberTrivia!(any()));

      // // assert
      verify(
        () => mockGetConcreteNumberTrivia!(Params(number: testParsedNumber)),
      );
    });

    test(
      'should emit [LoadingNumberTriviaState, LoadedNumberTriviaState] states when data is gotten successfully',
      () {
        // arrange
        setUpMockInputConverterSuccess();
        setUpMockGetConcreteNumberTriviaSuccess();

        // assert later
        final expected = [
          LoadingNumberTriviaState(),
          LoadedNumberTriviaState(trivia: testNumberTrivia),
        ];

        expectLater(bloc!.stream, emitsInOrder(expected));

        // act
        bloc!.add(GetTriviaForConcreteNumber(testNumberString));
      },
    );

    test(
      'should emit [LoadingNumberTriviaState, NumberTriviaRetrievalErrorState] states when data is gotten successfully',
      () {
        // arrange
        setUpMockInputConverterSuccess();

        when(() => mockGetConcreteNumberTrivia!(any()))
            .thenAnswer((_) async => Left(ServerFailure()));

        // assert later
        final expected = [
          LoadingNumberTriviaState(),
          NumberTriviaRetrievalErrorState(message: SERVER_FAILURE_MESSAGE),
        ];

        expectLater(bloc!.stream, emitsInOrder(expected));

        // act
        bloc!.add(GetTriviaForConcreteNumber(testNumberString));
      },
    );
    test(
      'should emit [LoadingNumberTriviaState, NumberTriviaRetrievalErrorState] with a propper message for the error when getting data fails',
      () {
        // arrange
        setUpMockInputConverterSuccess();

        when(() => mockGetConcreteNumberTrivia!(any()))
            .thenAnswer((_) async => Left(CacheFailure()));

        // assert later
        final expected = [
          LoadingNumberTriviaState(),
          NumberTriviaRetrievalErrorState(message: CACHE_FAILURE_MESSAGE),
        ];

        expectLater(bloc!.stream, emitsInOrder(expected));

        // act
        bloc!.add(GetTriviaForConcreteNumber(testNumberString));
      },
    );
  });

  group('GetTriviaForRandomNumber', () {
    test('should get data from the random use case', () async {
      // arrange
      setUpMockInputConverterSuccess();
      setUpMockGetRandomNumberTriviaSuccess();

      // act
      bloc!.add(GetTriviaForRandomNumber());
      await untilCalled(() => mockGetRandomNumberTrivia!(NoParams()));

      // // assert
      verify(
        () => mockGetRandomNumberTrivia!(NoParams()),
      );
    });

    test(
      'should emit [LoadingNumberTriviaState, LoadedNumberTriviaState] states when data is gotten successfully',
      () {
        // arrange
        setUpMockInputConverterSuccess();
        setUpMockGetRandomNumberTriviaSuccess();

        // assert later
        final expected = [
          LoadingNumberTriviaState(),
          LoadedNumberTriviaState(trivia: testNumberTrivia),
        ];

        expectLater(bloc!.stream, emitsInOrder(expected));

        // act
        bloc!.add(GetTriviaForRandomNumber());
      },
    );

    test(
      'should emit [LoadingNumberTriviaState, NumberTriviaRetrievalErrorState] states when data is gotten successfully',
      () {
        // arrange
        setUpMockInputConverterSuccess();

        when(() => mockGetRandomNumberTrivia!(NoParams()))
            .thenAnswer((_) async => Left(ServerFailure()));

        // assert later
        final expected = [
          LoadingNumberTriviaState(),
          NumberTriviaRetrievalErrorState(message: SERVER_FAILURE_MESSAGE),
        ];

        expectLater(bloc!.stream, emitsInOrder(expected));

        // act
        bloc!.add(GetTriviaForRandomNumber());
      },
    );
    test(
      'should emit [LoadingNumberTriviaState, NumberTriviaRetrievalErrorState] with a propper message for the error when getting data fails',
      () {
        // arrange
        setUpMockInputConverterSuccess();

        when(() => mockGetRandomNumberTrivia!(NoParams()))
            .thenAnswer((_) async => Left(CacheFailure()));

        // assert later
        final expected = [
          LoadingNumberTriviaState(),
          NumberTriviaRetrievalErrorState(message: CACHE_FAILURE_MESSAGE),
        ];

        expectLater(bloc!.stream, emitsInOrder(expected));

        // act
        bloc!.add(GetTriviaForRandomNumber());
      },
    );
  });
}
