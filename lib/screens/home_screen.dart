import 'package:flutter/material.dart';
import 'package:hava/models/hava_model.dart';
import 'package:bloc/bloc.dart';
import 'package:hava/constant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hava/bloc/hava/hava_bloc.dart';
import 'package:hava/bloc/hava/hava_event.dart';
import 'package:hava/bloc/hava/hava_state.dart';
import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:intl/intl.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:loader_overlay/loader_overlay.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  String lokasi = "";
  AnimationController rotationController;
  Position currentPosition;
  String currentWeather = "-";
  String currentAddress = "-";
  Color currentBackcolor;
  Color currentTextcolor;
  bool isSearch = false;
  HavaModel currentData;
  List<Forecastday> listForecastday = List<Forecastday>();
  double currentTempCelcius = 0;
  double currentTempFahrenheit = 0;
  int currentCode = 1000;
  final _drawerController = ZoomDrawerController();
  bool isCelcius = true;
  int isDay = 1;

  @override
  void initState() {
    super.initState();
    rotationController = AnimationController(duration: const Duration(seconds: 5), vsync: this);
    final now = new DateTime.now();
    int hourNow = int.parse(DateFormat('H').format(now));// 28/03/2020
    print(hourNow);       
    currentBackcolor = ((hourNow >= 18 && hourNow <= 23) || hourNow == 0 || (hourNow >= 1 && hourNow <= 6)) ? colorNightBack : colorDayBack;
    currentTextcolor = ((hourNow >= 18 && hourNow <= 23) || hourNow == 0 || (hourNow >= 1 && hourNow <= 6)) ? colorNightText : colorDayText;
    getData();
  }

  void getData(){
    _determinePosition().then((Position position) {
      setState((){
        currentPosition = position;
        lokasi = "${position.latitude}, ${position.longitude}";
      });
      BlocProvider.of<HavaBloc>(context).add(
        GetForecast(
          latitude:position.latitude,
          longitude:position.longitude
        ),
      );
      _getAddressFromLatLng();
      print("${position.latitude}, ${position.longitude}");
    }).catchError((e) {
      final snackBar = SnackBar(content: Text(e));
      Scaffold.of(context).showSnackBar(snackBar);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(
          currentPosition.latitude, currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        currentAddress = place.subLocality;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  void dispose() {
    super.dispose();
    rotationController.dispose();
  }

  Future<bool> _willPopCallback() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: ZoomDrawer(
        controller: _drawerController,
        menuScreen: Scaffold(
          backgroundColor: (currentBackcolor == colorNightBack) ? colorDayBack : colorNightBack,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Spacer(),
                GestureDetector(
                  onTap: (){
                      _drawerController.toggle();
                      setState((){
                          isCelcius = true;
                      });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only( bottom: 36.0, left: 36.0, right: 36.0),
                    child: Column(
                        children:[
                          Text(
                            "\u00B0C",
                            style: Theme.of(context).textTheme.headline2.copyWith(
                              color: (currentTextcolor == colorNightText) ? colorDayText : colorNightText,
                              fontWeight:FontWeight.w900,
                            ),
                          ),
                          AnimatedOpacity(
                            opacity: isCelcius ? 1.0 : 0.0,
                            duration: Duration(milliseconds: 500),
                            child: Container(
                              height: 5,
                              width: 10,
                              decoration: BoxDecoration(
                                color: (currentTextcolor == colorNightText) ? colorDayText : colorNightText,
                                borderRadius: BorderRadius.circular(20)
                              ) 
                            )
                          )
                        ]
                    )
                  ),
                ),
                GestureDetector(
                  onTap: (){
                      _drawerController.toggle();
                      setState((){
                          isCelcius = false;
                      });
                  },
                  child: Container(
                    padding: const EdgeInsets.only( bottom: 36.0, left: 36.0, right: 36.0),
                    child: Column(
                      children:[
                        Text(
                          "\u00B0F",
                          style: Theme.of(context).textTheme.headline2.copyWith(
                            color: (currentTextcolor == colorNightText) ? colorDayText : colorNightText,
                            fontWeight:FontWeight.w900,
                          ),
                        ),
                        AnimatedOpacity(
                          opacity: !isCelcius ? 1.0 : 0.0,
                          duration: Duration(milliseconds: 500),
                          child: Container(
                            height: 5,
                            width: 10,
                            decoration: BoxDecoration(
                              color: (currentTextcolor == colorNightText) ? colorDayText : colorNightText,
                              borderRadius: BorderRadius.circular(20)
                            ) 
                          )
                        )
                      ]
                    )
                  ),
                ),
                Spacer(),
              ],
            ),
          ),
        ),
        mainScreen: LoaderOverlay(
          overlayWidget: Center(
            child: Container(
              padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: (currentBackcolor == colorNightBack) ? colorDayBack : colorNightBack,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 5,
                      blurRadius: 10,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: SizedBox(
                  height: 70,
                  child: new AnimatedBuilder(
                    animation: rotationController,
                    child: BoxedIcon(WeatherIcons.day_sunny, color: (currentTextcolor == colorNightText) ? colorDayText : colorNightText, size: 50),
                    builder: (BuildContext context, Widget _widget) {
                      return new Transform.rotate(
                        angle: rotationController.value * 6.3,
                        child: _widget,
                      );
                    },
                  ),
                )
            ),
          ),
          overlayColor : Colors.black.withOpacity(0.8),
          overlayOpacity: 1,
          child: Scaffold(
            backgroundColor: currentBackcolor,
            body:  SafeArea(
              child: Container(
                padding: EdgeInsets.all(40),
                color: currentBackcolor,
                child: BlocListener<HavaBloc, HavaState>(
                  listener: (context, state) {
                    if(state is HavaLoading)
                    {
                      rotationController.repeat();
                      context.showLoaderOverlay();
                      print("Loading");
                    }

                    else if(state is HavaFailure){
                      context.hideLoaderOverlay();
                      print(state.error);
                      final snackBar = SnackBar(content: Text("Oops, Something Wrong"));
                      Scaffold.of(context).showSnackBar(snackBar);
                    }

                    else if(state is HavaSuccess)
                    {

                      context.hideLoaderOverlay();
                      print(state.havaModel);
                      setState((){
                        currentData = state.havaModel;
                        currentTempCelcius = state.havaModel.current.tempC;
                        currentTempFahrenheit =  state.havaModel.current.tempF;
                        currentWeather = state.havaModel.current.condition.text;
                        currentCode = state.havaModel.current.condition.code;
                        listForecastday = state.havaModel.forecast.forecastday;
                        isDay = state.havaModel.current.isDay;
                        currentBackcolor = (isDay==1) ? colorDayBack : colorNightBack;
                        currentTextcolor = (isDay==1) ? colorDayText : colorNightText;
                        listForecastday.removeAt(0);
                        print(listForecastday.length);
                      });
                      print(state.havaModel.current.condition.code);
                    }
                  },
                  child: Center(
                    child : Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children :[
                            Row(
                                children : [
                                  Expanded(
                                      child: Text(currentAddress, style: Theme.of(context).textTheme.headline6.copyWith(color: currentTextcolor, fontWeight: FontWeight.w900)),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.thermostat_outlined, color: currentTextcolor),
                                    onPressed: (){
                                      _drawerController.toggle();
                                      // getData();
                                    }
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.refresh_outlined, color: currentTextcolor),
                                    onPressed: (){
                                      getData();
                                    }
                                  )
                                ]
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text("Today", style: Theme.of(context).textTheme.bodyText1.copyWith(color: currentTextcolor, fontWeight: FontWeight.normal)),
                            ),
                          ]
                        ),
                        Column(
                          children:[
                            BoxedIcon(getWeatherIcon(currentCode), color: currentTextcolor, size: 100),
                            SizedBox(height: 2.5),
                            Text(currentWeather, style: Theme.of(context).textTheme.bodyText1.copyWith(color: currentTextcolor, fontWeight: FontWeight.normal)),
                            SizedBox(height: 10),
                            Text("${isCelcius ? currentTempCelcius : currentTempFahrenheit}\u00B0", style: Theme.of(context).textTheme.headline3.copyWith(color: currentTextcolor, fontWeight: FontWeight.w900)),
                          ]
                        ),
                        Container(
                          height: 100,
                          // child: LineChartSample5()
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: listForecastday.length,
                            itemBuilder: (context, index) {
                              var day = listForecastday[index].day;
                              var parsedDate = DateTime.parse(listForecastday[index].date);
                              if(index == 0){
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children : [
                                    Expanded(
                                      child: Text("Tomorrow", style: Theme.of(context).textTheme.bodyText1.copyWith(color: currentTextcolor, fontWeight: FontWeight.normal)),
                                    ),
                                    Text("${isCelcius ? day.avgtempC : day.avgtempF}\u00B0", style: Theme.of(context).textTheme.headline6.copyWith(color: currentTextcolor, fontWeight: FontWeight.normal)),
                                    BoxedIcon(getWeatherIcon(day.condition.code), color: currentTextcolor),
                                  ]
                                );
                              }
                              else{
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children : [
                                    Expanded(
                                      child: Text(DateFormat('EEEE').format(parsedDate), style: Theme.of(context).textTheme.bodyText1.copyWith(color: currentTextcolor, fontWeight: FontWeight.normal)),
                                    ),
                                    Text("${isCelcius ? day.avgtempC : day.avgtempF}\u00B0", style: Theme.of(context).textTheme.headline6.copyWith(color: currentTextcolor, fontWeight: FontWeight.normal)),
                                    BoxedIcon(getWeatherIcon(day.condition.code), color: currentTextcolor),
                                  ]
                                );
                              }
                            },
                            separatorBuilder: (context, index) {
                              return Container(
                                height: 3,
                                margin: EdgeInsets.symmetric(vertical: 15),
                                color: currentTextcolor
                              );
                            },
                          )
                        ),
                      ]
                    )
                  )
                )
              )
            )
          )
        ),
        borderRadius: 24.0,
        showShadow: true,
        angle: 0.0,
        backgroundColor: (isDay == 1) ? Colors.grey[300] : Colors.grey[600],
        slideWidth: MediaQuery.of(context).size.width * .45,
        openCurve: Curves.fastOutSlowIn,
        closeCurve: Curves.fastOutSlowIn,
      ), 
      onWillPop: _willPopCallback
    );
  }

  IconData getWeatherIcon(int code){
    var temp;
    if(showers.contains(code)){
      temp = WeatherIcons.showers;
    }

    else if(code == 1003){
      temp = (isDay == 1) ? WeatherIcons.day_cloudy : WeatherIcons.night_cloudy; 
    }

    else if(fog.contains(code)){
      temp = WeatherIcons.fog; 
    }

    else if(day_rain.contains(code)){
      temp = (isDay == 1) ? WeatherIcons.day_rain : WeatherIcons.night_rain; 
    }

    else if(day_snow.contains(code)){
      temp = (isDay == 1) ? WeatherIcons.day_snow : WeatherIcons.night_snow; 
    }

    else if(code == 1069){
      temp = (isDay == 1) ? WeatherIcons.day_sleet : WeatherIcons.night_sleet; 
    }

    else if(day_rain_mix.contains(code)){
      temp = (isDay == 1) ? WeatherIcons.day_rain_mix : WeatherIcons.night_rain_mix; 
    }

    else if(day_lightning.contains(code)){
      temp = (isDay == 1) ? WeatherIcons.day_lightning : WeatherIcons.night_lightning; 
    }

    else if(snow_wind.contains(code)){
      temp = (isDay == 1) ? WeatherIcons.day_snow_wind : WeatherIcons.night_snow_wind ;
    }

    else if(fog.contains(code)){
      temp = (isDay == 1) ? WeatherIcons.day_fog : WeatherIcons.night_fog; 
    }

    else if(drizzle.contains(code)){
      temp = (isDay == 1) ? WeatherIcons.day_sprinkle : WeatherIcons.night_sprinkle; 
    }

    else if(rain.contains(code)){
      temp = (isDay == 1) ? WeatherIcons.day_rain : WeatherIcons.night_rain; 
    }

    else if(hail.contains(code)){
      temp = WeatherIcons.hail; 
    }

    else if(sleet.contains(code)){
      temp = WeatherIcons.sleet; 
    }

    else if(snow.contains(code)){
      temp = WeatherIcons.snow; 
    }

    else if(cloudy.contains(code)){
      temp = WeatherIcons.cloudy; 
    }

    else if(day_shower.contains(code)){
      temp = (isDay == 1) ? WeatherIcons.day_showers : WeatherIcons.night_showers; 
    }

    else if(lightning.contains(code)){
      temp = WeatherIcons.lightning; 
    }

    else if(day_snow_thunderstorm.contains(code)){
      temp = (isDay == 1) ? WeatherIcons.day_snow_thunderstorm : WeatherIcons.night_snow_thunderstorm; 
    }

    else if(storm_showers.contains(code)){
      temp = WeatherIcons.storm_showers; 
    }

    else{
      temp = WeatherIcons.cloudy; 
    }
    return temp; 
  }

}


