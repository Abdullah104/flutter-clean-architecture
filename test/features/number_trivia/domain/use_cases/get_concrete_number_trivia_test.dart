import 'package:clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:clean_architecture/features/number_trivia/domain/use_cases/get_concrete_number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockNumberTriviaRepository extends Mock
    implements NumberTriviaRepository {}

void main() {
  const testNumber = 1;
  const testNumberTrivia = NumberTrivia(number: 1, text: 'test');
  GetConcreteNumberTrivia? useCase;
  MockNumberTriviaRepository? mockNumberTriviaRepository;

  setUp(() {
    mockNumberTriviaRepository = MockNumberTriviaRepository();
    useCase = GetConcreteNumberTrivia(mockNumberTriviaRepository!);
  });

  test('should get trivia for the number from the repository', () async {
    // Arrange
    when(() => mockNumberTriviaRepository!.getConcreteNumberTrivia(any()))
        .thenAnswer((_) async => const Right(testNumberTrivia));

    // Act
    final result = await useCase!(const Params(number: testNumber));

    // Assert
    expect(result, equals(const Right(testNumberTrivia)));
    verify(
        () => mockNumberTriviaRepository!.getConcreteNumberTrivia(testNumber));

    verifyNoMoreInteractions(
      mockNumberTriviaRepository,
    );
  });
}
