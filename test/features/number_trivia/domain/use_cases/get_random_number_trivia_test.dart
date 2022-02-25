import 'package:clean_architecture/core/use_cases/use_case.dart';
import 'package:clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:clean_architecture/features/number_trivia/domain/use_cases/get_random_number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockNumberTriviaRepository extends Mock
    implements NumberTriviaRepository {}

void main() {
  const testNumberTrivia = NumberTrivia(number: 1, text: 'test');
  GetRandomNumberTrivia? useCase;
  MockNumberTriviaRepository? mockNumberTriviaRepository;

  setUp(() {
    mockNumberTriviaRepository = MockNumberTriviaRepository();
    useCase = GetRandomNumberTrivia(mockNumberTriviaRepository!);
  });

  test('should get trivia from the repository', () async {
    // Arrange
    when(() => mockNumberTriviaRepository!.getRandomNumberTrivia())
        .thenAnswer((_) async => const Right(testNumberTrivia));

    // Act
    final result = await useCase!(NoParams());

    // Assert
    expect(result, equals(const Right(testNumberTrivia)));
    verify(() => mockNumberTriviaRepository!.getRandomNumberTrivia());

    verifyNoMoreInteractions(
      mockNumberTriviaRepository,
    );
  });
}
