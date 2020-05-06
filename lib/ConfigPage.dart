// For performing some operations asynchronously
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'BluetoothClass.dart';

class ConfigPage extends StatefulWidget {
  ConfigPage({Key key, this.appBarTitle, this.btlContainer}) : super(key: key);

  final String appBarTitle;
  final BluetoothClass btlContainer;

  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  bool _available = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    /*
    String btState = 'Apagado';
    if (widget.btlContainer.bluetoothInstance.isOn == true) {
      btState = 'Encendido';
    }

    String estado = 'No disponible';
    if (widget.btlContainer.bluetoothInstance.isAvailable == true) {
      estado = 'Disponible';
    }
    */

    _askUser() async {

      try {
        await widget.btlContainer.scanForDevices().then((value) {
          _available = value;
          print(_available);
          Navigator.of(context).pop();
        });
      } catch (err) {
        print('Caught error: $err');
      }

      /*
      var currentContext = _scaffoldKey.currentContext;
      showDialog(
          context: currentContext,
          builder: (context) => new AlertDialog(
                title: new Text("Buscando dispositivo"),
                content:
                    new Text("Un momento, estamos buscando tu dipositivo..."),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Cancelar'),
                    onPressed: () {
                      print('Detener');
                      _available = false;
                      widget.btlContainer.stopScanning();
                      //Navigator.of(context).pop();
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                  )
                ],
              ));
       */
      /*
      var selected = await showDialog(
          context: context,
          child: new SimpleDialog(
            title: new Text('Buscando dispositivos...'),
            children: <Widget>[
              new SimpleDialogOption(
                child: new Text('Detener'),
                onPressed: () {
                  //Navigator.pop(context, Answers.NO);
                  print('No');
                  _available = false;
                  widget.btlContainer.stopScanning();
                  //Navigator.of(context).pop();
                },
              ),
            ],
          )
      );
      
      switch (selected ) {
        case Answers.NO:
          print('No');
          _available = false;
          widget.btlContainer.stopScanning();
          Navigator.of(context).pop();
          break;
      }
      */
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: false,
        title: Row(children: <Widget>[
          Text(widget.appBarTitle),
        ]),
      ),
      body: ListView(
        children: <Widget>[
          SwitchListTile(
            title: Text('Bluetooth'),
            value: _available,
            onChanged: (bool value) {
              setState(() {
                if (value) {
                  print('lanzando');
                  _askUser();
                  print('finalizao');
                  //fetchUserOrder().then((value) => _available);
                } else {
                  _available = false;
                  widget.btlContainer.stopScanning();
                }
              });
            },
            secondary: const Icon(Icons.bluetooth),
          ),
          /*
          ListTile(
            leading: Icon(Icons.map),
            title: Text('Map'),
          ),
          ListTile(
            leading: Icon(Icons.photo_album),
            title: Text('Album'),
          ),
          ListTile(
            leading: Icon(Icons.phone),
            title: Text('Phone'),
          ),
           */
        ],
      ),
    );
    //throw UnimplementedError();
  }
}
