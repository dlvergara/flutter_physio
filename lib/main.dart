import 'package:dav/Pages/BtConfigPage.dart';

import 'Util/BluetoothLEClass.dart';
import 'Pages/HomePage.dart';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  //Root

  @override
  Widget build(BuildContext context) {
    FlutterBlue flutterBlue = FlutterBlue.instance;

    BluetoothLEClass bluetoothObj = new BluetoothLEClass(flutterBlue);
    bool connectionStatus = false;

    /*
    ConfigPage confPage = ConfigPage(
      appBarTitle: 'Configuración',
      btlContainer: bluetoothObj,
    );
    */
    BtConfigPage confPage = BtConfigPage();

    MyHomePage pagHome = MyHomePage(
      title: 'Bienvenido',
      appBarTitle: 'Physio Bot',
      btlContainer: bluetoothObj,
      configPageObj: confPage,
      //configPageObj: confPage,
      connectionStatus: connectionStatus,
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