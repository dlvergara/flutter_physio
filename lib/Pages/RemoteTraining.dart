import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Util/BluetoothClass.dart';
import 'package:flutter_charts/flutter_charts.dart';
import '../classess/Message.dart';
import '../classess/Session.dart';

class RemoteTraining extends StatefulWidget {
  RemoteTraining({Key key, this.btObj}) : super(key: key);
  BluetoothClass btObj;

  @override
  _RemoteTrainingState createState() => _RemoteTrainingState();
}

class _RemoteTrainingState extends State<RemoteTraining> {
  LineChartOptions _lineChartOptions;
  ChartOptions _verticalBarChartOptions;
  LabelLayoutStrategy _xContainerLabelLayoutStrategy;
  ChartData _chartData;

  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String _messageBuffer = '';
  List<Message> messages = List<Message>();
  String chanelOne = "";

  double valChannelOne = 1;
  double valChannelTwo = 0;

  Session activeSession;

  void defineOptionsAndData() {
    _lineChartOptions = new LineChartOptions();
    _verticalBarChartOptions = new VerticalBarChartOptions();
    _xContainerLabelLayoutStrategy = new DefaultIterativeLabelLayoutStrategy(
      options: _verticalBarChartOptions,
    );
    _chartData = new ChartData();
    _chartData.dataRowsLegends = [
      "Actividad",
      //"Canal 2",
      //"Fall", "Winter"
    ];
    _chartData.dataRows = [
      [
        this.valChannelOne,
        0,
      ],
      [
        0,
        this.valChannelTwo,
      ],
    ];
    _chartData.xLabels = [
      "1",
      "2",
    ];
    _chartData.assignDataRowsDefaultColors();
    // Note: ChartOptions.useUserProvidedYLabels default is still used (false);
  }

  void listenData(data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      //print('${_messageBuffer}');
      setState(() {
        chanelOne = backspacesCounter > 0
            ? _messageBuffer.substring(
                0, _messageBuffer.length - backspacesCounter)
            : _messageBuffer + dataString.substring(0, index);

        var jsonData = jsonDecode(chanelOne);
        print(jsonData);
        this.valChannelOne = jsonData[1];
        this.valChannelTwo = jsonData[2];

        messages.add(
          Message(
            1,
            chanelOne,
          ),
        );
        _messageBuffer = dataString.substring(index);
        defineOptionsAndData();
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }

    // It is an error to call [setState] unless [mounted] is true.
    if (!this.mounted) {
      return;
    }
  }

  void errorHandler(error) {
    print(error);
  }

  void doneStream() {
    if (this.widget.btObj.isDisconnecting) {
      print('Disconnecting locally!');
    } else {
      print('Disconnected remotely!');
    }
    if (this.mounted) {
      setState(() {});
    }
    widget.btObj.stopStreaming();
  }

  void receiveData() {
    try {
      print('receive data > ');
      if (widget.btObj.streamData == null) {
        widget.btObj.streamData = widget.btObj.connection.input.listen(
            listenData,
            onDone: doneStream,
            onError: errorHandler,
            cancelOnError: false);
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
      if (widget.btObj.streamData != null) {
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
    //start();//todo no olvidar activar
    defineOptionsAndData();

    /*
    Stream<Session> stream = new Stream.fromFuture(getData());
    stream.timeout(Duration(seconds: 60)).listen((data) {
      this.activeSession = data;
      print("DataReceived: "+data.session_id);
    }, onDone: () {
      print("Task Done");
      //TODO: pintar en verde
    }, onError: (error) {
      //TODO pintar en rojo
      print("Some Error");
    });
    */
  }

  Future<Session> getSessionData() async {
    // make GET request
    String url = 'http://107.170.208.14:8080/v1/session';
    Response response = await get(url);
    String json = response.body;

    Map<String, dynamic> map = jsonDecode(json);
    this.activeSession = Session.fromJson(map);

    return activeSession;
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
    VerticalBarChart verticalBarChart = new VerticalBarChart(
      painter: new VerticalBarChartPainter(),
      container: new VerticalBarChartContainer(
        chartData: _chartData, // @required
        chartOptions: _verticalBarChartOptions, // @required
        xContainerLabelLayoutStrategy:
            _xContainerLabelLayoutStrategy, // @optional
      ),
    );

    Icon icon = Icon(
      Icons.devices,
      color: Colors.red,
      size: 24.0,
      semanticLabel: "",
    );

    Text titleText = Text('Recibir info');
    Text subText = Text("sub");

    AppBar bar = AppBar(
      title: Text("Entrenamiento en línea"),
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
    );

    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        appBar: bar,
        body: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FutureBuilder<Session>(
                  future: getSessionData(),
                  builder:
                      (BuildContext context, AsyncSnapshot<Session> snapshot) {
                    String message = "";
                    if (snapshot.hasError) {
                      message = "Error: " + snapshot.error.toString();
                    } else {
                      switch (snapshot.connectionState) {
                        case ConnectionState.none:
                          message = "sin conexión";
                          break;
                        case ConnectionState.waiting:
                          message = "Esperando...";
                          break;
                        case ConnectionState.active:
                          message = "Descargando...";
                          break;
                        case ConnectionState.done:
                          message = "Sesión: " + snapshot.data.session_id;
                          break;
                      }
                    }
                    return Text(message);
                  }),
              Card(
                child: ListTile(
                  leading: icon,
                  title: titleText,
                  subtitle: subText,
                  onTap: _changeAction,
                ),
              ),
              Divider(),
              Card(
                child: ListTile(
                  title: Text("Dato recibido: "),
                  subtitle: Text(chanelOne),
                ),
              ),
              Divider(),
              //TODO: Graph here
              new Expanded(
                // expansion inside Column pulls contents |
                child: new Row(
                  // this stretch carries | expansion to <--> Expanded children
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    //new Text('>>>'),
                    // LineChart is CustomPaint:
                    // A widget that provides a canvas on which to draw
                    // during the paint phase.

                    // Row -> Expanded -> Chart expands chart horizontally <-->
                    new Expanded(
                      child: verticalBarChart, // verticalBarChart, lineChart
                    ),
                    // new Text('<<'), // horizontal
                    // new Text('<<<<<<'),   // tilted
                    // new Text('<<<<<<<<<<<'),   // skiped (shows 3 labels, legend present)
                    // new Text('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'), // skiped (shows 2 labels, legend present but text vertical)
                    // new Text('<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<'),// labels do overlap, legend NOT present
                    //new Text('<<<<<<'), // labels do overlap, legend NOT present
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
