import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class HomeScreen extends StatefulWidget {
  final FlutterBlue flutterBlue = FlutterBlue.instance;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<BluetoothDevice> devicesList = <BluetoothDevice>[];
  final _writeController = TextEditingController();
  BluetoothDevice _connectedDevice;
  List<BluetoothService> _services;

  _addDeviceToList(final BluetoothDevice device) {
    if (!devicesList.contains(device)) {
      setState(() {
        devicesList.add(device);
      });
    }
  }

  ListView _buildListViewOfDevices() {
    List<Container> containers = <Container>[];
    final _formKey = GlobalKey<FormState>();

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
                onPressed: () async {
                  widget.flutterBlue.stopScan();
                  try {
                    await device.connect();
                  } catch (e) {
                    if (e.code != 'already_connected') {
                      throw e;
                    }
                  } finally {
                    _services = await device.discoverServices();
                  }
                  setState(() {
                    _connectedDevice = device;
                  });
                  // showDialog(
                  //     context: context,
                  //     builder: (BuildContext context) {
                  //       return AlertDialog(
                  //         content: Stack(
                  //           clipBehavior: Clip.antiAlias,
                  //           children: <Widget>[
                  //             Positioned(
                  //               right: -40.0,
                  //               top: -40.0,
                  //               child: InkResponse(
                  //                 onTap: () {
                  //                   Navigator.of(context).pop();
                  //                 },
                  //                 child: CircleAvatar(
                  //                   child: Icon(Icons.close),
                  //                   backgroundColor: Colors.orange[700],
                  //                 ),
                  //               ),
                  //             ),
                  //             Form(
                  //               key: _formKey,
                  //               child: Column(
                  //                 mainAxisSize: MainAxisSize.min,
                  //                 children: <Widget>[
                  //                   Padding(
                  //                     padding: EdgeInsets.all(8.0),
                  //                     child: TextFormField(),
                  //                   ),
                  //                   Padding(
                  //                     padding: EdgeInsets.all(8.0),
                  //                     child: TextFormField(),
                  //                   ),
                  //                   Padding(
                  //                     padding: EdgeInsets.all(8.0),
                  //                     child: DropdownButtonFormField<int>(
                  //                       items: [1, 2, 3, 4, 5]
                  //                           .map((label) => DropdownMenuItem(
                  //                                 child: Text(label.toString()),
                  //                                 value: label,
                  //                               ))
                  //                           .toList(),
                  //                     ),
                  //                   ),
                  //                   Padding(
                  //                     padding: const EdgeInsets.all(8.0),
                  //                     child: ElevatedButton(
                  //                       child: Text("Send Packet"),
                  //                       onPressed: () {
                  //                         if (_formKey.currentState
                  //                             .validate()) {
                  //                           _formKey.currentState.save();
                  //                         }
                  //                       },
                  //                     ),
                  //                   )
                  //                 ],
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       );
                  //     });
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

  ListView _buildView() {
    if (_connectedDevice != null) {
      return _buildConnectDeviceView();
    }
    return _buildListViewOfDevices();
  }

  List<ButtonTheme> _buildReadWriteNotifyButton(
      BluetoothCharacteristic characteristic) {
    List<ButtonTheme> buttons = new List<ButtonTheme>();

    if (characteristic.properties.read) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: RaisedButton(
              color: Colors.blue,
              child: Text('READ', style: TextStyle(color: Colors.white)),
              onPressed: () {},
            ),
          ),
        ),
      );
    }
    if (characteristic.properties.write) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: RaisedButton(
              child: Text('WRITE', style: TextStyle(color: Colors.white)),
              onPressed: () async {
                await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Write"),
                        content: Row(
                          children: <Widget>[
                            Expanded(
                              child: TextField(
                                controller: _writeController,
                              ),
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text("Send"),
                            onPressed: () {
                              characteristic.write(
                                  utf8.encode(_writeController.value.text));
                              Navigator.pop(context);
                            },
                          ),
                          FlatButton(
                            child: Text("Cancel"),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    });
              },
            ),
          ),
        ),
      );
    }
    if (characteristic.properties.notify) {
      buttons.add(
        ButtonTheme(
          minWidth: 10,
          height: 20,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: RaisedButton(
              child: Text('NOTIFY', style: TextStyle(color: Colors.white)),
              onPressed: () {},
            ),
          ),
        ),
      );
    }

    return buttons;
  }

  ListView _buildConnectDeviceView() {
    List<Container> containers = new List<Container>();

    for (BluetoothService service in _services) {
      List<Widget> characteristicsWidget = new List<Widget>();
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        characteristic.value.listen((value) {
          print(value);
        });
        characteristicsWidget.add(
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Text(characteristic.uuid.toString(),
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Row(
                  children: <Widget>[
                    ..._buildReadWriteNotifyButton(characteristic),
                  ],
                ),
                Divider(),
              ],
            ),
          ),
        );
      }
      containers.add(
        Container(
          child: ExpansionTile(
              title: Text(service.uuid.toString()),
              children: characteristicsWidget),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hermes Packet Sender'),
        backgroundColor: Colors.blueGrey[800],
      ),
      backgroundColor: Colors.blueGrey,
      body: _buildView(),
    );
  }
}
