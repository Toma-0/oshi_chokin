// materialパッケージのインポート
import 'package:flutter/material.dart';
// サイズ設定関連のファイルのインポート
import '../config/size_config.dart';

// Riverpod関連のライブラリーのインポート
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 設定と推し関連のクラスのインポート
import '../setting.dart';
import 'oshi.dart';

// 描画のためのウィジェット関連のクラスのインポート
import '../parts/donutsChart.dart';
import '../parts/waveAnime.dart';

// ユーザ情報の取得用クラスのインポート

import '../info/oshi_info.dart';
import 'package:google_fonts/google_fonts.dart';

// 状態(State)管理
import '../state/state.dart';

class Home extends ConsumerStatefulWidget {
  @override
  _ATMState createState() => _ATMState();
}

class _ATMState extends ConsumerState<Home>
    with SingleTickerProviderStateMixin {
  // タップ状態
  bool tap = false;

  // oshiのアイコンや位置
  IconData? oshiIcon = Icons.settings;
  double x = Size.w! * 25;
  double y = Size.h! * 25;

  // Waveアニメーション制御用のコントローラー
  late AnimationController waveController = AnimationController(
    duration: const Duration(seconds: 10),
    vsync: this,
  )..repeat();

  @override
  Widget build(BuildContext context) {
    // サイズ設定の初期化
    Size().init(context);
    setState(() {
      x = Size.w! * 25;
      y = Size.h! * 25;
    });

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(
          foregroundColor: Color.fromARGB(255, 62, 58, 58),
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          elevation: 0.0,
          // AppBar内左端の表示設定

          // AppBar内右端（設定）の表示設定
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingPage()),
                );
              },
              icon: Icon(Icons.settings),
            ),
          ],
        ),
        body: GestureDetector(
            onTap: () {
              print(tap);
              setState(() {
                tap = !tap;
              });
            },
            child: tapWidget()), //タップ時の表示切り替え
      ),
    );
  }

  // oshiアイコン名から対応するアイコン設定へのマッピング
  IconSetting(iconName) {
    Map<String, IconData> iconList = {
      "Home": Icons.home,
      "Build": Icons.build,
      "fire": Icons.local_fire_department,
    };

    setState(() {
      oshiIcon = iconList[iconName];
    });
  }

  Widget tapWidget() {
    // Widget を返すように修正

    // ユーザー名、目標金額、貯金金額、推しリストを取得
    final userName = ref.watch(userNameProvider).toString();
    final goal_money = ref.watch(goalMoneyProvider);
    final sum_money = ref.watch(sumMoneyProvider);
    final oshi_list = ref.watch(oshiListProvider) as List<dynamic>;

    if (tap) {
      // タップされた場合のウィジェット表示
      return Align(
          alignment: Alignment.center,
          child: Stack(alignment: AlignmentDirectional.center, children: [
            //firebaseから目標金額と貯金金額を持ってくる

            // 貯金率グラフ（ドーナツチャート）を表示
            donuts().chart(
                sum_money, goal_money, x, y, Color.fromARGB(255, 62, 58, 58)),

            // アニメーションする波を生成
            makeWave().wave(
                waveController, x, y, ref, Color.fromARGB(255, 62, 58, 58)),

            // 推しリストのボタンを水平スクロールで表示
            Container(
              width: 115,
              height: 115,
              alignment: AlignmentDirectional.center,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (oshi_list != null)
                      for (var i = 0; i < oshi_list.length; i++)
                        oshi_button(i), // 推しリストの要素数分ボタンを生成
                  ],
                ),
              ),
            ),
          ]));
    } else {
      // タップされていない場合のウィジェット表示

      return Align(
          alignment: Alignment.center,
          child: Stack(alignment: AlignmentDirectional.center, children: [
            donuts().chart(
                sum_money, goal_money, x, y, Color.fromARGB(255, 62, 58, 58)),

            // アニメーションする波を生成
            makeWave().wave(
                waveController, x, y, ref, Color.fromARGB(255, 62, 58, 58)),

            Container(
              width: 115,
              height: 115,
              alignment: AlignmentDirectional.center,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Container(
                      width: 300,
                      height: 115,
                      child: Text(
                        userName,
                        style: GoogleFonts.kiwiMaru(
                          textStyle: TextStyle(fontSize: 30),
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          (sum_money / goal_money).toString() + "%",
                          style: GoogleFonts.kiwiMaru(
                            textStyle: TextStyle(fontSize: 30),
                          ),
                        ),
                        Text(
                          "貯金:$sum_money円",
                          style: GoogleFonts.kiwiMaru(
                            textStyle: TextStyle(fontSize: 10),
                          ),
                        ),
                        Text(
                          "目標:$goal_money円",
                          style: GoogleFonts.kiwiMaru(
                            textStyle: TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ]));
    }
  }

//推しごとのボタンの作成
  oshi_button(i) {
    // 推しリスト、アイコンカラー、アイコン名を取得
    final oshi_list = ref.watch(oshiListProvider) as List<dynamic>;
    OshiInformation().oshiInfo(oshi_list, ref);
    final oshiColor = ref.read(oshiColorProvider);
    final iconName = ref.read(oshiIconNameProvider);

    // アイコンカラーを16進数に変換

    String color = "FF" + oshiColor[i];

    // アイコン設定
    IconSetting(iconName[i]);

    // 推しの情報を表示するアイコンボタンを生成
    return Stack(children: [
      IconButton(
        iconSize: 100,
        onPressed: () {
          final oshiIndex = ref.read(oshiIndexProvider);
          if (oshiIndex.length <= i) {
            oshiIndex.add(i);
          } else {
            oshiIndex[i] = i;
          }
          print("推しのインデックスリストは$oshiIndex");

          String oshiName = oshi_list[i];
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    Oshi(oshi: oshiName)), // 選択した推しの詳細ページを表示する画面に遷移
          );
        },
        icon: Icon(
          oshiIcon,
          color: Color(int.parse(color, radix: 16)), // 16進数に変換したカラーでアイコン色を指定
        ),
      ),

      Text(oshi_list[i]) // 推しの名前を表示
    ]);
  }

// dispose処理
  @override
  void dispose() {
    waveController.dispose(); // AnimationControllerは明示的にdisposeする。
    super.dispose();
  }
}
