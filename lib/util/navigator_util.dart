import 'package:flutter/material.dart';
class NavigatorUtil {
  //跳转页面
  static push(BuildContext context, Widget page){
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => page
    ));
  }
}