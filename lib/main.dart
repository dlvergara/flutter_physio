import 'Util/BluetoothClass.dart';

import 'Pages/HomePage.dart';
import 'Pages/ConfigPage.dart';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() {
  runApp(MyApp());
}

//Search for device
Future<bool> searchDevice(BluetoothClass bluetoothObj) {
  return Future.delayed(Duration(seconds: 4), () {
    bool res = false;
    try {
      bluetoothObj.scanForDevices().then((value) {
        res = value;
      });
    } catch (err) {
      print('Caught error: $err');
    }
    return res;
  });
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    FlutterBlue flutterBlue = FlutterBlue.instance;
    BluetoothClass bluetoothObj = new BluetoothClass(flutterBlue);

    //searchDevice(bluetoothObj);

    ConfigPage confPage = ConfigPage(
      appBarTitle: 'Configuración',
      btlContainer: bluetoothObj,
    );
    MyHomePage pagHome = MyHomePage(
      title: 'Bienvenido',
      appBarTitle: 'Physio Bot',
      btlContainer: bluetoothObj,
      configPageObj: confPage,
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
