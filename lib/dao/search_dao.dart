// import 'dart:async';

// import 'package:dio/dio.dart';
// import 'package:flutter_travel/model/search_model.dart';

// const SEARCH_URL =
//     'https://m.ctrip.com/restapi/h5api/searchapp/search?source=mobileweb&action=autocomplete&contentType=json&keyword=';

// ///搜索接口
// class SearchDao {
//   static Future<SearchModel> fetch(String keyword) async {
//     Response response = await Dio().get(SEARCH_URL + keyword);
//     if (response.statusCode == 200) {
//       //只有当输入的内容与服务端返回的内容一致时才渲染
//       SearchModel model = SearchModel.fromJson(response.data);
//       model.keyword = keyword;
//       return model;
//     } else {
//       throw Exception('Failed to load search');
//     }
//   }
// }
import 'dart:async';
import 'dart:convert';
import 'package:flutter_travel/model/search_model.dart';
import 'package:http/http.dart' as http;


const SEARCH_URL='https://m.ctrip.com/restapi/h5api/searchapp/search?source=mobileweb&action=autocomplete&contentType=json&keyword=';
class SearchDao{
  static Future<SearchModel> fetch(text) async {
    final response = await http.get(SEARCH_URL+text);
    if(response.statusCode == 200){
      Utf8Decoder utf8decoder =  Utf8Decoder(); //修复中文乱码
      var result = json.decode(utf8decoder.convert(response.bodyBytes));
      //只有当当前输入的内容和服务器返回的内容一致时才渲染
      SearchModel model = SearchModel.fromJson(result);
      model.keyword = text;
      return model;
    }else{
      throw Exception('请求首页接口失败');
    }
  }
}
