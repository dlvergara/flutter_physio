import 'package:dav/Util/BluetoothClass.dart';
import 'package:flutter/material.dart';
import 'Pages/PhysioAppHome.dart';

void main() {
  runApp(BtConfigPage());
}

class BtConfigPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    BluetoothClass btObj = BluetoothClass();

    return MaterialApp(
      title: 'Bienvenido',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BluetoothApp(btObj: btObj,),
    );
  }
}
