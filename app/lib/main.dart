
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timeline/bloc_provider.dart';
import 'package:timeline/colors.dart';
import 'package:timeline/main_menu/main_menu.dart';

/// The app is wrapped by a [BlocProvider]. This allows the child widgets
/// to access other components throughout the hierarchy without the need
/// to pass those references around.
class TimelineApp extends StatelessWidget {
  const TimelineApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return BlocProvider(
      platform: Theme.of(context).platform,
      child: MaterialApp(
        title: 'History & Future of Everything',
        theme: ThemeData(scaffoldBackgroundColor: background),
        home: const MenuPage(),
      ),
    );
  }
}

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(appBar: null, body: MainMenuWidget());
  }
}

void main() => runApp(const TimelineApp());