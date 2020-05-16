import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

import '../Util/BluetoothClass.dart';

class LocalTraining extends StatefulWidget {
  LocalTraining({Key key, this.btObj}) : super(key: key);
  BluetoothClass btObj;

  @override
  _LocalTrainingState createState() => _LocalTrainingState();
}

class _LocalTrainingState extends State<LocalTraining> {
  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String chanelOne = "";

  void stop() {
    if (widget.btObj.connection.isConnected) {
      widget.btObj.connection.close();
    }
  }

  void receiveData() {
    try {
      print('receive data > ');
      widget.btObj.connection.input.listen((data) {
        String incomeData = ascii.decode(data);
        if (incomeData == ".00") {
          incomeData = "0";
        }
        //print('Data incoming: ${ascii.decode(data)}');
        print('Data incoming: ${incomeData}');
        setState(() {
          chanelOne = incomeData;//int.parse();
        });
        //widget.btObj.connection.output.add(data); // Sending data
        if (incomeData.contains('|')) {
          widget.btObj.connection.finish(); // Closing connection
          print('Disconnecting by local host');
        }
      }).onDone(() {
        print('Disconnected by remote request');
        stop();
      });
    } catch (exception) {
      print('Cannot connect, exception occured');
    }
  }

  void start() {
    print('Start receiving...');
    if (!widget.btObj.isConnected) {
      print('Request connection');
      var value = widget.btObj.connectToPhysioBot();
      print(value);
    }
    receiveData();
  }

  @override
  void initState() {
    super.initState();
    start();
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }

  void _changeAction() {
    print("Cambiar de accion");
  }

  // Now, its time to build the UI
  @override
  Widget build(BuildContext context) {

    Icon icon = Icon(
      Icons.devices,
      color: Colors.red,
      size: 24.0,
      semanticLabel: "",
    );

    Text titleText = Text('Recibir info');
    Text subText = Text("sub");

    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Entrenamiento en casa"),
          backgroundColor: Colors.greenAccent,
          actions: <Widget>[
            FlatButton.icon(
              icon: Icon(
                Icons.refresh,
                color: Colors.white,
              ),
              label: Text(
                "Refresh",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              splashColor: Colors.deepPurple,
              onPressed: null,
            ),
          ],
        ),
        body: ListView(
          children: <Widget>[
            Card(
              child: ListTile(
                leading: icon,
                title: titleText,
                subtitle: subText,
                onTap: _changeAction,
              ),
            ),
            Card(
              child: ListTile(
                title: Text(chanelOne),
              ),
            ),
          ],
        ),
      ),
    );
  }
}