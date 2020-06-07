import 'dart:async';
import 'dart:io';
import 'package:dav/BtConfigPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import '../Pages/HomePage.dart';
import '../Util/BluetoothClass.dart';
import '../Pages/LocalTraining.dart';

class MyHomePageState extends State<MyHomePage> {
  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var connectivityResult;
  String _connectionStatus = 'sin conexión';
  ConnectivityResult _connectivityStatus;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  int _processStatus = 0;

  var _btIcon = Icon(
    Icons.bluetooth_disabled,
    color: Colors.red,
    size: 24.0,
    semanticLabel: "",
  );

  // Update connection status function
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    switch (result) {
      case ConnectivityResult.wifi:
        String wifiName, wifiBSSID, wifiIP;

        try {
          if (Platform.isIOS) {
            LocationAuthorizationStatus status =
            await _connectivity.getLocationServiceAuthorization();
            if (status == LocationAuthorizationStatus.notDetermined) {
              status =
              await _connectivity.requestLocationServiceAuthorization();
            }
            if (status == LocationAuthorizationStatus.authorizedAlways ||
                status == LocationAuthorizationStatus.authorizedWhenInUse) {
              wifiName = await _connectivity.getWifiName();
            } else {
              wifiName = await _connectivity.getWifiName();
            }
          } else {
            wifiName = await _connectivity.getWifiName();
          }
        } on PlatformException catch (e) {
          print(e.toString());
          wifiName = "Failed to get Wifi Name";
        }

        try {
          if (Platform.isIOS) {
            LocationAuthorizationStatus status =
            await _connectivity.getLocationServiceAuthorization();
            if (status == LocationAuthorizationStatus.notDetermined) {
              status =
              await _connectivity.requestLocationServiceAuthorization();
            }
            if (status == LocationAuthorizationStatus.authorizedAlways ||
                status == LocationAuthorizationStatus.authorizedWhenInUse) {
              wifiBSSID = await _connectivity.getWifiBSSID();
            } else {
              wifiBSSID = await _connectivity.getWifiBSSID();
            }
          } else {
            wifiBSSID = await _connectivity.getWifiBSSID();
          }
        } on PlatformException catch (e) {
          print(e.toString());
          wifiBSSID = "Failed to get Wifi BSSID";
        }

        try {
          wifiIP = await _connectivity.getWifiIP();
        } on PlatformException catch (e) {
          print(e.toString());
          wifiIP = "Failed to get Wifi IP";
        }

        setState(() {
          this._connectivityStatus = result;
          _connectionStatus = '$result\n'
              'Wifi Name: $wifiName\n';
          //'Wifi BSSID: $wifiBSSID\n'
          //'Wifi IP: $wifiIP\n';
        });
        break;
      case ConnectivityResult.mobile:
      case ConnectivityResult.none:
        setState(() {
          _connectionStatus = result.toString();
          this._connectivityStatus = result;
        });
        break;
      default:
        setState(() {
          _connectionStatus = 'Falló en obtener conectividad';
          this._connectivityStatus = result;
        });
        break;
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print(e.toString());
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  @override
  void dispose() {
    widget.btObj.connection.dispose();
    widget.btObj.disconnect();
    widget.btObj.device = null;

    super.dispose();
  }

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
    print("BT Connection status: " + this.widget.btObj.isConnected.toString());

    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  //Search for device
  Future<void> _searchDevice() async {

    print("click! -> " + widget.btObj.isConnected.toString());

    if (!widget.btObj.isConnected) {

      var ps = 2;
      setState(() {
        print("cambio de estado");
        _processStatus = ps;
      });

      try {
        //var value = await widget.btlContainer.scanForDevices();
        await widget.btObj.getPairedDevices().then((list) {});
        bool value = await widget.btObj.connectToPhysioBot();

        print(value);
        if(value == true) {
          ps = 1;
        } else {
          ps = 2;
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
      } finally {
        print("Compleatdo");
        bool value = this.widget.btObj.isConnected;
        if(value == true) {
          ps = 1;
        } else {
          ps = 2;
        }
        setState(() {
          _processStatus = ps;
        });
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
    Color remoteTrainingIconColor = Colors.grey;

    BtConfigPage btConfig = BtConfigPage();
    LocalTraining localTrainingPage = LocalTraining(btObj: this.widget.btObj,key: this.widget.key,);

    var appBar = AppBar(
        centerTitle: false,
        title: Text(widget.appBarTitle),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              print('Saltar a config');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => btConfig),
              );
            },
          ),
        ]
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
        localTrainingIconColor = Colors.grey;
        break;
      case 1:
        _btIcon = Icon(
          Icons.bluetooth_connected,
          color: Colors.green,
          size: 24.0,
          semanticLabel: "Conectado",
        );
        localTrainingIconColor = Colors.green;
        if (this._connectivityStatus != ConnectivityResult.none) {
          remoteTrainingIconColor = Colors.green;
        }
        break;
      case 2:
        _btIcon = Icon(
          Icons.bluetooth_searching,
          color: Colors.blue,
          size: 24.0,
          semanticLabel: "Conectando...",
        );
        textStatus = "Conectando...";
        localTrainingIconColor = Colors.blueAccent;
        break;
      case 3:
        _btIcon = Icon(
          Icons.bluetooth_disabled,
          color: Colors.grey,
          size: 24.0,
          semanticLabel: "No disponible",
        );
        textStatus = "No disponible";
        localTrainingIconColor = Colors.grey;
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
              if (widget.btObj.device != null) {
                print('Saltar a local!');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => localTrainingPage),
                );
              } else {
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
              color: remoteTrainingIconColor,
              size: 24.0,
              semanticLabel: "Entrenamiento remoto",
            ),
            title: Text("Entrenar usando internet"),
            subtitle: Text(_connectionStatus),
            onTap: () {
              print("Entrenamiento en linea");
              if (this._connectivityStatus != ConnectivityResult.none && widget.btObj.device != null) {
                print('Saltar a remoto!');
                /*
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => localTrainingPage),
                );
                */
              } else {
                if (this._connectivityStatus == ConnectivityResult.none ) {
                  show("No hay conexión a internet");
                }
                if (widget.btObj.device == null) {
                  show("No hay dispositivo conectado ");
                }
              }
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
