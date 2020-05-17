import 'package:dav/BtConfigPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Util/BluetoothClass.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'LocalTraining.dart';

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
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

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

    if (!widget.btObj.isConnected) {
      if (widget.btObj.device == null) {
        _processStatus = 0;
        widget.btObj.deviceState = 0; // neutral

        // Get current state
        FlutterBluetoothSerial.instance.state.then((state) {
          setState(() {
            widget.btObj.bluetoothState = state;
          });
        });

        // If the bluetooth of the device is not enabled,
        // then request permission to turn on bluetooth
        // as the app starts up
        widget.btObj.enableBluetooth();

        // Listen for further state changes
        FlutterBluetoothSerial.instance
            .onStateChanged()
            .listen((BluetoothState state) {
          setState(() {
            widget.btObj.bluetoothState = state;

            if (widget.btObj.bluetoothState == BluetoothState.STATE_OFF) {
              _processStatus = 3;
            }

            widget.btObj.getPairedDevices();

            // It is an error to call [setState] unless [mounted] is true.
            if (!this.mounted) {
              return;
            }
          });
        });
      } else {
        widget.btObj.connectToPhysioBot();
      }
    }
    print("Connection status: " + this.widget.btObj.isConnected.toString());
  }

  //Search for device
  Future<void> _searchDevice() async {

    print("click! -> " + widget.btObj.isConnected.toString());

    if (!widget.btObj.isConnected) {

      setState(() {
        print("cambio de estado");
        _processStatus = 2;
      });

      try {
        //var value = await widget.btlContainer.scanForDevices();
        await widget.btObj.getPairedDevices();
        var value = await widget.btObj.connectToPhysioBot();
        var ps = 0;
        if(value == true) {
          ps = 1;
        }
        print("guardando estado value "+value.toString());
        setState(() {
          _processStatus = ps;
        });
      } catch (err) {
        setState(() {
          _processStatus = 0;
        });
        print('Caught error: $err');
      }
    } else {
      setState(() {
        _processStatus = 1;
      });
      /*
      await widget.btObj.disconnect();
      if (widget.btObj.device != null) {
        show('Desconectado');
      }
      setState(() {
        _processStatus = 0;
        //widget.connectionStatus = false;
      });
      */
    }
  }

  // Method to show a Snackbar
  Future show(
      String message, {
        Duration duration: const Duration(seconds: 3),
      }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: new Text(
          message,
        ),
        duration: duration,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    Color localTrainingIconColor = Colors.grey;

    BtConfigPage btConfig = BtConfigPage();
    LocalTraining localTrainingPage = LocalTraining(btObj: this.widget.btObj,key: this.widget.key,);

    var appBar = AppBar(
      centerTitle: false,
      title: Row(children: <Widget>[
        Text(widget.appBarTitle),
        RaisedButton.icon(
            onPressed: () {
              print('Saltar a config');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => btConfig),
              );
            },
            icon: Icon(Icons.settings),
            label: Text('')),
      ]),
    );

    var textStatus = "Conectado";

    if (!widget.btObj.isConnected) {
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
        localTrainingIconColor = Colors.green;
        break;
      case 3:
        _btIcon = Icon(
          Icons.bluetooth_disabled,
          color: Colors.grey,
          size: 24.0,
          semanticLabel: "No disponible",
        );
        textStatus = "No disponible";
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
              color: localTrainingIconColor,
              size: 24.0,
              semanticLabel: textStatus,
            ),
            title: Text('Entrenamiento Local'),
            subtitle: Text("Entrenar con tu telefono"),
            onTap:  () {
              print('Saltar!!');
              if (widget.btObj.device != null) {
                print('Saltar a local!');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => localTrainingPage),
                );
              } else {
                print('Saltar!!');
                show("No hay dispositivo conectado");
              }
            },
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
            onTap: () {
              print("Entrenamiento en linea");
            },
          ),
        ),
      ],
    );

    return Scaffold(
      key: _scaffoldKey,
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
