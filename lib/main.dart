import 'package:flutter/material.dart';
import 'package:hava/screens/splash_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hava/constant.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hava/bloc/hava/hava_bloc.dart';
import 'package:hava/provider/api_provider.dart';
import 'package:flutter/services.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitDown,DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context)  => HavaBloc(),
      child: MaterialApp(
        title: 'Hava',
        theme: ThemeData(
          textTheme: GoogleFonts.poppinsTextTheme(
              Theme.of(context).textTheme.apply(bodyColor: colorDayText)),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SplashPage(),
      ),
    );
  }
}
