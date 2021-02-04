import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:collection';

//アプリがファイルを保存可能な場所を取得するライブラリ
import 'package:path_provider/path_provider.dart';
//import 'dart:html';

//import 'shared_prefs.dart';
import 'CounterStorage.dart';
//import 'package:open_url/open_url.dart';
//import 'package:url_launcher/url_launcher.dart';

//void main() => runApp(MyApp());
void main() {
  HttpOverrides.global = new MyHttpOverrides();
  runApp(MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
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
  final String title;
  //CounterStorage storage;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  @override
  void initState() {
    _start();

    super.initState();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  //デバイスのディレクトリパスの取得
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  //デバイスのディレクトリパスの取得
  Future<String> get _temporaryPath async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }

  //ローカルファイルオブジェクトの取得
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }

  //テンポラリファイルオブジェクトの取得
  Future<File> get _temporaryFile async {
    final path = await _temporaryPath;
    return File('$path/counter.txt');
  }

  Future<File> writeCounter(int counter) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString('$counter');
  }

  Future<File> witeByteCounter(List<int> byte) async {
    final file = await _temporaryFile;
    return file.writeAsBytes(byte);
  }

  //tsリンクが得られる,パラメータurlは.m3u8リンクである
  Future get_ts(url) async {
    //var path = "C://Clone_Videos"; // 既定のビデオ保存パス
    final m3u8_path = await getApplicationDocumentsDirectory();
    var path = m3u8_path.path;
    //Platform.script.toFilePath(); // 既定のビデオ保存パス

    //var _url = Uri.parse('https://d.ossrs.net:8088/live/livestream.m3u8');
    //var url_ = _url.toString();
    List<String> all_url = url.split('/'); //split は '/' に基づいて文字列をリストに分割します
    var url_next =
        all_url.removeLast(); //リストall_url末尾にある項目を取得します,*.m3u8ファイル名を取得
    var url_pre =
        all_url.join('/') + '/'; // 最後の項目を破棄し、新しい URL にステッチします,splitを元になる戻す

    var _url = await HttpClient().getUrl(Uri.parse(url));
    var response = await _url.close();
    var m3u8_txt = await utf8.decodeStream(response);
    print(m3u8_txt);

    final File file = File('$path/' + url_next);
    var m3u8_content = await file.open(mode: FileMode.write); //テキストファイルのパスを取得。
    m3u8_content.writeString(m3u8_txt);

    var movies = []; // 取得した完全な .ts ビデオ リンクを格納するリストを作成します

    var urls = await file.open(mode: FileMode.read); //テキストファイルのパスを取得。

    List<String> lines = file.readAsLinesSync();
    for (var line in lines) {
      // ある文字列が別の文字列で終わっているか？
      //assert(line.endsWith('.ts'));
      if (line.endsWith('.ts')) {
        // 抽出.tsファイルのリンク
        // 完全な .ts ネットワーク リンクにステッチされ、movies リストに保存され、line2[:-1] は末尾の改行を削除します
        movies.add(url_pre + line);
        print('movies.append ${movies}');
      } else {
        continue;
      }
    }
    urls.close(); // 閉じます
    return movies; // 一覧に戻ります
  }

  //スライスダウンロード関数、引数moviesは.tsリンクです。
  Future down_ts(movies) async {
    //os.chdir(path)
    int i = 0;

    print("Downloaded中");
    for (var _url in movies) {
      var movie_name = i.toString().padLeft(3, "0") +
          '.ts'; //ビデオクリップの名前とパス(_url.split('/')[-1][-6:])  # 接続で最後の 6 ビットをファイル名として抽出します。
      print(movie_name); // => 001

      var error_get = []; // エラーが発生したリンクを格納するリストを作成します。
      try {
        //var movie = requests.get(_url, headers={'Connection': 'close'}, timeout=60,verify=False);  // .ts リンクを開きます
        var movie = await HttpClient().getUrl(Uri.parse(_url));
        var response = await _url.close();
        //var m3u8_txt = await utf8.decodeStream(response);
        print('movie ${movie}');
      } catch (e) {
        error_get.add(_url);
      }
      i++;

      print('movie_name ${movie_name}');

      //final File movie_name = File('$path/' + url_next);
      //var movie_content = open('C://Reptile_video/' + movie_name, 'wb'); // ファイルをローカルに作成します
      //var movie_content = await movie_name.open(mode: FileMode.write); //テキストファイルのパスを取得。
      //movie_content.writelines(movie_name);  //スライスをダウンロードします
      if (error_get[i]) {
        down_ts(error_get[i]); // エラー一覧を再ダウンロードします
      } else {
        print("ダウンロードは成功しました。");
        i = i + 1;
      }
      continue;
    }
    print("すべてのスライスのダウンロードが完了しました。");
    num N = movies.length; // リスト要素の数を取得します

    return N; //要素の数を返します
  }
  /*
    for (String line in urls.readlines()) {
      print('readlines?', urls.readlines());
      String line2 = line.decode();
       if ('.ts' in line2:){  // 抽出.tsファイルのリンク
          // 完全な .ts ネットワーク リンクにステッチされ、movies リストに保存され、line2[:-1] は末尾の改行を削除します
            movies.append(url_pre + line2[:-1]);
            print('movies.append',movies);
       }
        else{
            continue;
        }
      urls.close();  // 閉じます
      return movies; 

    }
    */

  Future<bool> readFileByteByByte() async {
    //final fileName = 'C:\\code\\test\\file_test\\bin\\main.dart'; // use your image file name here
    final fileName = Platform.script
        .toFilePath(); //this will read this text file as an example
    final script = File(fileName);
    final file = await script.open(mode: FileMode.read);

    var byte;
    while (byte != -1) {
      byte = await file.readByte();
      if (byte == ';'.codeUnitAt(0)) {
        //check if byte is semicolon
        print(byte);
      }
    }
    await file.close();
    return (true);
  }

  //livestream.m3u8ファイルをバイト書込みモードで作成する。

  //var m3u8_content = File(url_next); //m3u8ファイルを作成し、
  //m3u8_content.writeAsBytes(m3u8_txt.content, mode: FileMode.append);

  //Future<String> get _localPath async {
  //CounterStorage.readCounter();
  //CounterStorage.writeCounter(1);

  //return directory.path;
  //}

  //レスポンスボディをバイナリ形式で取得.
  //m3u8_content.writeAsBytes(m3u8_txt.bodyBytes); //ivestream.m3u8にm3u8.txtのcontentを書込む（）

  //with open(url_next, 'wb') as m3u8_content:;  //m3u8ファイルを作成し、
  //    var m3u8_content.write(m3u8_txt.content);  //m3u8_txt.content はバイト ストリームです

  //var movies = []; // 取得した完全な .ts ビデオ リンクを格納するリストを作成します

  //final script = File(url_next);
  //file = await script.open(mode: FileMode.read);
  //var m3u8_content = await file.readByte();

  //var urls = m3u8_content.readByte();//ivestream.m3u8ファイルをバイト読込モードで開く。
  //for (http.ByteStream line in m3u8_content){
  //    String line2 = utf8.decode(line);						// bytes -> str
  //    if ('.ts' in line2){  // 抽出.tsファイルのリンク
  // 完全な .ts ネットワーク リンクにステッチされ、movies リストに保存され、line2[:-1] は末尾の改行を削除します
  //        movies.append(url_pre + line2[:-1]);
  //    }
  //    else{
  //        continue;
  //    }
  //}
  //urls.close();  // 閉じます
  //return movies; // 一覧に戻ります

  Future<String> apiRequest(String url, Map jsonMap) async {
    HttpClient httpClient = new HttpClient();
    HttpClientRequest request = await httpClient.postUrl(Uri.parse(url));
    request.headers.set('content-type', 'application/json');
    request.add(utf8.encode(json.encode(jsonMap)));
    HttpClientResponse response = await request.close();
    // todo - you should check the response.statusCode
    String reply = await response.transform(utf8.decoder).join();
    httpClient.close();
    return reply;
  }

  void _start() async {
    var movie_all = [];

    var _url =
        'https://d.ossrs.net:8088/live/livestream.m3u8'; //# input("请输入.m3u8链接：")

    var _url1 =
        'https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8';

    var _url2 = 'https://mnmedias.api.telequebec.tv/m3u8/29880.m3u8';

    var _url3 =
        'https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8';

    //var _url4 = 'http://www.streambox.fr/playlists/test_001/stream.m3u8';

    var _url5 =
        'https://pae.ipportalegre.pt/testes2/wsjson/api/app/ws-authenticate';

    var _url6 =
        'https://mtg-vod-http.babahhcdn.com/mtg/_definst_/mp4:tv3/surabtuttavalt/season3/muurisepp10.mp4/playlist.m3u8';
    var _url7 =
        'http://1257120875.vod2.myqcloud.com/0ef121cdvodtransgzp1257120875/3055695e5285890780828799271/v.f230.m3u8';

    var _url8 =
        'Https://iqiyi.cdn9-okzy.com/20200121/5270_859c5425/1000k/hls/index.m3u8';

    var _url9 =
        'https://d2nvs31859zcd8.cloudfront.net/1577f22089ebf09d4856_yamatonjp_35671135207_9154206860/720p30/highlight-741553362.m3u8';

    //var _url = 'http://m3u8.test.com/test.m3u8';
    var movie_name = 'sample'; // input("input to VideoName")

    movie_all = await get_ts(_url9);
    var r = down_ts(movie_all);
    //merge_ts(r);
    // change_mp4(movie_name)
    //del_ts(num)
  }

/*
    //http.Response response
    //var response = await http.readBytes(
    //  _url,
    //);

    // make GET request
    String url = 'https://jsonplaceholder.typicode.com/posts';
    http.Response response1 = await http.get(url);

    //const download_path = os.getcwd() + "\download";//downloadパスの取得
    //const download_path = await getDownloadsDirectory();
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String download_path = appDocDir.path;

    if (download_path == null) {
      //os.mkdir(download_path);//downloadディレクトリが無い時、ディレクトリ作成
      new Directory('download_path').create(recursive: true);
    }

    //String all_content = requests.get(url).text;  //M3U8 のファイルの内容を取得します
    //var all_content = await HttpClient().getUrl(_url);
    final all_content = await http.read(_url); //^DJI

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
          var pd_url = _url.split("/", 1)[0] + "/" + file_line[0 + 1];
          var res = await HttpClient().getUrl(pd_url).toString();
          var c_fule_name = (file_line[0 + 1]).toString();
          //var f = open(download_path + "\\" + c_fule_name, 'ab');
          var f = File(c_fule_name).readAsString(); //.then(String contents);
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

   

    


}

*/

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
