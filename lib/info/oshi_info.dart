import "package:cloud_firestore/cloud_firestore.dart";
import 'package:firebase_auth/firebase_auth.dart';

import "../state/state.dart";

class OshiInformation {
  void listSetting(list, content, i) {
    if (list.length <= i) {
      list.add(content);
    } else {
      list[i] = content;
    }
  }

  oshiInfo(list, Wref) async {
    List colorList = Wref.read(oshiColorProvider);
    List iconList = Wref.read(oshiIconNameProvider);
    List goalList = Wref.read(oshiGoalMoneyProvider);
    List sumList = Wref.read(oshiSumMoneyProvider);
    Map<int, Map<int, List<String>>> oshiImageList =
        Wref.read(oshiImageListProvider);

    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        var user_id = user.uid;
        var db = FirebaseFirestore.instance;
        final tasks = <Future>[];

        for (int i = 0; i < list.length; i++) {
          final docRef = db
              .collection("users")
              .doc(user_id)
              .collection("oshi")
              .doc(list[i]);

          final task = docRef.get().then((snapshot) {
            if (snapshot.exists && snapshot.data() != null) {
              final ref = snapshot.data()!;

              final color = "FF" + ref['color'];
              final icon = ref['icon'];
              final goal = ref['goal_money'];
              final sum = ref['sum_money'];

              listSetting(colorList, color, i);
              listSetting(iconList, icon, i);
              listSetting(goalList, goal, i);
              listSetting(sumList, sum, i);

              final int num = ref['imageNum'];

              List<String> urlData = [];
              Map<int, List<String>> mapData = {};

              for (int j = 0; j < num; j++) {
                var imgDoc = docRef.collection("images").doc(j.toString());
                imgDoc.get().then((ref) {
                  String? tmp = ref.get("imageURL");
                  if (tmp != null) {
                    urlData.add(ref.get("imageURL") as String);
                  }
                });

                mapData[j] = urlData;
              }

              oshiImageList[i] = mapData;

              Wref.read(oshiColorProvider.notifier)
                  .update((state) => colorList);
              Wref.read(oshiIconNameProvider.notifier)
                  .update((state) => iconList);
              Wref.read(oshiGoalMoneyProvider.notifier)
                  .update((state) => goalList);
              Wref.read(oshiSumMoneyProvider.notifier)
                  .update((state) => sumList);
              Wref.read(oshiImageListProvider.notifier)
                  .update((state) => oshiImageList);
            } else {
              print('そのデータは存在しません');
            }
          });

          tasks.add(task);
        }
      }
    });
  }
}
