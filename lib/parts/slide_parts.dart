import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 状態管理に関するライブラリをインポート
import '../state/state.dart';

// ファイルから推しの情報を取得するためのクラスファイルをインポート
import '../info/oshi_info.dart';

// 推し詳細ページのコンポーネントを含むファイルをインポート
import '../page/oshi.dart';

class parts {

  oshiButton(index, ref, context) {
    // oshiListProviderが更新された時点で、ref.readメソッドを使って更新を監視したリストosih_listを作成
    final oshi_list = ref.watch(oshiListProvider) as List<dynamic>;

    // 明示的な推しキャラクターの情報取得のため、oshInfo関数を呼び出す
    OshiInformation().oshiInfo(oshi_list, ref);

    // 推しのアイコンカラー情報を変数oshiColorに取り出す
    final oshiColor = ref.read(oshiColorProvider);

    // 推しのアイコン名情報を変数iconNameに取り出す
    final iconName = ref.read(oshiIconNameProvider);

    // アイコンカラーを16進数に変換
    String color = "FF" + oshiColor[index];

    // アイコン設定
    IconSetting(iconName[index]);

    return Stack(children: [
      IconButton(
        iconSize: 100,
        onPressed: () {
          // oshiIndexProviderからoshiIndex変数を読み込んで、ここからその編集が可能となる
          final oshiIndex = ref.read(oshiIndexProvider);

          // 選択した推しのインデックスがoshiIndexリストの最後尾より手前かどうかをチェック。
          if (oshiIndex.length <= index) {
            // もしそうなら、oshiIndexリストに選択された推しのインデックスを追加していく。
            oshiIndex.add(index);
          } else {
            // もし手前でない場合は、その要素を上書きしてしまう。
            oshiIndex[index] = index;
          }
          print("推しのインデックスリストは$oshiIndex");

          // 選択された推しの名前を変数oshiNameに格納
          String oshiName = oshi_list[index];

          // 選択された推しの詳細ページを表示する画面に遷移
          Navigator.push(
            context,

            // Oshiクラスに、選択されたoshiName（プロパティ）を設定して画面に遷移
            MaterialPageRoute(
                builder: (context) =>

                    // 選択した推しの詳細ページを表示する画面に遷移
                    Oshi(oshi: oshiName)),
          );
        },
        icon: Icon(
          // 推しのアイコン名に応じてアイコンを生成する。
          IconSetting(iconName),

          // 16進数に変換したカラーでアイコン色を指定（ここではradix=16で16進数に変換）
          color: Color(int.parse(color, radix: 16)),
        ),
      ),

      Text(oshi_list[index]) // 推しの名前を表示
    ]);
  }

// 引数iconNameには、アイコン名が渡される
  IconSetting(iconName) {
    // アイコン名からアイコンを取得する方法を次で示す。
    IconData? oshiIcon = Icons.settings;

    // keyとvalueのセットがMultiple処理であるマップへの変換。iocnNameでアクセスできるアイコンのためのkey-value pair
    Map<String, IconData> iconList = {
      "Home": Icons.home,
      "Build": Icons.build,
      "fire": Icons.local_fire_department,
    };

    // 上記リストからアイコン名に従ってアイコンを取得
    oshiIcon = iconList[iconName];
    return oshiIcon;
  }

  name(showName) {
    return Container(
      // コンテナの幅を設定
      width: 300,

      // コンテナの高さを設定
      height: 115,

      // テキストを表示する部分の設定
      child: Text(
        // 引数のユーザー名を表示
        showName,

        // カスタムフォントの設定
        style: GoogleFonts.kiwiMaru(

          // フォントサイズを設定
          textStyle: TextStyle(fontSize: 30),
        ),
      ),
    );
  }

// 「現在の貯金額」と「目標の貯金額」から、進捗状況を含むウィジェットを作成する
  money(sum,goal) {
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          // 目標達成率を計算し、テキストで表示する
          (sum / goal).toString() + "%",
          style: GoogleFonts.kiwiMaru(
            textStyle: TextStyle(fontSize: 30),
          ),
        ),
        Text(
          // 現在の貯金額を表示する
          "貯金:$sum円",
          style: GoogleFonts.kiwiMaru(
            textStyle: TextStyle(fontSize: 10),
          ),
        ),
        Text(
          // 目標の貯金額を表示する
          "目標:$goal円",
          style: GoogleFonts.kiwiMaru(
            textStyle: TextStyle(fontSize: 10),
          ),
        ),
      ],
    );
  }
}
