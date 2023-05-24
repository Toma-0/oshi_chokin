// Riverpod関連のライブラリーのインポート
import 'package:flutter_riverpod/flutter_riverpod.dart';

//状態管理
final userNameProvider = StateProvider((ref) => 'Hello World');
final goalMoneyProvider = StateProvider((ref) => 0);
final sumMoneyProvider = StateProvider((ref) => 0);
final oshiListProvider = StateProvider((ref) => []);
final oshiColorProvider = StateProvider((ref) => []);
final oshiIconNameProvider = StateProvider((ref) => []);
final oshiGoalMoneyProvider = StateProvider((ref) => []);
final oshiSumMoneyProvider = StateProvider((ref) => []);
final oshiImageListProvider =
    StateProvider<Map<int, Map<int, List<String>>>>((ref) => {0: {}});

final oshiIndexProvider = StateProvider((ref) => []);