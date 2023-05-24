import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import "package:cloud_firestore/cloud_firestore.dart";

import 'page/home.dart';
import "sign_up.dart";
import 'config/size_config.dart';

//新しくユーザーを作成す'page/home.dart'Sign_in extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Sign_in(),
    );
  }

class Sign_in extends StatefulWidget {
  @override
  State<Sign_in> createState() => _Sign_in();
}

class _Sign_in extends State<Sign_in> {
  String email = "";
  String pass = "";
  bool view = false;

  void mail_pass(mail_ad, pass) async {
    try {



      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: mail_ad,
        password: pass,
      );

      final user = credential.user;
      final uuid = user?.uid;
      // usersコレクションを作成して、uidとドキュメントidを一致させるプログラムを定義
      final users =
          FirebaseFirestore.instance.collection('users').doc(uuid).set({
        'uid': uuid,
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Home(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('そのパスワードは脆弱性があるため利用できません');
      } else if (e.code == 'email-already-in-use') {
        print('そのメールアドレスはすでに利用されているようです。');
      } else {
        print("アカウント作成に重大なエラーが起こりました。作成者に連絡してください。");
      }
    } catch (e) {
      print(e);
    }
  }

  Widget build(BuildContext context) {
    Size().init(context);
    return MaterialApp(
      home: Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Color.fromARGB(255, 118, 161, 184),
                width: Size.w! * 1,
              ),
            ),
            width: Size.w! * 70,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      icon: Icon(Icons.mail),
                      labelText: "メールアドレス",
                    ),
                    onChanged: (text) {
                      setState(() {
                        email = text;
                      });
                    }),
                TextField(
                    decoration: InputDecoration(
                      icon: Icon(Icons.key),
                      labelText: "パスワード",
                      suffixIcon: IconButton(
                        icon: Icon(
                            view ? Icons.visibility_off : Icons.visibility),
                        onPressed: () {
                          setState(() {
                            view = !view;
                          });
                        },
                      ),
                    ),
                    style: TextStyle(color: Color.fromARGB(255, 62, 58, 58)),
                    onChanged: (text) {
                      setState(() {
                        pass = text;
                      });
                    },
                    obscureText: view),
                Padding(padding: EdgeInsets.only(top: Size.h! * 7)),
                OutlinedButton(
                  child: Text("新規作成"),
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 118, 161, 184)),
                  ),
                  onPressed: () {
                    mail_pass(email, pass);
                  },
                ),
                TextButton(
                  child: const Text('アカウントをお持ちの方はこちらから'),
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 62, 58, 58)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Sign_up(),
                      ),
                    );
                  },
                ),
              ]),
            ),
          ),
        ),
      ),
      ),
    );
  }
}
