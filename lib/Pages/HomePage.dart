import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Util/BluetoothClass.dart';
import '../States/MyHomePageState.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage(
      { Key key,
        this.title,
        this.appBarTitle,
        this.btObj
      })
      : super(key: key);

  final String title;
  final String appBarTitle;
  BluetoothClass btObj;

  @override
  MyHomePageState createState() => MyHomePageState();
}