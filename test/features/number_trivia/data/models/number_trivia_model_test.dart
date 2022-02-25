import 'dart:convert';

import 'package:clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  const testNumberTriviaModel = NumberTriviaModel(number: 1, text: 'Test Text');

  test('should be a subclass of number trivia entity', () {
    // Assert
    expect(testNumberTriviaModel, isA<NumberTrivia>());
  });

  group('fromJson', () {
    test('should return a valid model when the JSON number is int', () {
      // Arrange
      final Map<String, dynamic> jsonMap = json.decode(fixture('trivia.json'));

      // Act
      final result = NumberTriviaModel.fromJson(jsonMap);

      // Assert
      expect(result, testNumberTriviaModel);
    });

    test(
      'should return a valid model when the JSON number is regarded as a double',
      () {
        // Arrange
        final Map<String, dynamic> jsonMap =
            json.decode(fixture('trivia_double.json'));

        // Act
        final result = NumberTriviaModel.fromJson(jsonMap);

        // Assert
        expect(result, testNumberTriviaModel);
      },
    );
  });

  group('toJson', () {
    test('should return a JSON map containing the proper data', () {
      // Act
      final result = testNumberTriviaModel.toJson();

      // Assert
      final expectedMap = {'text': 'Test Text', 'number': 1};

      expect(result, equals(expectedMap));
    });
  });
}
