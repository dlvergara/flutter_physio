import 'Util/BluetoothClass.dart';
import 'Pages/HomePage.dart';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    BluetoothClass btObj = BluetoothClass();

    MyHomePage pagHome = MyHomePage(
      title: 'Bienvenido',
      appBarTitle: 'Physio Bot',
      btObj: btObj,
    );

    MaterialApp mainApp = MaterialApp(
      title: 'Physio Bot',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: pagHome,
    );

    return mainApp;
  }
}