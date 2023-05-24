import 'package:flutter/material.dart';
import "../state/state.dart";
import 'package:firebase_auth/firebase_auth.dart';
import "package:cloud_firestore/cloud_firestore.dart";

class form {
  //各種コントローラーの生成
  final titleController = TextEditingController();
  final moneyController = TextEditingController();
  final contentsController = TextEditingController();
  DateTime selectedDate = DateTime.now();

  //日付選択用Widgetが呼ばれたときの処理
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2021),
        lastDate: DateTime(2222));
    if (picked != null && picked != selectedDate) selectedDate = picked;
  }

  //入金処理の実行
  void nyukin(ref, oshi, syukkin) async {
    //データベースで使用する関数の定義
    String collection = "nyukin";

    //入力フォームからの入力を変数に格納
    final title = titleController.text;
    int money = int.parse(moneyController.text);
    final contents = contentsController.text;
    final today = DateTime.now();
    final dateOnly = DateTime(today.year, today.month, today.day);

    if (syukkin) {
      //出金の場合は金額にマイナスをつける
      //コレクション名も変更する
      money = money * -1;
      collection = "syukkin";
    }

    //データベースに挿入するデータの定義
    Map<String, dynamic> data = {
      "created_at": dateOnly,
      "title": title,
      "money": money,
      "contents": contents
    };

    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        var db = FirebaseFirestore.instance;
        var user_id = user.uid;

        //Firestoreにデータを追加
        final docRef = db
            .collection("users")
            .doc(user_id)
            .collection("oshi")
            .doc(oshi)
            .collection(collection);
        await docRef.add(data);

        //Firestore上のoshisumに金額を加算
        final oshiRef =
            db.collection("users").doc(user_id).collection("oshi").doc(oshi);

        oshiRef
            .update({'sum_money': FieldValue.increment(money)})
            .then((_) => print('Update success!'))
            .catchError((error) => print('Failed to update: $error'));

        //状態管理されているoshiList、oshiIndex、oshiSumMoney、sumMoney の更新
        final userRef = db.collection("users").doc(user_id);
        late List oshiList = ref.read(oshiListProvider);
        late List indexList = ref.read(oshiIndexProvider);

        //oshiList中におし名(oshi)が何番目にあるか(index) を検索
        int index = indexList[oshiList.indexOf(oshi)];
        List sumOshiList = ref.read(oshiSumMoneyProvider);

        //該当するoshiの金額（sumOshiList[index]） にmoney分加算
        sumOshiList[index] = sumOshiList[index] + money;
        ref.read(oshiSumMoneyProvider.notifier).update((state) => sumOshiList);

        //全てのOshiの金額の合計(sumMoney)にmoney分加算
        int sum = ref.read(sumMoneyProvider);
        sum = sum + money;
        ref.read(sumMoneyProvider.notifier).update((state) => sum);

        //Firestore上のsum_moneyに金額を加算
        userRef
            .update({'sum_money': FieldValue.increment(money)})
            .then((_) => print('Update success!'))
            .catchError((error) => print('Failed to update: $error'));
      } else {
        //ログインしていない場合
        print("user:$user");
      }
    });
  }

  //フォームを表示する
  formList(
    List list,
  ) {
    return Form(
      child: Column(
        children: <Widget>[
          for (int i = 0; i < list.length; i++) list[i],
        ],
      ),
    );
  }

//textフォームを指定する。
//行数、高さ、いろ、コントローラー、アイコン、テキストを指定する
  _form(i, y, oshicolor, controller, icon, text) {
    return SizedBox(
      height: y,
      child: TextFormField(
        maxLines: i,
        controller: controller,
        decoration: InputDecoration(
            prefixIcon: Icon(icon, color: oshicolor),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: oshicolor),
            ),
            labelText: text,
            contentPadding: EdgeInsets.symmetric(vertical: y * 4 / 8 - 10)),
      ),
    );
  }
}
