import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class Calender extends ConsumerStatefulWidget {
  final String oshi;
  const Calender({Key? key, required this.oshi}) : super(key: key);

  @override
  ConsumerState<Calender> createState() => _CalenderState();
}

class _CalenderState extends ConsumerState<Calender> {
  late List<dynamic> timeStampList = [];

  void getDate() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      final now = Timestamp.now();

      final query1 = FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .collection("oshi")
          .doc(widget.oshi)
          .collection("nyukin")
          .where('created_at', isLessThan: now)
          .orderBy('created_at', descending: true)
          .limit(1);

      final query2 = FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .collection("oshi")
          .doc(widget.oshi)
          .collection("syukkin")
          .where('created_at', isLessThan: now)
          .orderBy('created_at', descending: true)
          .limit(1);

      final snapshot = await Future.wait([query1.get(), query2.get()]);
      final documentList = snapshot
          .where((s) => s.docs.isNotEmpty)
          .map((e) => e.docs.first)
          .toList();

      setState(() {
        timeStampList =
            documentList.map((e) => e.data()['created_at']).toList();
      });
    });
  }

  Widget build(BuildContext context) {
    // 現在の日付で初期化
    DateTime selectedDate = DateTime.now();

    // 新しい日付を設定した時の処理
    void _onSelectedDate(DateTime date, DateTime date2) {
      setState(() {
        selectedDate = date;
      });
    }

    return MaterialApp(
      home: Scaffold(
        body: TableCalendar(
          onDaySelected: _onSelectedDate,
          calendarBuilders: CalendarBuilders(
            todayBuilder: (BuildContext context, DateTime dateTime, _1) =>
                Container(
              margin: EdgeInsets.all(4.0),
              decoration:
                  BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              child: Center(
                child: Text(
                  dateTime.day.toString(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            selectedBuilder: (BuildContext context, DateTime dateTime, _1) =>
                Container(
              margin: EdgeInsets.all(4.0),
              decoration:
                  BoxDecoration(color: Colors.green, shape: BoxShape.circle),
              child: Center(
                child: Text(
                  dateTime.day.toString(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),

          // 特定の日付に注目させるために同じカレンダーに表示する
          focusedDay: selectedDate,

          // カレンダーを過去から未来に広げるための範囲指定
          firstDay: DateTime.utc(2022, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),

          // 取得したタイムスタンプから日付に変換
          eventLoader: (day) {
            getDate();

            final datetime = Timestamp.fromDate(day).toDate();
            if (timeStampList.contains(datetime)) {
              return [
                InkWell(
                  onTap: () {
                    print("tap");
                  },
                  child: Icon(Icons.check),
                )
              ];
            }

            return [];
          },
        ),
      ),
    );
  }
}
