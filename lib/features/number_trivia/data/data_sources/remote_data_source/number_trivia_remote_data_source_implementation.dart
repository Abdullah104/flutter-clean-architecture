import 'dart:convert';

import 'package:clean_architecture/core/error/exceptions/server_exception.dart';
import 'package:http/http.dart';

import '../../models/number_trivia_model.dart';
import 'number_trivia_remote_data_source.dart';

const _API = 'http://numbersapi.com';

class NumberTriviaRemoteDataSourceImplementation
    implements NumberTriviaRemoteDataSource {
  final Client _client;

  NumberTriviaRemoteDataSourceImplementation({
    required Client client,
  }) : this._client = client;

  @override
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number) =>
      this._getTriviaFromUrl('$_API/$number');

  @override
  Future<NumberTriviaModel> getRandomNumberTrivia() =>
      this._getTriviaFromUrl('$_API/random');

  Future<NumberTriviaModel> _getTriviaFromUrl(String url) async {
    final uri = Uri.parse(url);

    final headers = {
      'Content-Type': 'application/json',
    };

    final response = await this._client.get(uri, headers: headers);
    final responseBody = response.body;
    final responseCode = response.statusCode;

    if (responseCode == 200) {
      final jsonResponse = json.decode(responseBody);
      final numberTriviaModel = NumberTriviaModel.fromJson(jsonResponse);

      return numberTriviaModel;
    } else {
      throw ServerException();
    }
  }
}
