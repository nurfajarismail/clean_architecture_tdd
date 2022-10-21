import 'dart:convert';

import 'package:clean_architecture_tdd/core/error/exception.dart';
import 'package:clean_architecture_tdd/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:clean_architecture_tdd/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_architecture_tdd/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';
import 'number_trivia_local_data_source_test.mocks.dart';
import 'package:http/http.dart' as http;

import 'number_trivia_remote_data_source_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  NumberTriviaRemoteDataSourceImpl? dataSource;
  MockClient? mockHttpClient;

  setUp(() {
    mockHttpClient = MockClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient!);
  });

  void setUpMockHttpClientSuccess200() {
    when(mockHttpClient?.get(any, headers: anyNamed("headers")))
        .thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHttpClientFailure404() {
    when(mockHttpClient?.get(any, headers: anyNamed("headers")))
        .thenAnswer((_) async => http.Response("Something went wrong", 404));
  }

  group("getConcreteNumberTrivia", () {
    final tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test(
      '''should perform a GET request on a URL with number being the endpoint and with application/json header''',
      () async {
        setUpMockHttpClientSuccess200();
        dataSource?.getConcreteNumberTrivia(tNumber);
        verify(mockHttpClient?.get(Uri.parse("http://numbersapi.com/$tNumber"),
            headers: {'Content-Type': 'application/json'}));
      },
    );

    test("should return Number Trivia when the response code is 200 (success",
        () async {
      setUpMockHttpClientSuccess200();

      final result = await dataSource?.getConcreteNumberTrivia(tNumber);
      expect(result, equals(tNumberTriviaModel));
    });

    test(
        "should throw a ServerException when the response code is 404 or other",
        () async {
      setUpMockHttpClientFailure404();
      final call = dataSource?.getConcreteNumberTrivia;
      expect(() => call!(tNumber), throwsA(TypeMatcher<ServerException>()));
    });
  });

  group(
    "getRandomNumberTrivia",
    () {
      final tNumberTriviaModel =
          NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

      test(
        '''should perform a GET request on a URL with number being the endpoint and with application/json header''',
        () async {
          setUpMockHttpClientSuccess200();
          dataSource?.getRandomNumberTrivia();
          verify(mockHttpClient?.get(Uri.parse("http://numbersapi.com/random"),
              headers: {'Content-Type': 'application/json'}));
        },
      );

      test("should return Number Trivia when the response code is 200 (success",
          () async {
        setUpMockHttpClientSuccess200();

        final result = await dataSource?.getRandomNumberTrivia();
        expect(result, equals(tNumberTriviaModel));
      });

      test(
        "should throw a ServerException when the response code is 404 or other",
        () async {
          setUpMockHttpClientFailure404();
          final call = dataSource?.getRandomNumberTrivia();
          expect(() => call, throwsA(TypeMatcher<ServerException>()));
        },
      );
    },
  );
}
