import 'dart:convert';

import 'package:clean_architecture/core/error/exceptions/cache_exception.dart';
import 'package:clean_architecture/features/number_trivia/data/data_sources/local_data_source/number_trivia_local_data_source_implementation.dart';
import 'package:clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../fixtures/fixture_reader.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late NumberTriviaLocalDataSourceImplementation dataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();

    dataSource = NumberTriviaLocalDataSourceImplementation(
      sharedPreferences: mockSharedPreferences,
    );
  });

  group('getLastNumberTrivia', () {
    final testNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia_cached.json')));
    test(
      'should return number trivia model from SharedPreferences when there is one in the cache',
      () async {
        // Arrange
        when(() => mockSharedPreferences.getString(any()))
            .thenReturn(fixture('trivia_cached.json'));

        // Act
        final result = await dataSource.getLastNumberTrivia();

        // Assert
        verify(() => mockSharedPreferences.getString(cachedNumberTrivia));
        expect(result, equals(testNumberTriviaModel));
      },
    );

    test(
      'should throw a cache exception when there is not a cached value',
      () async {
        // Arrange
        when(() => mockSharedPreferences.getString(any())).thenReturn(null);

        // Act
        final call = dataSource.getLastNumberTrivia;

        // Assert
        expect(() => call(), throwsA(const TypeMatcher<CacheException>()));
      },
    );
  });

  group('cacheNumberTrivia', () {
    const testNumberTriviaModel = NumberTriviaModel(
      number: 1,
      text: 'test trivia',
    );

    test('should call shared preferences to cache the data', () {
      // Arrange
      when(() => mockSharedPreferences.setString(any(), any()))
          .thenAnswer((_) async => true);

      // Act
      dataSource.cacheNumberTrivia(testNumberTriviaModel);

      // Assert
      final expectedJsonString = json.encode(testNumberTriviaModel.toJson());

      verify(() => mockSharedPreferences.setString(
            cachedNumberTrivia,
            expectedJsonString,
          ));
    });
  });
}
