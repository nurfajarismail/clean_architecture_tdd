import 'package:equatable/equatable.dart';

class NumberTrivia extends Equatable {
  const NumberTrivia({
    required this.text,
    required this.number,
  });

  final String text;
  final int number;

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}
