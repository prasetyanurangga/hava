import 'package:hava/models/hava_model.dart';
import 'package:hava/provider/response_data.dart';
import 'package:hava/provider/api_provider.dart';
import 'package:dio/dio.dart';
import 'dart:async';

class HavaRepository{
  ApiProvider _apiProvider = ApiProvider();

  Future<ResponseData> getForecasts(double lan, double long) async{
  	Response response = await _apiProvider.getForecast(lan, long);
  	HavaModel responseJust = HavaModel.fromJson(response.data);
  	if (responseJust == null) {
      return ResponseData.connectivityError();
    }

    if (response.statusCode == 200) {
      return ResponseData.success(responseJust);
    } else {
      return ResponseData.error("Error");
    }
  }


}