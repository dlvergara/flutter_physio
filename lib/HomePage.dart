
import 'package:dav/ConfigPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'BluetoothClass.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.appBarTitle, this.btlContainer, this.configPageObj}) : super(key: key);

  final String title;
  final String appBarTitle;
  final BluetoothClass btlContainer;
  ConfigPage configPageObj;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    String btState = 'Apagado';
    if (widget.btlContainer.bluetoothInstance.isOn == true ) {
      btState = 'Encendido';
    }

    String estado = 'No disponible';
    if (widget.btlContainer.bluetoothInstance.isAvailable == true) {
      estado = 'Disponible';
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Row(
            children: <Widget>[
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
                  label: Text('')
              ),
            ]
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row (
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(widget.title)
              ],
            ),
            Text('Disponibilidad del bluetooth: ' + estado),
            Text('Estado del bluetoohth:' + btState),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
