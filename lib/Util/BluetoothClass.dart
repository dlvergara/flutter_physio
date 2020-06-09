// For using PlatformException
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothClass {

  // Initializing the Bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  BluetoothDevice _device;
  StreamSubscription streamData;

  // Get the instance of the Bluetooth
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;

  // Track the Bluetooth connection with the remote device
  BluetoothConnection connection;

  int _deviceState;
  bool isDisconnecting = false;

  // To track whether the device is still connected to Bluetooth
  bool get isConnected => connection != null && connection.isConnected;

  // Define some variables, which will be required later
  List<BluetoothDevice> _devicesList = [];
  bool _connected = false;

  BluetoothState get bluetoothState => _bluetoothState;

  set bluetoothState(BluetoothState value) {
    _bluetoothState = value;
  }

  BluetoothDevice get device => _device;

  set device(BluetoothDevice value) {
    _device = value;
  }

  FlutterBluetoothSerial get bluetooth => _bluetooth;

  set bluetooth(FlutterBluetoothSerial value) {
    _bluetooth = value;
  }

  int get deviceState => _deviceState;

  set deviceState(int value) {
    _deviceState = value;
  }

  List<BluetoothDevice> get devicesList => _devicesList;

  set devicesList(List<BluetoothDevice> value) {
    _devicesList = value;
  }

  bool get connected => _connected;

  set connected(bool value) {
    _connected = value;
  }

  // Request Bluetooth permission from the user
  Future<void> enableBluetooth() async {
    // Retrieving the current Bluetooth state
    this.bluetoothState = await FlutterBluetoothSerial.instance.state;

    // If the bluetooth is off, then turn it on first
    // and then retrieve the devices that are paired.
    if (this.bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      return true;
    } else {
      await getPairedDevices();
    }
    return false;
  }

  // For retrieving and storing the paired devices
  // in a list.
  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];
    try {
      devices = await this.bluetooth.getBondedDevices();
      this.devicesList = devices;
    } on PlatformException {
      print("PlatformException");
    }
  }

  //Function to connect with the HC-06
  Future<bool> connectToPhysioBot() async {
    print("conect to physiobot");
    if (!this.isConnected) {
      this.devicesList.forEach((element) {
        if (element.name == "HC-06") {
          this.device = element;

          BluetoothConnection.toAddress(this.device.address)
              .then((_connection) {
            print('Connected to the device: ' + device.name + " -> " + device.address);
            this.connection = _connection;
            //yield _connection;
          }).catchError((error) {
            print('Cannot connect, exception occurred');
            print(error);
          });

          //this.connection = BluetoothConnection.toAddress(this.device.address) as BluetoothConnection;
          //print('Connected to the device: ' + device.name + " -> " + device.address);
        }
      });
    }
    return this.isConnected;
  }

  void disconnect() {
    this.connection.close();
    this.deviceState = 0;
    this.connected = false;
  }

  void stopStreaming() {
    if (this.connection.isConnected) {
      if ( this.streamData != null && !this.streamData.isPaused) {
        this.streamData.pause();
      } else {
        this.connection.close();
      }
    }
  }
}