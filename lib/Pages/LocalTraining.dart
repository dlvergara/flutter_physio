import 'dart:convert';
import 'dart:typed_data';
import '../classes/PhysioMessage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Util/BluetoothClass.dart';
import 'package:flutter_charts/flutter_charts.dart';

class LocalTraining extends StatefulWidget {
  LocalTraining({Key key, this.btObj}) : super(key: key);
  BluetoothClass btObj;

  @override
  _LocalTrainingState createState() => _LocalTrainingState();
}

class _LocalTrainingState extends State<LocalTraining> {
  ChartOptions _verticalBarChartOptions;
  LabelLayoutStrategy _xContainerLabelLayoutStrategy;
  ChartData _chartData;

  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String _messageBuffer = '';
  List<PhysioMessage> messages = List<PhysioMessage>();
  String chanelOne = "";

  double valChannelOne = 1;
  double valChannelTwo = 0;

  void defineOptionsAndData() {
    LineChartOptions _lineChartOptions = new LineChartOptions();
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
        this.valChannelOne, 0,
      ],
      [
        0, this.valChannelTwo,
      ],
    ];
    _chartData.xLabels = ["1", "2",];
    _chartData.assignDataRowsDefaultColors();
    // Note: ChartOptions.useUserProvidedYLabels default is still used (false);
  }

  void listenData(data) {
    //String incomeData = ascii.decode(data);
    //print('incoming: ${incomeData}');

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
          PhysioMessage(
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
        widget.btObj.streamData = widget.btObj.connection.input.listen(listenData, onDone: doneStream, onError: errorHandler, cancelOnError: false);
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
      widget.btObj.connectToPhysioBot().then((value) {
        receiveData();
      });
    }
    receiveData();
  }

  @override
  void initState() {
    super.initState();
    start();
    defineOptionsAndData();
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
        body: new Center(
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
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