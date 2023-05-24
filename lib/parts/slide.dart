import 'package:flutter/material.dart';

class fild {
  _fild(List list,x,y) {
    //ウィジェットのリストを入力。
    //Rowを返す。
    return Container(
      width: x,
      height: y,
      alignment: AlignmentDirectional.center,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (int i = 0; i < list.length; i++) list[i],
          ],
        ),
      ),
    );
  }
}
