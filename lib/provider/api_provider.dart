import 'package:hava/constant.dart';
import 'package:dio/dio.dart';
import 'custom_exception.dart';
import 'response_data.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

class ApiProvider{
  final Dio _dio = Dio();

  Future<Response> getForecast(double lan, double long) async {
    String _endpoint = "https://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$lan,$long&days=7";
    Response response;
    try {
      response = await _dio.get(_endpoint);
    } on Error catch (e) {
      throw Exception('Failed to load post ' + e.toString());
    }
    return response;
  }
}