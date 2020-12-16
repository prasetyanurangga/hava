import 'package:hava/models/hava_model.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class HavaState extends Equatable {
  const HavaState();

  @override
  List<Object> get props => [];
}

class HavaInitial extends HavaState {}

class HavaLoading extends HavaState {}

class HavaSuccess extends HavaState {
  final HavaModel havaModel;

  HavaSuccess({@required this.havaModel});

}

class HavaFailure extends HavaState {
  final String error;

  const HavaFailure({@required this.error});

  @override
  List<Object> get props => [error];

  @override
  String toString() => 'HavaFailure { error: $error }';
}
