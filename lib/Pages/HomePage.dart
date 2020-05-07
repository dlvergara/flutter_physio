import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Util/BluetoothClass.dart';
import 'ConfigPage.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage(
      {Key key,
      this.title,
      this.appBarTitle,
      this.btlContainer,
      this.configPageObj,
      this.connectionStatus})
      : super(key: key);

  final String title;
  final String appBarTitle;
  final BluetoothClass btlContainer;
  bool connectionStatus;
  ConfigPage configPageObj;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _processStatus = 0;
  var _btIcon = Icon(
    Icons.bluetooth_disabled,
    color: Colors.red,
    size: 24.0,
    semanticLabel: "",
  );

  @override
  void initState() {
    super.initState();
    widget.connectionStatus = false;
    _processStatus = 0;
  }

  //Search for device
  void _searchDevice() {
    print("click! -> " + widget.connectionStatus.toString());

    setState(() {
      _processStatus = 2;
    });

    if (!widget.connectionStatus) {
      Future.delayed(Duration(seconds: 5), () {
        try {
          widget.btlContainer.scanForDevices().then((value) {
            print("Response BT: " + value.toString());
            setState(() {
              widget.connectionStatus = value;
              if(value) {
                _processStatus = 1;
              } else {
                _processStatus = 0;
              }
            });
          });
        } catch (err) {
          widget.connectionStatus = false;
          print('Caught error: $err');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    var appBar = AppBar(
      centerTitle: false,
      title: Row(children: <Widget>[
        Text(widget.appBarTitle),
        RaisedButton.icon(
            onPressed: () {
              print('Saltar a config');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => widget.configPageObj),
              );
            },
            icon: Icon(Icons.settings),
            label: Text('')),
      ]),
    );

    var textStatus = "Conectado";

    print("state: " + widget.connectionStatus.toString());
    if (!widget.connectionStatus) {
      textStatus = "Desconectado";
    }

    switch(_processStatus){
      case 0:
        _btIcon = Icon(
          Icons.bluetooth_disabled,
          color: Colors.red,
          size: 24.0,
          semanticLabel: "Desconectado",
        );
        break;
      case 1:
        _btIcon = Icon(
          Icons.bluetooth_connected,
          color: Colors.green,
          size: 24.0,
          semanticLabel: "Conectado",
        );
        break;
      case 2:
        _btIcon = Icon(
          Icons.bluetooth_searching,
          color: Colors.blue,
          size: 24.0,
          semanticLabel: "Conectando...",
        );
        textStatus = "Conectando...";
        break;
    }

    var listObject = ListView(
      //padding: const EdgeInsets.all(8),
      children: <Widget>[
        Card(
          child: ListTile(
            leading: _btIcon,
            title: Text('Conexión con el dispositivo:'),
            subtitle: Text(textStatus),
            onTap: _searchDevice,
            //trailing: Icon(Icons.more_vert),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(
              Icons.phonelink_lock,
              //color: colorDevice,
              size: 24.0,
              semanticLabel: textStatus,
            ),
            title: Text('Entrenamiento Local'),
            subtitle: Text("Entrenar con tu telefono"),
            onTap: null,
            //trailing: Icon(Icons.more_vert),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(
              Icons.phonelink,
              //color: colorDevice,
              size: 24.0,
              semanticLabel: "Entrenamiento remoto",
            ),
            title: Text('Entrenamiento Remoto'),
            subtitle: Text("Entrenar usando internet"),
            onTap: null,
            //trailing: Icon(Icons.more_vert),
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: appBar,
      body: listObject,
      /*
      floatingActionButton: FloatingActionButton(
        onPressed: _searchDevice,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
      */
    );
  }
}
