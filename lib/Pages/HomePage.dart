import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Util/BluetoothClass.dart';
import 'BtSetting.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage(
      {Key key,
      this.title,
      this.appBarTitle,
      this.btlContainer,
      //this.configPageObj,
      this.connectionStatus})
      : super(key: key);

  final String title;
  final String appBarTitle;
  final BluetoothClass btlContainer;
  bool connectionStatus;
  //ConfigPage configPageObj;
  SettingsBtPage settingsPage = SettingsBtPage();

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
  Future<void> _searchDevice() async {
    print("click! -> " + widget.connectionStatus.toString());

    if (!widget.connectionStatus) {

      setState(() {
        print("cambio de estado");
        _processStatus = 2;
      });
      try {
        var value = await widget.btlContainer.scanForDevices();
        /*
        widget.btlContainer.scanForDevices().then((value) {
          print("Response BT: " + value.toString());
          var ps = 0;
          if(value) {
            ps = 1;
          }
          setState(() {
            widget.connectionStatus = value;
            _processStatus = ps;
          });
        });
         */
        var ps = 0;
        if(value) {
          ps = 1;
        }
        print("guardando estado value "+value.toString());
        setState(() {
          widget.connectionStatus = value;
          _processStatus = ps;
        });
      } catch (err) {
        setState(() {
          widget.connectionStatus = false;
          _processStatus = 0;
        });
        print('Caught error: $err');
      }
    } else {

      if (widget.btlContainer.device != null) {
        widget.btlContainer.device.disconnect();
      }

      setState(() {
        _processStatus = 0;
        widget.connectionStatus = false;
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
                MaterialPageRoute(builder: (context) => widget.settingsPage),
              );
            },
            icon: Icon(Icons.settings),
            label: Text('')),
      ]),
    );

    var textStatus = "Conectado";

    print("state: " + widget.connectionStatus.toString());
    print("ps-state: " + _processStatus.toString());
    if (!widget.connectionStatus) {
      textStatus = "Desconectado";
      if(_processStatus == 1 ) {
        _processStatus = 0;
      }
    }
    print("ps-state: " + _processStatus.toString());

    switch(_processStatus)
    {
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
      children: <Widget>[
        Card(
          child: ListTile(
            leading: _btIcon,
            title: Text('Conexión con el dispositivo:'),
            subtitle: Text(textStatus),
            onTap: _searchDevice,
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
            onTap: _searchDevice,
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
