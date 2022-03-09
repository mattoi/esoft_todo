import 'package:flutter/material.dart';
import 'package:todo/constants.dart';
import 'package:todo/screens/main_page_mobile.dart';

void main() => runApp(const ToDoApp());

class ToDoApp extends StatelessWidget {
  const ToDoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: UITextStrings.appName,
      theme: appTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const MainPageMobile(),
      },
    );
  }
}
