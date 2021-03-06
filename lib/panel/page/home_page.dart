import 'package:flutter/material.dart';
import 'package:coc_trpg/model/Investigator.dart';
import 'package:coc_trpg/model/Property.dart';
import 'package:coc_trpg/panel/page/property_page.dart';
import 'package:coc_trpg/model/Skill.dart';
import 'package:coc_trpg/utils/AppConfig.dart';
import 'note_list_page.dart';
import 'package:coc_trpg/create/page/create_model_page.dart';
import 'package:coc_trpg/AppThemeData.dart';
import 'dart:convert';
import 'dart:io';
import 'package:coc_trpg/create/widget/next_step_button.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
class HomePage extends StatefulWidget{
  HomePage({Key key}): super(key: key);

  @override
  _HomePage createState() => _HomePage();

}


class _HomePage extends State<HomePage>{

  List<Investigator> investigatorList = List();
  String HPImage = "asset/head.jpg";
  String SANImage = "asset/head.jpg";
  PageController _pageController;
  PageView _pageView;
  int _currentPage = 0;
  var _futureBuilderFuture;
  List<Widget> listViewWidget = List();
  bool hasInvestigator = false;
  Investigator currentInvestigator;


  List<Widget> loadSkillWidgetList(List<Skill> skillList){
    List<Widget> skillWidgetList = new List();
    for (var skill in skillList){
      skillWidgetList.add(
        new Container(
          margin: EdgeInsets.only(bottom: 5),
          alignment: Alignment.center,
          child:Text("${skill.label} ${skill.value}",style: TextStyle(fontSize: 22),)
        )
      );
    }
    return skillWidgetList;

  }

  Map<String,int> loadPropertyTestData(){
    Map<String,int> map = Map();
    for(var item in investigatorList[0].skills){
      map[item.label] = item.value;
    }
    return map;
  }

  List<Widget> loadPropertyWidgetList(List<Property> propertyList){
    List<Widget> propertyWidgetList = new List();
    for(var property in propertyList){
      propertyWidgetList.add(
        new Container(
          alignment: Alignment.center,
          child: Flex(
              direction:Axis.horizontal,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Text(property.label,style:TextStyle(fontSize: 22,color: Colors.grey)),
              ),
              Expanded(
                flex: 1,
                child: Text(property.value.toString(),style:TextStyle(fontSize: 22)),
              )
            ],
          ),
        )
      );
    }
    return propertyWidgetList;
  }


  @override
  void initState(){
    super.initState();
    _futureBuilderFuture = loadInvestigators();


  }


  Future loadInvestigators() async{

    Investigator investigator = new Investigator();
    final localDir = await getApplicationDocumentsDirectory();
    List<FileSystemEntity> files = [];
    files = Directory(localDir.path).listSync();
    for(var item in files){

      print(item.path.substring(item.path.length-4,item.path.length));
      if(item.path.substring(item.path.length-4,item.path.length) == "json"){
        hasInvestigator = true;
        File file = File(item.path);
        String content = await file.readAsString();
        print(content);
        investigator = Investigator.fromJson(json.decode(content));
        investigator.imageUrl = "assets/head.jpg";
        investigatorList.add(investigator);
      }
    }
    if(!hasInvestigator){
      investigator.name = "创建新角色";
      investigator.properties = loadTestProperty();
      investigator.skills = loadTestSkillList();
      investigator.imageUrl = "assets/head.jpg";
      investigatorList.add(investigator);
    }

    currentInvestigator = investigatorList[0];
    _pageController = new PageController();
    _pageView = new PageView(
      controller: _pageController,
      children: <Widget>[
        PropertyPage(attributeData: currentInvestigator.properties,),
        PropertyPage(attributeData:currentInvestigator.skills),
      ],
      onPageChanged: (index){
        setState(() {
          _currentPage = index;
        });
      },
    );

  }

  List<Property> loadTestProperty(){
    List<Property> propertyList = new List();
    for(int i=0;i<8;i++){
      Property property = Property();
      property.label = "幸运";
      property.value = 60;
      property.name = "LUC";
      propertyList.add(property);
    }
    return propertyList;
  }
  List<Skill> loadTestSkillList(){
    List<Skill> skillList = new List();
    for(int i=0;i<8;i++){
      Skill skill = new Skill();
      if(i==1){
        skill.name = "lib";
        skill.label = "图书馆";
        skill.value = 60;
        skillList.add(skill);
        continue;
      }
      skill.name = "Search";
      skill.label = "侦察";
      skill.value = 60;
      skillList.add(skill);
    }
    return skillList;
  }

  Widget buildBottomButton(String imageUrl,String name){
    return Container(
        constraints: BoxConstraints(
          maxHeight: 80,
        ),
        child:Column(
          children: <Widget>[
            IconButton(
                icon: ImageIcon(
                  AssetImage(imageUrl),
                  color: AppTheme.investigatorMainColor,
                  size: 40,)
            ),
            Text(name,style: TextStyle(color: AppTheme.investigatorMainColor),)
          ],
        )
    );
  }

  Widget buildBottomAppbar(){

    return BottomAppBar(
      color: Color(0x44000000),
      shape: CircularNotchedRectangle(), // 底部导航栏打一个圆形的洞
      child: Row(
        children: [
          buildBottomButton(AppConfig.encyImage, "百科"),
          buildBottomButton(AppConfig.ruleImage, "规则"),
          SizedBox(), //中间位置空出
          SizedBox(), //中间位置空出
          SizedBox(), //中间位置空出
          buildBottomButton(AppConfig.documentImage, "档案"),
          buildBottomButton(AppConfig.individualImage, "我的"),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceAround, //均分底部导航栏横向空间
      ),
    );
  }

  Widget buildIvesHeadImage(String imageUrl){
    return  Container(
      width: 150.0,
      height: 150.0,
      decoration: new BoxDecoration(
        color: Colors.white,
        image:new DecorationImage(
            image: new AssetImage(imageUrl),
            fit: BoxFit.cover
        ),
        shape: BoxShape.circle,
      ),
    );
  }
  selectPopItem(IconData icon, String text, String id) {
    return new PopupMenuItem<String>(
        value: id,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            new Icon(icon, color: Colors.white),
            new Text(text,style: TextStyle(color: Colors.white),),
          ],
        )
    );
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    showInvestigatorChosenDialog(BuildContext context){
      showDialog(
          context: context,
        builder: (context){
            return AlertDialog(
              backgroundColor: AppTheme.investigatorMinorColor,
              title: Text("选择调查员",style: AppTheme.dialogTextStyle,),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.5,
                child: ListView.builder(
                  itemCount: investigatorList.length,
                    itemBuilder: (context,index){
                      return Container(
                        child: FlatButton(
                            onPressed:(){
                              setState(() {
                                currentInvestigator = investigatorList[index];
                                _pageView = new PageView(
                                  controller: _pageController,
                                  children: <Widget>[
                                    PropertyPage(attributeData: currentInvestigator.properties,),
                                    PropertyPage(attributeData:currentInvestigator.skills),
                                  ],
                                  onPageChanged: (index){
                                    setState(() {
                                      _currentPage = index;
                                    });
                                  },
                                );
                                Navigator.of(context).pop();
                              });
                            },
                            child: Text(
                              investigatorList[index].name,
                              style:AppTheme.dialogTextStyle,
                            ),
                        ),
                      );
                    }
                ),
              ),
            );
        }
      );
    }
    Widget buildMainListWidget(){
      return Scaffold(
          backgroundColor: Colors.transparent,
          appBar:  AppBar(
            title: Container(
              alignment: Alignment.center,
              child: Text(currentInvestigator.name,style: TextStyle(color: Colors.white),),
            ),
            backgroundColor: Color(0x22000000),
            elevation: 0,
            actions: <Widget>[
              PopupMenuButton<String>(
                color: AppTheme.investigatorMinorColor,
                itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                  selectPopItem(Icons.add, '添加调查员', 'A'),
                  selectPopItem(Icons.person, '我的调查员', 'B'),
                ],
                onSelected: (String action) {
                  // 点击选项的时候
                  switch (action) {
                    case 'A':
                      Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) =>CreateModelPage()));
                      break;
                    case 'B':
                      showInvestigatorChosenDialog(context);
                      break;
                    case 'C': break;
                  }
                },
              )
            ],
          ),
          bottomNavigationBar: buildBottomAppbar(),
          body: !hasInvestigator ?
          Center(

            child: Container(
              alignment: Alignment.center,
              child: Column(
                children: <Widget>[
                  Text(
                    "还未创建调查员",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16
                    ),
                  ),
                  NextStepButton(
                    text: "点击创建",
                    onPressFunction: (){
                      Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) =>CreateModelPage()));
                    },
                  )
                ],
              ),
            )
          ):
          ListView(
            shrinkWrap: true,
            children: <Widget>[
                Container(
                padding: EdgeInsets.all(20),
                child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(SANImage,width: 40,height: 40,),
                  buildIvesHeadImage(currentInvestigator.imageUrl),
                  Image.asset(SANImage,width: 40,height: 40,),
                ],
              ),
            ),
              Container(
                alignment: Alignment.centerRight,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(25),
                          bottomLeft: Radius.circular(25))
                  ),
                  color: Color(0xff20BAC1),
                  child: Container(
                      constraints: BoxConstraints(
                        maxWidth: 110,
                      ),
                      child:Row(
                        children: <Widget>[
                          ImageIcon(
                            AssetImage(AppConfig.noteImage),
                            color: Colors.white,
                            size: 30,
                          ),
                          Text("调查笔记",style: TextStyle(fontSize: 20,
                              color: Colors.white),),

                        ],
                      )
                  ),
                  onPressed: (){
                    Navigator.push(context,
                        MaterialPageRoute(builder: (BuildContext context) =>NoteListPage()));
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 15),
                alignment: Alignment.centerLeft,
                constraints: BoxConstraints(
                  maxWidth: 150,
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      decoration:_currentPage == 0 ? BoxDecoration(
                        color: Colors.white,
                      ):BoxDecoration(
                        color:  Color(0x22000000),),
                      child: Center(
                        child: FlatButton(
                            onPressed: (){
                              _pageController.animateToPage(0,
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.decelerate);
                            },
                            child: Text("属性",style: TextStyle(fontSize: 18),)
                        ),
                      ),
                    ),

                    Container(
                      decoration:_currentPage == 1 ? BoxDecoration(
                        color: Colors.white,
                      ):BoxDecoration(
                        color:  Color(0x22000000),
                      ),
                      child: Center(
                        child: FlatButton(
                            onPressed: (){
                              _pageController.animateToPage(1,
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.decelerate);
                            },
                            child: Text("技能",style: TextStyle(fontSize: 18),)
                        ),
                      ),
                    ),

                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(15,0,15,5),
                constraints: BoxConstraints(
                    maxHeight: 430,
                    maxWidth: 180
                ),
                child: _pageView,
                decoration: BoxDecoration(
                  color: Color(0x22000000),
                ),
              )
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            backgroundColor: Color(0xff20BAC1),
            child: Image.asset(
              AppConfig.homeImage,width: 30,height: 30,),
            onPressed: (){

            },
          )
      );
    }
    Widget _buildFuture(BuildContext context, AsyncSnapshot snapshot){
      switch (snapshot.connectionState) {
        case ConnectionState.none:
          print('none');
          return Text('ConnnectionState.none');
        case ConnectionState.active:
          print('active');
          return Text('ConnectionState.active');
        case ConnectionState.waiting:
          print('waiting');
          return Center(
            child: CircularProgressIndicator(),
          );
        case ConnectionState.done:
          print('done');
          if (snapshot.hasError) return Text('Error: ${snapshot.error}');
          return buildMainListWidget();
        default:
          return null;
      }
    }

    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xbb20BAC1), Colors.grey],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          )
      ),
      child:FutureBuilder(
        builder: _buildFuture,
        future: _futureBuilderFuture,
      ),
    );
  }

}


