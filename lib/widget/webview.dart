import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
const CATCH_URLS = ['m.ctrip.com/', 'm.ctrip.com/html5/', 'm.ctrip.com/html5'];


class WebView extends StatefulWidget{
  final String title;
  String url;
  final String statusBarColor;
  final bool hideAppBar;
  final bool backForbid;

  WebView({this.title,this.url,this.statusBarColor,this.backForbid = false,this.hideAppBar}){
    if (url != null && url.contains('ctrip.com')) {
      //fix 携程H5 http://无法打开问题
      url = url.replaceAll("http://", 'https://');
    }
  }

  @override
  _WebViewState createState() => _WebViewState();
}

class _WebViewState extends State<WebView>{
  final webviewReference = new FlutterWebviewPlugin();
  StreamSubscription<String> _onUrlChange;
  StreamSubscription<WebViewStateChanged> _onStateChanged;
  StreamSubscription<WebViewHttpError> _onHttpError;
  bool exiting = false;

  @override
  void initState() {
    super.initState();
    webviewReference.close();
    _onUrlChange = webviewReference.onUrlChanged.listen((String url){
      //对非http获取https链接判断(不加会出现无法显示网站的错误)
      if (url == null || !url.startsWith('http')) {
        webviewReference.stopLoading();
      }
    });
    _onStateChanged = webviewReference.onStateChanged.listen((WebViewStateChanged state){
      switch(state.type){
        case WebViewState.shouldStart:
          break;
        case WebViewState.startLoad:
          if(_isToMain(state.url) && !exiting){
            if(widget.backForbid){
              webviewReference.launch(widget.url);
            }else{
              Navigator.pop(context);
              exiting = true;
            }
          }
          break;
        case WebViewState.finishLoad:
          break;
        case WebViewState.abortLoad:
          break;
        default:
          break; 
      }
    });
    _onHttpError = webviewReference.onHttpError.listen((WebViewHttpError error){
      print(error);
    });
  }

  _isToMain(String url){
    bool contain = false;
    for(final value in CATCH_URLS){
      if(url?.endsWith(value)??false){
        contain = true;
        break;
      } 
    }
    return contain;
  }
  @override
  void dispose() {
    _onUrlChange.cancel();
    _onStateChanged.cancel();
    _onHttpError.cancel();
    webviewReference.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String statusBarColorStr = widget.statusBarColor ?? 'ffffff';
    Color backButtonColor;
    if(statusBarColorStr == 'ffffff') {
      backButtonColor = Colors.black;
    }else {
      backButtonColor = Colors.white;
    }
    return Scaffold(
      body: Column(
        children: <Widget>[
          _appBar(Color(int.parse('0xff'+statusBarColorStr)),backButtonColor),
          Expanded(child: WebviewScaffold(
            url: widget.url,
            userAgent: 'null', //防止携程H5页面重定向到打开携程APP ctrip://wireless/xxx的网址
            withZoom: true,
            withLocalStorage: true,
            hidden: true,
            enableAppScheme: true,
            initialChild: Container(
              color: Colors.white,
              child: Center(child: CircularProgressIndicator(),),
            ),
          ),)
        ],
      ),
    );
  }

  _appBar(Color backgroudColor, Color backButtonColor){
    if(widget.hideAppBar??false){
      return Container(
        color: backgroudColor,
        height: 30,
      );
    }
    return Container(
      color: backgroudColor,
      padding: EdgeInsets.fromLTRB(0, 40, 0, 10),
      child: FractionallySizedBox(
        widthFactor: 1,
        child: Stack(
          children: <Widget>[
            GestureDetector(
              onTap: (){
                Navigator.pop(context);
              },
              child: Container(
                margin: EdgeInsets.only(left: 10), 
                child: Icon(Icons.close, color: backButtonColor,size: 26,),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              child: Center(
                child: Text(widget.title??'',style:TextStyle(color:backgroudColor,fontSize: 20)),
              ),
            )
          ],
        ),
      ),
    );
  }
}