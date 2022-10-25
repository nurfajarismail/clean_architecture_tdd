import 'package:bloc/bloc.dart';
import 'package:clean_architecture_tdd/core/error/failure.dart';
import 'package:clean_architecture_tdd/core/usecases/usecase.dart';
import 'package:clean_architecture_tdd/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../core/util/input_converter.dart';
import '../../domain/usecases/get_concrete_number_trivia.dart';
import '../../domain/usecases/get_random_number_trivia.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String INVALID_INPUT_FAILURE_MESSAGE =
    'Invalid Input - The number must be a positive integer or zero.';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc({
    // Changed the name of the constructor parameter (cannot use 'this.')
    required GetConcreteNumberTrivia concrete,
    required GetRandomNumberTrivia random,
    required this.inputConverter,
    // Asserts are how you can make sure that a passed in argument is not null.
    // We omit this elsewhere for the sake of brevity.
  })  : assert(concrete != null),
        assert(random != null),
        assert(inputConverter != null),
        getConcreteNumberTrivia = concrete,
        getRandomNumberTrivia = random,
        super(Empty()) {
    on<NumberTriviaEvent>((event, emit) async {
      if (event is GetTriviaForConcreteNumber) {
        final inputEither =
            inputConverter.stringToUnsignedInteger(event.numberString);

        inputEither.fold(
          (failure) async {
            emit(Error(message: INVALID_INPUT_FAILURE_MESSAGE));
          },
          // Although the "success case" doesn't interest us with the current test,
          // we still have to handle it somehow.
          (integer) async {
            emit(Loading());
            final failureOrTrivia = await getConcreteNumberTrivia(
              Params(number: integer),
            );
            _eitherLoadedOrErrorState(failureOrTrivia, emit);
          },
        );
      } else if (event is GetTriviaForRandomNumber) {
        emit(Loading());
        final failureOrTrivia = await getRandomNumberTrivia(
          NoParams(),
        );
        _eitherLoadedOrErrorState(failureOrTrivia, emit);
      }
    });
  }

  String _mapFailureToMessage(Failure failure) {
    // Instead of a regular 'if (failure is ServerFailure)...'
    switch (failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case CacheFailure:
        return CACHE_FAILURE_MESSAGE;
      default:
        return 'Unexpected Error';
    }
  }

  void _eitherLoadedOrErrorState(
    Either<Failure, NumberTrivia> either,
    Emitter<NumberTriviaState> emit,
  ) {
    either.fold(
      (failure) => emit(Error(message: _mapFailureToMessage(failure))),
      (trivia) => emit(Loaded(trivia: trivia)),
    );
  }
}
