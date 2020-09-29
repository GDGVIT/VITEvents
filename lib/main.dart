import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import './screens/loginPage.dart';
import 'services/shared.dart';

void main() async {
  await DotEnv().load('.env');
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    Shared.initShared();
    //B4:2E:FF:1F:F9:2C:6F:24:6A:0E:29:FF:D3:0B:AE:CE:C7:80:BA:24
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: Color(0xff1abc9c),
      debugShowCheckedModeBanner: false,
      title: 'Events App',
      theme: ThemeData(),
      home: LoginPage(),
    );
  }
}
