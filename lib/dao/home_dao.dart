import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_travel/model/home_model.dart';


const HOME_URL='http://140.143.147.167:8180/travel.json';
class HomeDao{
  static Future<HomeModel> fetch() async {
    final response = await http.get(HOME_URL);
    if(response.statusCode == 200){
      Utf8Decoder utf8decoder =  Utf8Decoder(); //修复中文乱码
      var result = json.decode(utf8decoder.convert(response.bodyBytes));
      return HomeModel.fromJson(result);
    }else{
      throw Exception('请求首页接口失败');
    }
  }
}