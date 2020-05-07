import 'dart:async';
import 'package:flutter_blue/flutter_blue.dart';

//We're making these three things global so that we-
//can check the state and device later in this class

class BluetoothClass {
  BluetoothDevice device;
  BluetoothState state;
  BluetoothDeviceState deviceState;

  FlutterBlue _bluetoothInstance = FlutterBlue.instance;
  //BluetoothDevice device;
  StreamSubscription<ScanResult> scanSubscription;

  FlutterBlue get bluetoothInstance => _bluetoothInstance;

  set bluetoothInstance(FlutterBlue value) {
    _bluetoothInstance = value;
  }

  ///Constructor
  BluetoothClass(FlutterBlue instance) {
    this._bluetoothInstance = instance;
  }

  ///Initialisation and listening to device state
  //@override
  void initState() {
    print('Inicializacion BTL');
    //super.initState();
    //checks bluetooth current state
    FlutterBlue.instance.state.listen((state) {
      if (state == BluetoothState.off) {
        //Alert user to turn on bluetooth.
      } else if (state == BluetoothState.on) {
        //if bluetooth is enabled then go ahead.
        //Make sure user's device gps is on.
        //scanForDevices();
      }
    });
  }

  ///// **** Scan and Stop Bluetooth Methods  ***** /////
  Future<bool> scanForDevices() async {
    /*
    scanSubscription = bluetoothInstance.scan().listen((scanResult) async {
      String deviceName = scanResult.device.name;
      if (deviceName != "") {
        print(deviceName + " --" + scanResult.device.id.toString());

        if (scanResult.device.name == "HC-06" ||
            scanResult.device.name == "physiobotBT") {
            print("found device");
            //Assigning bluetooth device
            device = scanResult.device;
            //After that we stop the scanning for device
            stopScanning();
        }
      }
    });
    */
    // Start scanning
    this._bluetoothInstance.startScan(timeout: Duration(seconds: 8));

    /*
    // Listen to scan results
    var scanSubscription = this._bluetoothInstance.scanResults.listen((results) {
      // do something with scan results
      for (ScanResult scanResult in results) {
        if (scanResult.device.name != "") {
          print("${scanResult.device.name} found! rssi: ${scanResult.device.id}");
          if (scanResult.device.name == "HC-06" ||
              scanResult.device.name == "physiobotBT") {

            //Assigning bluetooth device
            device = scanResult.device;
            //After that we stop the scanning for device
            this._bluetoothInstance..stopScan();
            break;
          }
        }
      }
    });
    scanSubscription.cancel();
    stopScanning();

    // Stop scanning
    this._bluetoothInstance.stopScan();
    */
    await Future<String>.delayed(const Duration(seconds: 10));
    if (device != null) {
      return true;
    }
    return true;
  }

  void stopScanning() {
    _bluetoothInstance.stopScan();
    if (scanSubscription != null) {
      scanSubscription.cancel();
    }
  }
}
