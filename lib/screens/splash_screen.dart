import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';
import 'package:hava/constant.dart';
import 'package:hava/screens/home_screen.dart';
import 'package:intl/intl.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  AnimationController fadeController;
  Animation<double> animation;
  Color currentBackcolor;
  Color currentTextcolor;
  bool isDay;

  @override
  void initState() {
    super.initState();
    fadeController = AnimationController(duration: const Duration(seconds: 1), vsync: this);
    animation = CurvedAnimation(parent: fadeController, curve: Curves.easeIn);
    final now = new DateTime.now();
    int hourNow = int.parse(DateFormat('H').format(now));// 28/03/2020
    print(hourNow);       
    isDay = !((hourNow >= 18 && hourNow <= 23) || hourNow == 0 || (hourNow >= 1 && hourNow <= 6));
    currentBackcolor = ((hourNow >= 18 && hourNow <= 23) || hourNow == 0 || (hourNow >= 1 && hourNow <= 6)) ? colorNightBack : colorDayBack;
    currentTextcolor = ((hourNow >= 18 && hourNow <= 23) || hourNow == 0 || (hourNow >= 1 && hourNow <= 6)) ? colorNightText : colorDayText;
    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => HomePage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ));
      }
    });
    fadeController.forward();
  }

  @override
  void dispose() {
    super.dispose();
    fadeController.dispose();
  }

  Future<bool> _willPopCallback() async {
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: currentBackcolor,
        body: FadeTransition(
          opacity: animation,
          child: Center(
            child: Column(
              children:[
                Spacer(),
                BoxedIcon(isDay ? WeatherIcons.day_cloudy : WeatherIcons.night_cloudy, color: currentTextcolor, size: 100),
                Text("hava\u00B0", style: Theme.of(context).textTheme.headline3.copyWith(color: currentTextcolor, fontWeight: FontWeight.w900)),
                Spacer(),
              ]
            ),
          ),
        ),
      ), 
      onWillPop: _willPopCallback
    );
  }
}


