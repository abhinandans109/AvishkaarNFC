import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Avishkaar NFC',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Avishkaar NFC Tags'),
    );
  }
}

class MyHomePage extends StatefulWidget {


  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static final GlobalKey<ScaffoldState> _scaffoldKey =
  GlobalKey<ScaffoldState>();

  late UnityWidgetController _unityWidgetController;
  double _sliderValue = 0.0;
  String _currentTag='0';
  String _sequence='';
  var _sequenceList=[];

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  void dispose() {
    _unityWidgetController.dispose();
    super.dispose();
  }
  Future<void> _init() async {
    print('hello in ii=nit');
    if(await Permission.camera.isGranted) {
      bool isAvailable = await NfcManager.instance.isAvailable();
      if (isAvailable) {
        NfcManager.instance.startSession(
          onDiscovered: (NfcTag tag) async {
            _currentTag = utf8
                .decode(
                    tag.data['ndef']['cachedMessage']['records'][0]['payload'])
                .toString()
                .split('en')[1];
            _sequenceList.add(_currentTag);
            if (_currentTag == '0') {
              _sequence+='Delay 2,';
            }
           else if (_currentTag == '1') {
              _sequence+='Blue,';
            } else if (_currentTag == '2') {
              _sequence+='Red,';
            } else if (_currentTag == '3') {
              _sequence+='Yellow,';
            } else if (_currentTag == '4') {
              _sequence+='Green,';
            } else if (_currentTag == '5') {
              _sequence+='Rotation 0%,';
            } else if (_currentTag == '6') {
              _sequence+='Rotation 50%,';
            } else if (_currentTag == '7') {
              _sequence+='Rotation 100%,';
            }else if(_currentTag=='8') _sequence+='Cube,';
            else if(_currentTag=='9') _sequence+='Cylinder,';
            else if(_currentTag=='10') _sequence+='Capsule,';
            setState(() {});
          },
        );
      }
    }else {
      var status = Permission.camera.request();
      if(await status.isGranted){
        _init();
      }else{
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Allow Camera Permissions First')));
      }
    }
  }

  List<String> list=[];
  var _showList=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Avishkaar NFC Demo'),
      ),
      body: Column(
        children: [
          Expanded(
            child: UnityWidget(
              onUnityCreated: _onUnityCreated,
              onUnityMessage: onUnityMessage,
              onUnitySceneLoaded: onUnitySceneLoaded,
              // useAndroidViewSurface: false,
              // borderRadius: BorderRadius.all(Radius.circular(70)),
            ),
          ),
          Card(
            elevation: 10,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(_sequence,style:TextStyle(fontWeight: FontWeight.w500)),
                ),
                Slider(
                  onChanged: (value) {
                    setState(() {
                      _sliderValue = value;
                    });
                    setRotationSpeed(value.toString());
                  },
                  value: _sliderValue,
                  min: 0.0,
                  max: 1.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 120,
                      child: ElevatedButton(
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.blue)),
                          onPressed: (){
                            _unityWidgetController.postMessage('FlutterManager', 'ColorFromFlutter', 'blue');
                          }, child: Text('Blue',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 18),)),
                    ),
                    SizedBox(
                      width: 120,
                      child: ElevatedButton(
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                          onPressed: (){
                            _unityWidgetController.postMessage('FlutterManager', 'ColorFromFlutter', 'red');
                          }, child: Text('Red',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 18),)),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 120,
                      child: ElevatedButton(
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.green)),
                          onPressed: (){
                            _unityWidgetController.postMessage('FlutterManager', 'ColorFromFlutter', 'green');
                          }, child: Text('Green',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 18),)),
                    ),
                    SizedBox(
                      width: 120,
                      child: ElevatedButton(
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.yellow)),
                          onPressed: (){
                            _unityWidgetController.postMessage('FlutterManager', 'ColorFromFlutter', 'yellow');
                          }, child: Text('Yellow',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 18),)),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.green)),
                          onPressed: (){
                            _unityWidgetController.postMessage('FlutterManager', '_SpawnObject', 'Cube');
                          }, child: Text('Cube',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),)),
                    ),
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.green)),
                          onPressed: (){
                            _unityWidgetController.postMessage('FlutterManager', '_SpawnObject', 'Cylinder');
                          }, child: Text('Cylinder',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),)),
                    ),
                    SizedBox(
                      width: 100,
                      child: ElevatedButton(
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.green)),
                          onPressed: (){
                            _unityWidgetController.postMessage('FlutterManager', '_SpawnObject', 'Capsule');
                          }, child: Text('Capsule',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),)),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 150,
                      child: ElevatedButton(
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.blue)),
                          onPressed: ()async {
                            for(var _currentTag in _sequenceList){
                              if (_currentTag == '0') {
                              await  Future.delayed(Duration(seconds: 2));
                              }
                             else if (_currentTag == '1') {
                                _unityWidgetController.postMessage(
                                    'FlutterManager', 'ColorFromFlutter', 'blue');
                              } else if (_currentTag == '2') {
                                _unityWidgetController.postMessage(
                                    'FlutterManager', 'ColorFromFlutter', 'red');
                              } else if (_currentTag == '3') {
                                _unityWidgetController.postMessage(
                                    'FlutterManager', 'ColorFromFlutter', 'yellow');
                              } else if (_currentTag == '4') {
                                _unityWidgetController.postMessage(
                                    'FlutterManager', 'ColorFromFlutter', 'green');
                              } else if (_currentTag == '5') {
                                setRotationSpeed('0.0');
                                _sliderValue = 0.0;
                              } else if (_currentTag == '6') {
                                setRotationSpeed('0.5');
                                _sliderValue = 0.5;
                              } else if (_currentTag == '7') {
                                setRotationSpeed('1.0');
                                _sliderValue = 1.0;
                              }else if(_currentTag=='8') _unityWidgetController.postMessage('FlutterManager', '_SpawnObject', 'Cube');
                              else if(_currentTag=='9') _unityWidgetController.postMessage('FlutterManager', '_SpawnObject', 'Cylinder');
                              else if(_currentTag=='10') _unityWidgetController.postMessage('FlutterManager', '_SpawnObject', 'Capsule');
                              setState(() {

                              });
                            }
                          }, child: Text('Play',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),)),
                    ),
                    SizedBox(
                      width: 150,
                      child: ElevatedButton(
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                          onPressed: (){
                           _sequenceList=[];
                           _sequence='';
                           _unityWidgetController.postMessage(
                             'FlutterManager',
                             'clearObject',
                             'clear',
                           );
                           _sliderValue=0.0;
                           setState(() {

                           });
                          }, child: Text('Clear',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),)),
                    ),
                  ],
                ),


              ],
            ),
          ),
        ],
      ),
    );
  }
  void setRotationSpeed(String speed) {
    _unityWidgetController.postMessage(
      'FlutterManager',
      'SetRotationSpeed',
      speed,
    );
  }

  void onUnityMessage(message) {
    print('Received message from unity: ${message.toString()}');
  }

  void onUnitySceneLoaded(SceneLoaded? scene) {
    print('Received scene loaded from unity: ${scene!.name}');
    print('Received scene loaded from unity buildIndex: ${scene.buildIndex}');
  }

  // Callback that connects the created controller to the unity controller
  void _onUnityCreated(controller) {
    controller.resume();
    _unityWidgetController = controller;
  }
}
