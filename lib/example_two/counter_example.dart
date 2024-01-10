import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';

void main() {
  runApp(MyApp());
}

   void _isolateEntryPoint(SendPort sendPort) {
    final ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    int counter = 0;
    Timer.periodic(Duration(seconds: 1), (timer) {
      counter++;
      sendPort.send(counter);
    });
  }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Timer _timer;
  late FlutterIsolate _isolate;
  late ReceivePort _receivePort;
  int _counter = 0;

  @override
  void initState() {
    super.initState();
    _receivePort = ReceivePort();
  }

  void startIsolate() async {
    _isolate = await FlutterIsolate.spawn(_isolateEntryPoint, _receivePort.sendPort);
    _receivePort.listen((message) {
      setState(() {
        _counter = message;
      });
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      _isolate.pause();
      _isolate.resume();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _isolate.kill();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Isolate Timer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Contador:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          startIsolate();
        },
        tooltip: 'Iniciar Contador',
        child: Icon(Icons.play_arrow),
      ),
    );
  }
}
