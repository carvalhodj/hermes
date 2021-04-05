import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class HomeScreen extends StatefulWidget {
  final FlutterBlue flutterBlue = FlutterBlue.instance;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<BluetoothDevice> devicesList = <BluetoothDevice>[];

  _addDeviceToList(final BluetoothDevice device) {
    if (!devicesList.contains(device)) {
      setState(() {
        devicesList.add(device);
      });
    }
  }

  ListView _buildListViewOfDevices() {
    List<Container> containers = <Container>[];
    for (BluetoothDevice device in devicesList) {
      containers.add(Container(
        height: 50,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                children: <Widget>[
                  Text(device.name == '' ? 'unknown device' : device.name),
                  Text(
                    device.id.toString(),
                  ),
                ],
              ),
            ),
            ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blueGrey[800])),
                onPressed: () {
                  print('Conectando...');
                },
                child: Text(
                  'Connect',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ))
          ],
        ),
      ));
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    widget.flutterBlue.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        _addDeviceToList(device);
      }
    });
    widget.flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        _addDeviceToList(result.device);
      }
    });
    widget.flutterBlue.startScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hermes Packet Sender'),
        backgroundColor: Colors.blueGrey[800],
      ),
      backgroundColor: Colors.blueGrey,
      body: _buildListViewOfDevices(),
    );
  }
}
