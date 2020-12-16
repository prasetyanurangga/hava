import 'dart:async';

import 'package:hava/bloc/hava/hava_event.dart';
import 'package:hava/bloc/hava/hava_state.dart';
import 'package:hava/models/hava_model.dart';
import 'package:hava/provider/response_data.dart';
import 'package:hava/repository/hava_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

class HavaBloc extends Bloc<HavaEvent, HavaState> {
  HavaRepository havaRepository = HavaRepository();

  HavaBloc() : super(HavaInitial());

  @override
  HavaState get initialState =>HavaInitial();

  @override
  Stream<HavaState> mapEventToState(HavaEvent event) async* {
    if (event is GetForecast) { 
      print("Test");
      yield HavaLoading();
      try {
        final ResponseData<dynamic> response = await havaRepository.getForecasts(event.latitude, event.longitude);
        if (response.status == Status.ConnectivityError) {
          yield const HavaFailure(error: "");
        }
        if (response.status == Status.Success) {
          print(response.data);
          yield HavaSuccess(havaModel: response.data);
        } else {
          yield HavaFailure(error: response.message);
        }
      } catch (error) {
        // print(error);
        yield HavaFailure(error: error.toString());
      }
    }
  }
}