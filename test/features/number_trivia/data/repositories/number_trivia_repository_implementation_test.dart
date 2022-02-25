import 'package:clean_architecture/core/error/exceptions/cache_exception.dart';
import 'package:clean_architecture/core/error/exceptions/server_exception.dart';
import 'package:clean_architecture/core/error/failures/cache_failure.dart';
import 'package:clean_architecture/core/error/failures/server_failure.dart';
import 'package:clean_architecture/core/network/network_information.dart';
import 'package:clean_architecture/features/number_trivia/data/data_sources/local_data_source/number_trivia_local_data_source.dart';
import 'package:clean_architecture/features/number_trivia/data/data_sources/remote_data_source/number_trivia_remote_data_source.dart';
import 'package:clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:clean_architecture/features/number_trivia/data/repositories/number_trivia_repository_implementation.dart';
import 'package:clean_architecture/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSource {}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInformation {}

void main() {
  late NumberTriviaRepositoryImplementation repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();

    repository = NumberTriviaRepositoryImplementation(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInformation: mockNetworkInfo,
    );
  });

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }

  group('getConcreteNumberTrivia', () {
    const testNumber = 1;

    const testNumberTriviaModel = NumberTriviaModel(
      number: testNumber,
      text: 'test trivia',
    );

    const NumberTrivia testNumberTrivia = testNumberTriviaModel;

    test('should check if the device is online', () {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);

      when(() => mockRemoteDataSource.getConcreteNumberTrivia(any()))
          .thenAnswer((_) async => testNumberTriviaModel);

      when(() => mockLocalDataSource.cacheNumberTrivia(testNumberTriviaModel))
          .thenAnswer((_) => Future<void>(() {}));

      // Act
      repository.getConcreteNumberTrivia(testNumber);

      // Assert
      verify(() => mockNetworkInfo.isConnected);
    });

    runTestsOnline(() {
      setUp(() {
        when(() => mockLocalDataSource.cacheNumberTrivia(testNumberTriviaModel))
            .thenAnswer((_) => Future<void>(() {}));
      });

      test(
        'should return remote data when the call to remote data source is successful',
        () async {
          // Arrange
          when(() => mockRemoteDataSource.getConcreteNumberTrivia(any()))
              .thenAnswer((_) async => testNumberTriviaModel);

          // Act
          final result = await repository.getConcreteNumberTrivia(testNumber);

          // Assert
          verify(
            () => mockRemoteDataSource.getConcreteNumberTrivia(testNumber),
          );

          expect(result, equals(const Right(testNumberTrivia)));
        },
      );

      test(
        'should cache the data locally when the call to remote data source is successful',
        () async {
          // Arrange
          when(() => mockRemoteDataSource.getConcreteNumberTrivia(any()))
              .thenAnswer((_) async => testNumberTriviaModel);

          // Act
          await repository.getConcreteNumberTrivia(testNumber);

          // Assert
          verify(
            () => mockRemoteDataSource.getConcreteNumberTrivia(testNumber),
          );

          verify(
            () => mockLocalDataSource.cacheNumberTrivia(testNumberTriviaModel),
          );
        },
      );

      test(
        'should return server failure when the call to remote data source is unsuccessful',
        () async {
          // Arrange
          when(() => mockRemoteDataSource.getConcreteNumberTrivia(any()))
              .thenThrow(ServerException());

          // Act
          final result = await repository.getConcreteNumberTrivia(testNumber);

          // Assert
          verify(
            () => mockRemoteDataSource.getConcreteNumberTrivia(testNumber),
          );

          verifyZeroInteractions(mockLocalDataSource);
          expect(result, equals(Left(ServerFailure())));
        },
      );
    });

    runTestsOffline(() {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test(
        'should return last locally cached data when the cached data is present',
        () async {
          // Arrange
          when(() => mockLocalDataSource.getLastNumberTrivia())
              .thenAnswer((_) async => testNumberTriviaModel);

          // Act
          final result = await repository.getConcreteNumberTrivia(testNumber);

          // Assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(() => mockLocalDataSource.getLastNumberTrivia());
          expect(result, const Right(testNumberTrivia));
        },
      );

      test(
        'should return cache failure when there is no cached data',
        () async {
          // Arrange
          when(() => mockLocalDataSource.getLastNumberTrivia())
              .thenThrow(CacheException());

          // Act
          final result = await repository.getConcreteNumberTrivia(testNumber);

          // Assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(() => mockLocalDataSource.getLastNumberTrivia());
          expect(result, Left(CacheFailure()));
        },
      );
    });
  });

  group('getRandomNumberTrivia', () {
    const testNumberTriviaModel = NumberTriviaModel(
      number: 123,
      text: 'test trivia',
    );

    const NumberTrivia testNumberTrivia = testNumberTriviaModel;

    test('should check if the device is online', () {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);

      when(() => mockRemoteDataSource.getRandomNumberTrivia())
          .thenAnswer((_) async => testNumberTriviaModel);

      when(() => mockLocalDataSource.cacheNumberTrivia(testNumberTriviaModel))
          .thenAnswer((_) => Future<void>(() {}));

      // Act
      repository.getRandomNumberTrivia();

      // Assert
      verify(() => mockNetworkInfo.isConnected);
    });

    runTestsOnline(() {
      setUp(() {
        when(() => mockLocalDataSource.cacheNumberTrivia(testNumberTriviaModel))
            .thenAnswer((_) => Future<void>(() {}));
      });

      test(
        'should return remote data when the call to remote data source is successful',
        () async {
          // Arrange
          when(() => mockRemoteDataSource.getRandomNumberTrivia())
              .thenAnswer((_) async => testNumberTriviaModel);

          // Act
          final result = await repository.getRandomNumberTrivia();

          // Assert
          verify(
            () => mockRemoteDataSource.getRandomNumberTrivia(),
          );

          expect(result, equals(const Right(testNumberTrivia)));
        },
      );

      test(
        'should cache the data locally when the call to remote data source is successful',
        () async {
          // Arrange
          when(() => mockRemoteDataSource.getRandomNumberTrivia())
              .thenAnswer((_) async => testNumberTriviaModel);

          // Act
          await repository.getRandomNumberTrivia();

          // Assert
          verify(
            () => mockRemoteDataSource.getRandomNumberTrivia(),
          );

          verify(
            () => mockLocalDataSource.cacheNumberTrivia(testNumberTriviaModel),
          );
        },
      );

      test(
        'should return server failure when the call to remote data source is unsuccessful',
        () async {
          // Arrange
          when(() => mockRemoteDataSource.getRandomNumberTrivia())
              .thenThrow(ServerException());

          // Act
          final result = await repository.getRandomNumberTrivia();

          // Assert
          verify(
            () => mockRemoteDataSource.getRandomNumberTrivia(),
          );

          verifyZeroInteractions(mockLocalDataSource);
          expect(result, equals(Left(ServerFailure())));
        },
      );
    });

    runTestsOffline(() {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      test(
        'should return last locally cached data when the cached data is present',
        () async {
          // Arrange
          when(() => mockLocalDataSource.getLastNumberTrivia())
              .thenAnswer((_) async => testNumberTriviaModel);

          // Act
          final result = await repository.getRandomNumberTrivia();

          // Assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(() => mockLocalDataSource.getLastNumberTrivia());
          expect(result, const Right(testNumberTrivia));
        },
      );

      test(
        'should return cache failure when there is no cached data',
        () async {
          // Arrange
          when(() => mockLocalDataSource.getLastNumberTrivia())
              .thenThrow(CacheException());

          // Act
          final result = await repository.getRandomNumberTrivia();

          // Assert
          verifyZeroInteractions(mockRemoteDataSource);
          verify(() => mockLocalDataSource.getLastNumberTrivia());
          expect(result, Left(CacheFailure()));
        },
      );
    });
  });
}
