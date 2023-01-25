import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:android_path_provider/android_path_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import 'dart:async';

import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Plugin must be initialized before using
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  await FlutterDownloader.initialize(
      debug: true, // optional: set to false to disable printing logs to console (default: true)
      ignoreSsl: true // option: set to false to disable working with http links (default: false)
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Avishkaar NFC',
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
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  late UnityWidgetController _unityWidgetController;
  double _sliderValue = 0.0;
  String _currentTag='0';
  String _sequence='';
  var _sequenceList=[];

  List<BluetoothService>? _services;

  String? nfcData;

  BluetoothDevice? _connectedDevice;

  var path='';

  @override
  void initState() {
    _init();

    _setPath();
    // _downloadFile();
    // Start scannin
    super.initState();
  }
  void _setPath() async {
    Directory _path = await getApplicationDocumentsDirectory();
    String _localPath = _path.path + Platform.pathSeparator + 'Download';
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
    var downloadsPath = await AndroidPathProvider.downloadsPath;
    path =(await _getSavedDir())!;
    _downloadFiles();
  }
  @override
  void dispose() {
    _unityWidgetController.dispose();
    super.dispose();
  }
  ReceivePort _port = ReceivePort();
  @pragma('vm:entry-point')
  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    final SendPort send = IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }
  Future<void> _init() async {
    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState((){ });
    });
    await FlutterDownloader.registerCallback(downloadCallback);
    print('hello in ii=nit');
    if(await Permission.camera.isGranted) {
      bool isAvailable = await NfcManager.instance.isAvailable();
      if (isAvailable) {
        NfcManager.instance.startSession(
          alertMessage: _sequence,
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
      appBar: AppBar(
        title: const Text('Avishkaar NFC Demo'),
      ),
      body: SafeArea(
        child: Column(
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
                              _unityWidgetController.postMessage('FlutterManager', 'ChangeColorShape', 'Blue');
                            }, child: Text('Blue',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 18),)),
                      ),
                      SizedBox(
                        width: 120,
                        child: ElevatedButton(
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                            onPressed: (){
                              _unityWidgetController.postMessage('FlutterManager', 'ChangeColorShape', 'Red');
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
                              _unityWidgetController.postMessage('FlutterManager', 'ChangeColorShape', 'Green');
                            }, child: Text('Green',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 18),)),
                      ),
                      SizedBox(
                        width: 120,
                        child: ElevatedButton(
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.yellow)),
                            onPressed: (){
                              _unityWidgetController.postMessage('FlutterManager', 'ChangeColorShape', 'Yellow');
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
                              _unityWidgetController.postMessage('FlutterManager', 'LoadScene', 'lvl1');
                            }, child: Text('Level 1',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),)),
                      ),
                      SizedBox(
                        width: 100,
                        child: ElevatedButton(
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.green)),
                            onPressed: (){
                              _unityWidgetController.postMessage('FlutterManager', 'LoadScene', 'lvl2');
                            }, child: Text('Level 2',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),)),
                      ),
                      SizedBox(
                        width: 100,
                        child: ElevatedButton(
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.green)),
                            onPressed: (){
                              _unityWidgetController.postMessage('FlutterManager', 'LoadScene', 'lvl3');
                            }, child: Text('Level 3',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),)),
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
                                      'FlutterManager', 'ChangeColorShape', 'Blue');
                                } else if (_currentTag == '2') {
                                  _unityWidgetController.postMessage(
                                      'FlutterManager', 'ChangeColorShape', 'Red');
                                } else if (_currentTag == '3') {
                                  _unityWidgetController.postMessage(
                                      'FlutterManager', 'ChangeColorShape', 'Yellow');
                                } else if (_currentTag == '4') {
                                  _unityWidgetController.postMessage(
                                      'FlutterManager', 'ChangeColorShape', 'Green');
                                } else if (_currentTag == '5') {
                                  setRotationSpeed('0.0');
                                  _sliderValue = 0.0;
                                } else if (_currentTag == '6') {
                                  setRotationSpeed('0.5');
                                  _sliderValue = 0.5;
                                } else if (_currentTag == '7') {
                                  setRotationSpeed('1.0');
                                  _sliderValue = 1.0;
                                }else if(_currentTag=='8') _unityWidgetController.postMessage('FlutterManager', 'LoadScene', 'lvl1');
                                else if(_currentTag=='9') _unityWidgetController.postMessage('FlutterManager', 'LoadScene', 'lvl2');
                                else if(_currentTag=='10') _unityWidgetController.postMessage('FlutterManager', 'LoadScene', 'lvl3');
                                setState(() {

                                });
                              }
                            }, child: Text('Play',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),)),
                      ),
                      Row(
                        children: [
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: 150,
                        child: ElevatedButton(
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                            onPressed: (){
                              flutterBlue.startScan(timeout: Duration(seconds: 30));
                              flutterBlue.scanResults.listen((results) async {
                                // do something with scan results
                                for (ScanResult r in results) {
                                  if(r.device.name=='AVX_NFC' && _connectedDevice==null){
                                    _connectedDevice=r.device;
                                   await r.device.connect();
                                    _services = await r.device.discoverServices();
                                    var toSubtract=0;
                                    if(Platform.isIOS)toSubtract=2;
                                    _services![2-toSubtract].characteristics[0].setNotifyValue(true);
                                    _services![2-toSubtract].characteristics[0].value.listen((event) {
                                      nfcData=utf8.decode(event);
                                      _sequenceList.add(nfcData);
                                      if (nfcData == '0') {
                                        _sequence+='Delay 2,';
                                      }
                                      else if (nfcData == '1') {
                                        _sequence+='Blue,';
                                      } else if (nfcData == '2') {
                                        _sequence+='Red,';
                                      } else if (nfcData == '3') {
                                        _sequence+='Yellow,';
                                      } else if (nfcData == '4') {
                                        _sequence+='Green,';
                                      } else if (nfcData == '5') {
                                        _sequence+='Rotation 0%,';
                                      } else if (nfcData == '6') {
                                        _sequence+='Rotation 50%,';
                                      } else if (nfcData == '7') {
                                        _sequence+='Rotation 100%,';
                                      }else if(nfcData=='8') _sequence+='Cube,';
                                      else if(nfcData=='9') _sequence+='Cylinder,';
                                      else if(nfcData=='10') _sequence+='Capsule,';
                                      setState(() {

                                      });

                                    });

                                  }
                                }
                              });
                            }, child: Text('Connect BLE',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),)),
                      ),
                      SizedBox(
                        width: 150,
                        child: ElevatedButton(
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                            onPressed: () async {
                             await _connectedDevice!.disconnect();
                             _connectedDevice=null;
                            }, child: Text('Disconnect BLE',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 16),)),
                      ),
                    ],
                  ),


                ],
              ),
            ),
          ],
        ),
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

  }

  // Callback that connects the created controller to the unity controller
  void _onUnityCreated(controller) {
    controller.resume();
    _unityWidgetController = controller;

  }

  Future<void> _downloadFiles() async {
    try {
      var response = await Dio().get('https://assets.avishkaar.cc/nfc-game-assets/AssetBundles/game1',
      options: Options(responseType: ResponseType.bytes)
      );
      if(Platform.isAndroid)
     var f=await File('/storage/emulated/0/Android/data/com.avishkaar.avishkaar_nfc/files/game1').writeAsBytes(response.data);
      else
     var f=await File('${(await getApplicationDocumentsDirectory()).absolute.path}${Platform.pathSeparator}game1').writeAsBytes(response.data);


      var response2 = await Dio().get('https://assets.avishkaar.cc/nfc-game-assets/AssetBundles/materials',
      options: Options(responseType: ResponseType.bytes)
      );
      if(Platform.isAndroid)
     var k=await File('/storage/emulated/0/Android/data/com.avishkaar.avishkaar_nfc/files/materials').writeAsBytes(response2.data);
      else
        var f=await File('${(await getApplicationDocumentsDirectory()).absolute.path}${Platform.pathSeparator}materials').writeAsBytes(response.data);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download Completed')));
      _unityWidgetController.postMessage('GameManager', 'Setup', 'start');


      print(response);
    } catch (e) {
      print(e);
    }

  }
  Future<String?> _getSavedDir() async {
    String? externalStorageDirPath;

    if (Platform.isAndroid) {
      try {
        externalStorageDirPath = await AndroidPathProvider.documentsPath;
      } catch (err, st) {
        print('failed to get downloads path: $err, $st');

        final directory = await getExternalStorageDirectory();
        externalStorageDirPath = directory?.path;
      }
    } else if (Platform.isIOS) {
      externalStorageDirPath =
          (await getApplicationDocumentsDirectory()).absolute.path;
    }
    return externalStorageDirPath;
  }

  // Future<void> _downloadFile() async {
  //  var options = DownloaderUtils(
  //     progressCallback: (current, total) {
  //       final progress = (current / total) * 100;
  //       print('Downloading: $progress');
  //     },
  //     file: File('$path/200MB.zip'),
  //     progress: ProgressImplementation(),
  //     onDone: () => print('COMPLETE'),
  //     deleteOnCancel: true,
  //   );
  //   await Flowder.download(
  //       'http://ipv4.download.thinkbroadband.com/200MB.zip',
  //       options);
  // }
}
