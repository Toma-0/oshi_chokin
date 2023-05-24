import "package:cloud_firestore/cloud_firestore.dart";
import 'package:firebase_auth/firebase_auth.dart';

import "../state/state.dart";

class UserInformation {
  static String userName = "ffffff";
  static int goal_money = 0;
  static int sum_money = 0;
  static List<dynamic> oshi_list = [];

  void userInfo(Wref) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        var user_id = user.uid;

        var db = FirebaseFirestore.instance;

        final docRef = db.collection("users").doc(user_id);

        docRef.get().then(
          (ref) {
            userName = ref.get("name");
            goal_money = ref.get("goal_money");
            sum_money = ref.get("sum_money");
            oshi_list = ref.get("oshi_name") as List<dynamic>;

            Wref.read(userNameProvider.notifier).state = userName;
            Wref.read(oshiListProvider.notifier).state = oshi_list;
            Wref.read(goalMoneyProvider.notifier).state = goal_money;
            Wref.read(sumMoneyProvider.notifier).state = sum_money;
          },
          onError: (e) => print("Error getting document: $e"),
        );
      } else {
        userName = "test";
      }
    });
  }
}
