//Firebase関連のパッケージとUIパッケージをimportする
import 'package:flutter/material.dart';

//アプリケーションサイズに関する設定ファイルをimportする
import '../config/size_config.dart';

//数学関数のimport
import 'dart:math' as math;

//ユーザー情報を格納したファイルをimportする
import "../info/user_info.dart";


//CustomClipperを拡張したWaveClipper classを宣言する
class WaveClipper extends CustomClipper<Path> {
  //画面のコンテキスト、波を描画するためのパラメータ、座標リストを準備する
  final BuildContext context;
  final double waveControllerValue; // waveController.valueの値
  final double offset; // 波のずれ
  final List<Offset> coordinateList = []; // 波の座標のリスト

//WaveClipperクラスのconstructorを作成する
  WaveClipper(this.context, this.waveControllerValue, this.offset) {
    final width = MediaQuery.of(context).size.width; // 画面の横幅
    final height = MediaQuery.of(context).size.height; // 画面の高さ

    // coordinateListに波の座標を追加し、waveControllerValueとoffsetを使用して波を動かす
    for (var i = 0; i <= width * 10; i++) {
      final step = ((i / width) - waveControllerValue) * 8;
      coordinateList.add(
        Offset(
            i.toDouble() * 4, // X座標
            math.sin(step * 2 * math.pi - offset) * 3 + height * 0.3),
      );
    }
  }

  //CustomClipperのabstract methodであるgetClipメソッドをoverrideする
  @override
  Path getClip(size) {
    final path = Path()
      // addPolygon: coordinateListに入っている座標を直線で結ぶ。
      //             false -> 最後に始点に戻らない
      ..addPolygon(coordinateList, false)
      ..lineTo(size.width, size.height) // 画面右下へ
      ..lineTo(0, size.height) // 画面左下へ
      ..close(); // 始点に戻る
    return path;
  }

  //shouldReclipメソッドをoverrideすることで、波バウンド操作を再度行うタイミングを決定する
  @override
  @override
  bool shouldReclip(WaveClipper oldClipper) =>
      waveControllerValue != oldClipper.waveControllerValue;
}

//UI関連する処理をまとめたmakeWaveクラスを宣言する
class makeWave {
  //UserInformationのメソッドを呼び出し、高額額と目標額を変数に格納する関数を定義する
  high(ref) {
    UserInformation().userInfo(ref);
    List highList = [UserInformation.sum_money, UserInformation.goal_money];
    return highList;
  }

  //waveメソッドを定義し、波を描画するためのWidgetを返す
  AnimatedBuilder wave(waveController, x, y, ref, color) {

    //highメソッドを呼び出して高額額と目標額を取得する
    high(ref);

    // ウェーブ効果をもつアニメーションを作成するAnimatedBuilder
    return AnimatedBuilder(
       // アニメーション用のコントローラー
      animation: waveController,
      builder: (context, child) => Stack(
        children: [
          // クリップパスにより子要素を円形にカットしたコンテナー。1つ目のウェーブが描画される
          ClipPath(
            child: Container(
              width: (Size.w! * (x - 60)) * 2,
              height: Size.h! * y! * 10,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 255, 255, 255),
                shape: BoxShape.circle,
              ),
            ),
            // クリップパスで切り抜くためのカスタムクリッパー。今の値に準じて描画される範囲が変わる
            clipper: WaveClipper(context, waveController.value, 0),
          ),
          // クリップパスにより子要素を円形にカットしたコンテナー。2つ目のウェーブが描画される
          ClipPath(
            child: Container(
              width: (Size.w! * (x - 60)) * 2,
              height: Size.h! * y!,
              decoration: BoxDecoration(
                color: Color.fromARGB(149, 255, 255, 255),
                shape: BoxShape.circle,
              ),
            ),
            // クリップパスで切り抜くためのカスタムクリッパー。今の値に準じて描画される範囲が変わる
            clipper: WaveClipper(context, waveController.value, 0.6),
          ),
        ],
      ),
    );
  }
}
