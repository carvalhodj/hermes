import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:geolocator/geolocator.dart';

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
  Position _currentPosition;
  String _currentAddress;
  final Geolocator geolocator = Geolocator();

  _addDeviceToList(final BluetoothDevice device) {
    if (!devicesList.contains(device)) {
      setState(() {
        devicesList.add(device);
      });
    }
  }

  _getCurrentLocation() {
    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
      // _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
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
                  if (_currentPosition != null)
                    Text(
                      'Lat:' +
                          _currentPosition.latitude.toString() +
                          'Long' +
                          _currentPosition.longitude.toString(),
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
    _getCurrentLocation();
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

  // List<ButtonTheme> _buildReadWriteNotifyButton(
  List<Widget> _buildReadWriteNotifyButton(
      BluetoothCharacteristic characteristic) {
    // List<ButtonTheme> buttons = new List<ButtonTheme>();
    // List<ButtonTheme> buttons = [];
    List<Widget> buttons = [];

    // if (characteristic.properties.read) {
    //   buttons.add(
    //     ButtonTheme(
    //       minWidth: 10,
    //       height: 20,
    //       child: Padding(
    //         padding: const EdgeInsets.symmetric(horizontal: 4),
    //         child: ElevatedButton(
    //           style: ButtonStyle(
    //               backgroundColor:
    //                   MaterialStateProperty.all<Color>(Colors.blueGrey[800])),
    //           child: Text('READ', style: TextStyle(color: Colors.white)),
    //           onPressed: () {},
    //         ),
    //       ),
    //     ),
    //   );
    // }
    if (characteristic.properties.write) {
      buttons.add(
        Row(
          children: <Widget>[
            ElevatedButton(
              child:
                  Text('Send Message', style: TextStyle(color: Colors.white)),
              style: ButtonStyle(
                alignment: Alignment.center,
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.blueGrey[800]),
              ),
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Type the message"),
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
                        TextButton(
                          child: Text("Cancel"),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        TextButton(
                          child: Text("Send"),
                          onPressed: () {
                            characteristic.write(
                                utf8.encode(_writeController.value.text));
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      );
    }
    // if (characteristic.properties.notify) {
    //   buttons.add(
    //     ButtonTheme(
    //       minWidth: 10,
    //       height: 20,
    //       child: Padding(
    //         padding: const EdgeInsets.symmetric(horizontal: 4),
    //         child: ElevatedButton(
    //           child: Text('NOTIFY', style: TextStyle(color: Colors.white)),
    //           onPressed: () {},
    //         ),
    //       ),
    //     ),
    //   );
    // }

    return buttons;
  }

  ListView _buildConnectDeviceView() {
    // List<Container> containers = new List<Container>();
    List<Container> containers = [];
    int count = 0;

    for (BluetoothService service in _services) {
      // List<Widget> characteristicsWidget = new List<Widget>();
      List<Widget> characteristicsWidget = [];
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        // characteristic.value.listen((value) {
        //   print(value);
        // });
        characteristicsWidget.add(
          Align(
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                // Row(
                //   children: <Widget>[
                //     Text(characteristic.uuid.toString(),
                //         style: TextStyle(fontWeight: FontWeight.bold)),
                //   ],
                // ),
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
      count++;
      if (count == 3) {
        containers.add(
          Container(
            // child: ExpansionTile(
            //     title: Text(service.uuid.toString()),
            //     children: characteristicsWidget),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '\n\nTap the button to send a message\n\n',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: characteristicsWidget,
                )
              ],
            ),
          ),
        );
      }
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
