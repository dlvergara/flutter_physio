import 'package:dav/BtConfigPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Util/BluetoothClass.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

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

    widget.btObj.connected = false;
    _processStatus = 0;

    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        widget.btObj.bluetoothState = state;
      });
    });

    widget.btObj.deviceState = 0; // neutral

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
  }

  //Search for device
  Future<void> _searchDevice() async {

    print("click! -> " + widget.btObj.connected.toString());

    if (!widget.btObj.connected) {

      setState(() {
        print("cambio de estado");
        _processStatus = 2;
      });

      try {
        //var value = await widget.btlContainer.scanForDevices();
        await widget.btObj.getPairedDevices();
        var value = await widget.btObj.connectToPhysioBot();
        var ps = 0;
        if(value) {
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
      await widget.btObj.disconnect();
      if (widget.btObj.device != null) {
        show('Desconectado');
      }
      setState(() {
        _processStatus = 0;
        //widget.connectionStatus = false;
      });
    }
  }

  // Method to show a Snackbar,
  // taking message as the text
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
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    BtConfigPage btConfig = BtConfigPage();

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

    //print("state: " + widget.connectionStatus.toString());
    //print("ps-state: " + _processStatus.toString());
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
