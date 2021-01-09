import 'dart:async';
import 'dart:io';
//import 'package:http_server/http_server.dart';
//import "dart:isolate";
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String url = 'https://d.ossrs.net:8088/live/livestream.m3u8';

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

  Future get_ts(url) async {
    const download_path = os.getcwd() + "\download";

    if not os.path.exists(download_path):
        os.mkdir(download_path);//ディレクトリ作成

    String all_content = requests.get(url).text;  //M3U8 のファイルの内容を取得します# 获取M3U8的文件内容
    String file_line = all_content.split("\r\n"); //ファイル内の各行を読み取ります# 读取文件里的每一行



    //ファイル ヘッダーを判断して、M3U8 ファイルかどうかを判断します# 通过判断文件头来确定是否是M3U8文件
    if file_line[0] != "#EXTM3U":
        raise BaseException(u"M3U8 以外のリンク非M3U8的链接")
    else:
        unknow = True  //ダウンロードのアドレスが見つかったかどうかを判断するために使用されます# 用来判断是否找到了下载的地址
        for index, line in enumerate(file_line):
            if "EXTINF" in line:
                unknow = False
                //ts フラグメントの URL を綴ります# 拼出ts片段的URL
                pd_url = url.rsplit("/", 1)[0] + "/" + file_line[index + 1]
                res = requests.get(pd_url)
                c_fule_name = str(file_line[index + 1])
                with open(download_path + "\\" + c_fule_name, 'ab') as f:
                    f.write(res.content)
                    f.flush()
        if unknow:
            raise BaseException("対応するダウンロード リンクが見つかではありません未找到对应的下载链接")
        else:
            print u"ダウンロードが完了しました下载完成"




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
