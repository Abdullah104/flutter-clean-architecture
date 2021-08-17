import 'package:clean_architecture/features/number_trivia/data/models/number_trivia_model.dart';

abstract class NumberTriviaLocalDataSource {
  /// Calls the http://numbersapi.com/random endpoint
  ///
  /// Throws a [ServerException] for all error codes.
  Future<NumberTriviaModel> getLastNumberTrivia();

  /// Gets the cached [NumberTriviaModel] which was gotten the last time
  /// the user had an internet connection.
  ///
  /// Throws [CacheException] if no cached data is present
  Future<void> cacheNumberTrivia(NumberTriviaModel triviaToCache);
}
