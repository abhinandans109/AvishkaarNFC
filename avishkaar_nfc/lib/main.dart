import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';

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
  List<String> list=[];
  var _showList=false;
  String _currentTag='';
  @override
  void initState() {
    _init();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Current Tag : ',style: TextStyle(fontWeight: FontWeight.w500,fontSize: 18),),
                Text(_currentTag,style: TextStyle(fontWeight: FontWeight.w500,fontSize: 18),),
              ],
            ),
          SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: (){
                  _showList=_showList?false:true;
                  list.add('hello');
                  setState(() {

                  });
                }, child: Text('Show List')),
                ElevatedButton(onPressed: (){
                  list=[];
                  setState(() {
                  });
                }, child: Text('Clear')),
              ],
            ),
          SizedBox(height: 20,),
          Visibility(
            visible: _showList,
            child: Expanded(
              child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (itemBuilder,pos)=>Text(list[pos],style: TextStyle(fontWeight: FontWeight.w500,fontSize: 18),)),
            ),
          )
        ],
      ),
     // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<void> _init() async {
    bool isAvailable = await NfcManager.instance.isAvailable();
    if(isAvailable) {
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          _currentTag=tag.data.values.first.toString();
          list.add(tag.data.values.first.toString());
          setState(() {

          });
        },
      );
    }
  }
}
