import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'shared_prefs.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

Future get_ts(url) async {
  //const download_path = os.getcwd() + "\download";//downloadパスの取得
  //const download_path = await getDownloadsDirectory();
  Directory appDocDir = await getApplicationDocumentsDirectory();
  String download_path = appDocDir.path;

  if (download_path == null) {
    //os.mkdir(download_path);//downloadディレクトリが無い時、ディレクトリ作成
    new Directory('download_path').create(recursive: true);
  }

  //String all_content = requests.get(url).text;  //M3U8 のファイルの内容を取得します
  var all_content = await HttpClient().getUrl(url);
  //var response = await all_content.close();
  var all_content_string = all_content.toString();
  var file_line = all_content_string.split("\r\n"); //ファイル内の各行を読み取ります

  //ファイル ヘッダーを判断して、M3U8 ファイルかどうかを判断します
  if (file_line[0] != "#EXTM3U") {
    throw Exception("M3U8 以外のリンク");
    //raise BaseException("M3U8 以外のリンク");
  } else {
    bool unknow = true; //ダウンロードのアドレスが見つかったかどうかを判断するために使用されます
    //ndex関数を使えば、探したい要素がリストの何番目に存在するかを知ることができます。
    //for (index, line in enumerate(file_line)){
    //enumerate関数を使うと、要素のインデックスと要素を同時に取り出す事が出来ます。
    for (String line in file_line) {
      if ("EXTINF" == line) {
        unknow = false;
        //ts フラグメントの URL を綴ります
        var pd_url = url.rsplit("/", 1)[0] + "/" + file_line[0 + 1];
        var res = await HttpClient().getUrl(pd_url).toString();
        var c_fule_name = (file_line[0 + 1]).toString();
        //var f = open(download_path + "\\" + c_fule_name, 'ab');
        var f = File(c_fule_name).readAsString();//.then(String contents);
        //f.write(res.content);
        File(c_fule_name).writeAsString('some content');
        //f.flush();
      }
    }
    if (unknow) {
      throw Exception("対応するダウンロードリンクが見つかりません");
      //raise BaseException("対応するダウンロード リンクが見つかではありません");
    } else {
      print("ダウンロードが完了しました");
    }
  }

  const path = "E://Clone Videos"; //既定のビデオ保存パス

  //String all_url = url.split('/');
  //'https://d.ossrs.net:8088/live/livestream.m3u8'
  List<String> all_url = url.split('/'); //split は '/' に基づいて文字列をリストに分割します
  String url_pre = all_url
      .join(); //'/'.join(all_url[-1]) + '/';			//最後の項目を破棄し、新しい URL にステッチします
  String url_next = all_url[-1]; //リストall_url末尾にある項目を取得します

  //String m3u8_txt = requests.get(url, headers = {'Connection':'close'});	//requests.get() 関数は requests.models.Response オブジェクトを返します
  var m3u8_txt = await http.get(url);
  print(m3u8_txt);

  //with open(url_next, 'wb') as m3u8_content: //m3u8 ファイル(m3u8_content)を新規作成します
  //m3u8_content.write(m3u8_txt.content); //m3u8_txt.content はバイト ストリームです
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String url = 'https://d.ossrs.net:8088/live/livestream.m3u8';

  @override
  void initState() {
    SharePrefs.setInstance();

    //codeItems = SharePrefs.getCodeItems();
    //stockItems = SharePrefs.getStockItems();
    //valueItems = SharePrefs.getValueItems();
    //acquiredAssetsItems = SharePrefs.getacquiredAssetsItems(); //取得資産
    //valuableAssetsItems = SharePrefs.getvaluableAssetsItems();
    super.initState();
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
      get_ts(url);
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
