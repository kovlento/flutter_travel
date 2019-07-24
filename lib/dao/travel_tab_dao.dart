import 'dart:async';
import 'dart:convert';
import 'package:flutter_travel/model/travel_tab_model.dart';
import 'package:http/http.dart' as http;


//旅拍类型接口
const TRAVEL_TAB_URL =
    'https://apk-1256738511.file.myqcloud.com/FlutterTrip/data/travel_page.json';

class TravelTabDao{
  static Future<TravelTabModel> fetch() async {
    final response = await http.get(TRAVEL_TAB_URL);
    if(response.statusCode == 200){
      Utf8Decoder utf8decoder =  Utf8Decoder(); //修复中文乱码
      var result = json.decode(utf8decoder.convert(response.bodyBytes));
      return TravelTabModel.fromJson(result);
    }else{
      throw Exception('请求旅拍类型接口失败');
    }
  }
}