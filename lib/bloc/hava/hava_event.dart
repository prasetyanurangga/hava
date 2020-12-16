import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

abstract class HavaEvent extends Equatable {
  const HavaEvent();
  @override
  List<Object> get props => [];
}

class GetForecast extends HavaEvent {
	final double latitude;
	final double longitude;
  	GetForecast({
  		@required this.latitude, 
  		@required this.longitude
  	});
}