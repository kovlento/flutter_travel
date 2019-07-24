import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutter_travel/dao/home_dao.dart';
import 'package:flutter_travel/model/grid_nav_model.dart';
import 'dart:convert';
import 'package:flutter_travel/model/home_model.dart';
import 'package:flutter_travel/model/common_model.dart';
import 'package:flutter_travel/model/sales_box_model.dart';
import 'package:flutter_travel/pages/search_page.dart';
import 'package:flutter_travel/widget/grid_nav.dart';
import 'package:flutter_travel/widget/local_nav.dart';
import 'package:flutter_travel/widget/sales_box.dart';
import 'package:flutter_travel/widget/search_bar.dart';
import 'package:flutter_travel/widget/sub_nav.dart';
import 'package:flutter_travel/widget/loading_container.dart';
import 'package:flutter_travel/widget/webview.dart';
import 'package:flutter_splash_screen/flutter_splash_screen.dart';

const APPBAR_SCROLL_OFFSET = 100;
const SEARCH_BAR_DEFAULT_TEXT = '网红打卡地 景点 酒店 美食';
class HomePage extends StatefulWidget{
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  // List _imageUrls = [
  //   'https://ss1.bdstatic.com/70cFuXSh_Q1YnxGkpoWK1HF6hhy/it/u=1638695478,3359394321&fm=27&gp=0.jpg',
  //   'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1562915364207&di=99113c5385ab195901763b10a3f3be9f&imgtype=0&src=http%3A%2F%2Fimg1.cache.netease.com%2Fcatchpic%2F8%2F8D%2F8DB991E2392FA6287414E996F98BF8A9.jpg',
  //   'https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1562915364205&di=d0ac7bc7bf8f70df1d4ffda573f04238&imgtype=0&src=http%3A%2F%2Fimg.pconline.com.cn%2Fimages%2Fupload%2Fupc%2Ftx%2Fitbbs%2F1405%2F04%2Fc11%2F33834031_1399170113979_mthumb.jpg',
  // ];
  double appBarAlpha = 0;
  String resultString = '';
  List<CommonModel> localNavList = [];
  List<CommonModel> bannerList = [];
  List<CommonModel> subNavList = [];
  GridNavModel gridNavModel;
  SalesBoxModel salesBoxModel;
  bool _loading = true;

  @override
  void initState(){
    super.initState();
    _handleRefesh();
    Future.delayed(Duration(milliseconds:600),(){
      FlutterSplashScreen.hide();
    });
    // FlutterSplashScreen.hide();
  }

  _onScoll(offset){
    double alpha = offset/APPBAR_SCROLL_OFFSET;
    if(alpha<0){
      alpha=0;
    }else if(alpha>1){
      alpha=1;
    }
    setState(() {
      appBarAlpha = alpha;
    });
    print(appBarAlpha);
  }

  // loadData(){
  //   HomeDao.fetch().then((result){
  //     setState((){
  //       resultString = json.encode(result);
  //     });
  //   }).catchError((e){
  //     setState((){
  //       resultString = e.toString();
  //     });
  //   });
  // }

  Future<Null> _handleRefesh() async{
    try {
      HomeModel model  =await HomeDao.fetch();
      setState((){
        localNavList = model.localNavList;
        subNavList = model.subNavList;
        gridNavModel = model.gridNav;
        salesBoxModel  = model.salesBox;
        bannerList = model.bannerList;
        _loading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        _loading = false;  
      });
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff2f2f2),
      body:LoadingContainer(isLoading: _loading,child: Stack(
        children: <Widget>[
          //去掉listview顶部的padding
          MediaQuery.removePadding(
          removeTop: true,
          context: context, 
          child: RefreshIndicator(
              child: NotificationListener(
              onNotification: (ScrollNotification){
                if(ScrollNotification is ScrollUpdateNotification && ScrollNotification.depth==0){
                  //列表滚动的时候
                  _onScoll(ScrollNotification.metrics.pixels);
                }
              },
              child: _listView,
            ),
            onRefresh: _handleRefesh,
          ) 
          ),
          _appBar,
        ],
      ),)
    );
  }
  Widget  get _listView {
    return ListView(
      children: <Widget>[
        _banner,
        Padding(
          padding: EdgeInsets.fromLTRB(7, 4, 7, 4),
          child:LocalNav(localNavList: localNavList,),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(7, 0, 7, 4),
          child:GridNav(gridNavModel: gridNavModel),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(7, 0, 7, 4),
          child:SubNav(subNavList: subNavList),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(7, 0, 7, 4),
          child:SalesBox(salesBox: salesBoxModel),
        ) 
      ],
    );
  }
  Widget get _appBar {
    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0x66000000), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter
            )
          ),
          child: Container(
            padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
            height: 80.0,
            decoration: BoxDecoration(
              color: Color.fromARGB((appBarAlpha * 255).toInt(), 255, 255, 255),
            ),
            child:SearchBar(
            searchBarType: appBarAlpha > 0.2
            ? SearchBarType.homeLight
              : SearchBarType.home,
            inputBoxClick: _jumpToSearch,
            speakClick: _jumpToSpeak,
            defaultText:  SEARCH_BAR_DEFAULT_TEXT,
            leftButtonClick: (){

            },
          ),
          ),
        ),
        Container(
          height: appBarAlpha> 0.2 ?0.5: 0,
          decoration: BoxDecoration(
            boxShadow: [BoxShadow(color: Colors.black12,blurRadius: 0.5) ]
          ),
        )
      ],
    );
    
    

  }

  Widget get _banner {
    return Container(
      height: 160,
      child: Swiper(
        itemCount: bannerList.length,
        autoplay: true,
        itemBuilder: (BuildContext context,int index){
          return GestureDetector(
            onTap: (){
              Navigator.push(context, 
                MaterialPageRoute(builder: (context) {
                  CommonModel model = bannerList[index];
                  WebView(url: model.url, title:model.title, statusBarColor:model.statusBarColor,hideAppBar: model.hideAppBar);
                }
                )
              );
            },
            child: Image.network(
              bannerList[index].icon,
              fit:BoxFit.fill,
            ),
          );
        },
        pagination: SwiperPagination(),
      ),
    );
  }

  _jumpToSearch() {
    Navigator.push(context, MaterialPageRoute(builder: (context)=>
      SearchPage(hint:SEARCH_BAR_DEFAULT_TEXT)
    ));
  }
  _jumpToSpeak() {

  }
}