import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions/cache_exception.dart';
import '../../../../core/error/exceptions/server_exception.dart';
import '../../../../core/error/failures/cache_failure.dart';
import '../../../../core/error/failures/failure.dart';
import '../../../../core/error/failures/server_failure.dart';
import '../../../../core/network/network_information.dart';
import '../../domain/entities/number_trivia.dart';
import '../../domain/repositories/number_trivia_repository.dart';
import '../data_sources/local_data_source/number_trivia_local_data_source.dart';
import '../data_sources/remote_data_source/number_trivia_remote_data_source.dart';
import '../models/number_trivia_model.dart';

typedef _ConcreteOrRandomChooser = Future<NumberTriviaModel> Function();

class NumberTriviaRepositoryImplementation implements NumberTriviaRepository {
  final NumberTriviaRemoteDataSource _numberTriviaRemoteDataSource;
  final NumberTriviaLocalDataSource _numberTriviaLocalDataSource;
  final NetworkInformation _networkInformation;

  NumberTriviaRepositoryImplementation({
    required NumberTriviaRemoteDataSource remoteDataSource,
    required NumberTriviaLocalDataSource localDataSource,
    required NetworkInformation networkInformation,
  })  : _numberTriviaRemoteDataSource = remoteDataSource,
        _numberTriviaLocalDataSource = localDataSource,
        _networkInformation = networkInformation;

  @override
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(
    int number,
  ) async =>
      await _getTrivia(
          () => _numberTriviaRemoteDataSource.getConcreteNumberTrivia(number));

  @override
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia() async =>
      await _getTrivia(
          () => _numberTriviaRemoteDataSource.getRandomNumberTrivia());

  Future<Either<Failure, NumberTrivia>> _getTrivia(
      _ConcreteOrRandomChooser getConcreteOrRandom) async {
    final isConnected = await _networkInformation.isConnected;

    if (isConnected) {
      try {
        final numberTrivia = await getConcreteOrRandom();

        _numberTriviaLocalDataSource.cacheNumberTrivia(numberTrivia);

        return Right(numberTrivia);
      } on ServerException {
        final failure = ServerFailure();

        return Left(failure);
      }
    } else {
      try {
        final numberTrivia =
            await _numberTriviaLocalDataSource.getLastNumberTrivia();

        return Right(numberTrivia);
      } on CacheException {
        final failure = CacheFailure();

        return Left(failure);
      }
    }
  }
}
