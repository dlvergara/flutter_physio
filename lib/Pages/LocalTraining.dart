import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  void listenData(data) {
    String incomeData = ascii.decode(data);
    //Map<String, dynamic> incomingData = jsonDecode(incomeData);
    print('incoming: ${incomeData}');

    // It is an error to call [setState] unless [mounted] is true.
    if (!this.mounted) {
      return;
    }
    setState(() {
      chanelOne = incomeData;
    });
    //widget.btObj.connection.output.add(data); // Sending data
    if (incomeData.contains('|')) {
      widget.btObj.connection.finish(); // Closing connection
      print('Disconnecting by local host');
    }
  }

  void doneStream() {
    print('Disconnected by remote request');
    widget.btObj.stopStreaming();
  }

  void receiveData() {
    try {
      print('receive data > ');
      if (widget.btObj.streamData == null) {
        widget.btObj.streamData = widget.btObj.connection.input.listen(listenData,onDone: doneStream);
      } else {
        widget.btObj.streamData.resume();
      }
    } catch (exception) {
      print('Cannot connect, exception occured');
    }
  }

  void start() {
    print('Start receiving...');
    if (!widget.btObj.isConnected) {
      if ( widget.btObj.streamData != null ) {
        widget.btObj.streamData.resume();
      } else {
        receiveData();
      }
    } else {
      print('Request connection');
      var value = widget.btObj.connectToPhysioBot().then((value) {
        receiveData();
      });
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
    widget.btObj.stopStreaming();
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