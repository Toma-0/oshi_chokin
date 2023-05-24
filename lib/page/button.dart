import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'oshi.dart';

import '../config/size_config.dart';

import '../state/state.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class ButtonPage extends ConsumerStatefulWidget {
  final String oshi;
  ButtonPage({Key? key, required this.oshi}) : super(key: key);

  @override
  ConsumerState<ButtonPage> createState() => _ButtonPage();
}

class _ButtonPage extends ConsumerState<ButtonPage> {
  final titleController = TextEditingController();
  final moneyController = TextEditingController();
  final contentsController = TextEditingController();
  final _date = TextEditingController();
  DateTime selectedDate = DateTime.now();

  int money = 0;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2021),
        lastDate: DateTime(2222));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  void _saveData() async {
    final title = titleController.text;
    final contents = contentsController.text;

    Map<String, dynamic> data = {
      "created_at": DateTime.now(),
      "title": title,
      "money": money,
      "contents": contents
    };

    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        var db = FirebaseFirestore.instance;
        var user_id = user.uid;

        final docRef = db
            .collection("users")
            .doc(user_id)
            .collection("oshi")
            .doc(widget.oshi)
            .collection("nyukin");
        await docRef.add(data);

        final oshiRef = db
            .collection("users")
            .doc(user_id)
            .collection("oshi")
            .doc(widget.oshi);

        oshiRef
            .update({'sum_money': FieldValue.increment(money)})
            .then((_) => print('Update success!'))
            .catchError((error) => print('Failed to update: $error'));

        final userRef = db.collection("users").doc(user_id);

        userRef
            .update({'sum_money': FieldValue.increment(money)})
            .then((_) => print('Update success!'))
            .catchError((error) => print('Failed to update: $error'));

        late List oshiList = ref.read(oshiListProvider);
        late List indexList = ref.read(oshiIndexProvider);

        int index = indexList[oshiList.indexOf(widget.oshi)];

        List sumOshiList = ref.read(oshiSumMoneyProvider);
        sumOshiList[index] = sumOshiList[index] + money;
        ref.read(oshiSumMoneyProvider.notifier).update((state) => sumOshiList);

        int sum = ref.read(sumMoneyProvider);
        sum = sum + money;
        ref.read(sumMoneyProvider.notifier).update((state) => sum);
      } else {
        print("user:$user");
      }
    });
  }

  Widget build(BuildContext context) {
    late List indexList = ref.read(oshiIndexProvider);
    late List oshiList = ref.read(oshiListProvider);

    int index = indexList[oshiList.indexOf(widget.oshi)];
    late List colorList = ref.read(oshiColorProvider);

    String colorSt = "FF" + colorList[index];
    Color Oshicolor = Color(int.parse(colorSt, radix: 16));

    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: Container(
          padding: EdgeInsets.all(20),
          color: Colors.white,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Oshicolor),
            ),
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                makeForm(Oshicolor),
                Padding(padding: EdgeInsets.only(top: 20)),
                ElevatedButton(
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        side: BorderSide(
                          color: Oshicolor,
                          width: 2,
                        ),
                      ),
                    ),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                  ),
                  onPressed: () {
                    _saveData();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Oshi(oshi: widget.oshi)),
                    );
                  },
                  child: Text(
                    '貯金',
                    style: TextStyle(color: Oshicolor),
                  ),
                )
              ],
            ),
          ),
        )),
      ),
    );
  }

  makeForm(Color oshicolor) {
    final double y = (Size.h! * 100) - 116;

    List iconList = ref.read(oshiIconNameProvider);
    late List oshiList = ref.read(oshiListProvider);
    late List indexList = ref.read(oshiIndexProvider);
    int index = indexList[oshiList.indexOf(widget.oshi)];

    IconData? oshiIcon = Icons.settings;
    bool _isTapped = false;
    IconSetting(iconName) {
      Map<String, IconData> iconList = {
        "Home": Icons.home,
        "Build": Icons.build,
        "fire": Icons.local_fire_department,
      };

      if (iconList[iconName] != null) {
        setState(() {
          oshiIcon = iconList[iconName];
        });
      }

      return oshiIcon;
    }

    return Column(
      children: [
        Form(
            child: Column(children: <Widget>[
          SizedBox(
            height: y / 8,
            child: TextField(
              controller: _date, // 選択した日付を表示するテキストフィールド
              onTap: () => _selectDate(context), // タップした時に日付を選ぶダイアログを表示
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.calendar_today, color: oshicolor),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: oshicolor),
                  ),
                  labelText: '日付'),
            ),
          ),
          SizedBox(
            height: y / 8,
            child: TextFormField(
              controller: titleController,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.favorite, color: oshicolor),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: oshicolor),
                  ),
                  labelText: 'タイトル'),
            ),
          ),
          SizedBox(
            height: y / 8,
            child: TextFormField(
              controller: moneyController,
              decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: oshicolor),
                  ),
                  prefixIcon: Icon(Icons.attach_money, color: oshicolor),
                  labelText: '金額'),
            ),
          ),
          SizedBox(
            height: y / 8,
            child: TextFormField(
              controller: contentsController,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.chat_bubble_outline, color: oshicolor),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: oshicolor),
                  ),
                  labelText: '萌え語り',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: y * 4 / 8 - 10)),
            ),
          ),
        ])),
        IconButton(
          onPressed: () {
            int tmp = int.parse(moneyController.text);
            setState(() {
              money = money + tmp;
              print(money);
              _isTapped = true; // 新しいステートを設定しtrueにする
            });

            Future.delayed(Duration(milliseconds: 100), () {
              setState(() {
                _isTapped = false; // 元に戻す
              });
            });
          },
          icon: Icon(
            IconSetting(iconList[index]),
            size: y * 3 / 8,
            color: _isTapped ? oshicolor : null, // タップ時にだけ色を変更する
          ),
        ),
      ],
    );
  }
}
