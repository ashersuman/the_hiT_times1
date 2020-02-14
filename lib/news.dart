import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:photo_view/photo_view.dart';
import 'package:the_hit_times/card_ui.dart';
import 'package:the_hit_times/models/postmodel.dart';

//import 'package:zoomable_image/zoomable_image.dart';

class News extends StatefulWidget {
  @override
  NewsState createState() {
    return new NewsState();
  }
}

class NewsState extends State<News> {
  final String url = "http://thehittimes.herokuapp.com/posts";
  List data;
  PostList allPosts;

  Future<String> getSWData() async {
    var res = await http
        .get(Uri.encodeFull(url), headers: {"Accept": "application/json"});
    //print(allPosts.posts.length);
    setState(() {
      var resBody = json.decode(res.body);
      allPosts = PostList.fromJson(resBody);
      allPosts.posts.sort((a,b) => b.createdAt.compareTo(a.createdAt));
      data = resBody;
    });
    //print(allPosts.posts.length);
    //print(data);
/*    for(var i=0; i<=55; i++){
      print(allPosts.posts[i].id);
    }*/
    //print(data.sort());
    return "Success";
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    this.getSWData();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Expanded(
        child: RefreshIndicator(
          onRefresh: getSWData,
          child: data == null
              ? const Center(child: const CircularProgressIndicator())
              : data.length != 0
                  ? new ListView.builder(
                      itemCount: data == null ? 0 : data.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            Navigator.of(context).push(new MaterialPageRoute(
                              builder: (BuildContext context) => new DisplayPost(
                                    pIndex: index,
                                    /*title: data[data.length - index- 1]['title'],
                                    body: data[data.length - index- 1]['body'],
                                    imgUrl: data[data.length - index- 1]['link'],
                                    date: data[data.length - index- 1]['updated_at'],*/
                                    title: allPosts.posts[index].title,
                                    body: allPosts.posts[index].body,
                                    imgUrl: allPosts.posts[index].link,
                                    date: allPosts.posts[index].createdAt,
                                category: int.parse(
                                    allPosts.posts[index].dropdown),
                                  ),
                            ));
                          },
                          child: CusCard(
                            /*imgUrl: data[data.length - index- 1]['link'],
                            title: data[data.length - index- 1]['title'],*/
                            imgUrl: allPosts.posts[index].link,
                            title: allPosts.posts[index].title,
                          ),
                        );
                      },
                    )
                  : new Center(
                      child: new Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          new Icon(Icons.chrome_reader_mode,
                              color: Colors.grey, size: 60.0),
                          new Text(
                            "No articles found",
                            style:
                                new TextStyle(fontSize: 24.0, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
        ),
      ),
    ]);
  }
}

class DisplayPost extends StatelessWidget {
  DisplayPost(
      {this.pIndex, this.body, this.title, this.imgUrl, this.date, this.category});
  final int pIndex;
  final String body;
  final String title;
  final String imgUrl;
  final String date;
  final int category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
        title: Text(
            'The HIT Times',
            style: TextStyle(
              color: Colors.white
            ),
        ),
        centerTitle: true,
      ),
      body: InkWell(
        /*onDoubleTap: () {
          Navigator.pop(context);
        },*/
        child: ImageScroll(
          title: title,
          body: body,
          imgUrl: imgUrl,
          date: date,
            category: category
        ),
      ),
    );
  }
}

class ImageScroll extends StatefulWidget {
  ImageScroll({this.imgUrl, this.title, this.body, this.date, this.category});

  final String imgUrl;
  final String title;
  final String body;
  final String date;
  final int category;

  @override
  _ImageScrollState createState() => _ImageScrollState();

}


class _ImageScrollState extends State<ImageScroll> {
  bool _zoomEnabled = false;

  _toggleZoom(){
    setState(() {
      _zoomEnabled = !_zoomEnabled;
      print(_zoomEnabled);
    });
  }

  @override
  Widget build(BuildContext context) {

    // TODO: implement build
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              _toggleZoom();
            },
            /*onVerticalDragEnd: (DragEndDetails details) {
              Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => new DisplayBody(
                  body: body,
                  date: date,
                ),
              ));
            },*/

            child: (!_zoomEnabled) ? Container(
              child: Text("Tap to zoom out!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  backgroundColor: Colors.red,
                ),
              ),
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(widget.imgUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ) :
            Container(
              child: new PhotoView(
                imageProvider: CachedNetworkImageProvider(widget.imgUrl),
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.contained,
              ),
            ),
          ),
          widget.category != 03 ?
          GestureDetector(
            onVerticalDragEnd: (DragEndDetails details) {
              Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => new DisplayBody(
                      body: widget.body,
                      date: widget.date,
                    ),
              ));
            },
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.3,
                color: Colors.black26,
                child: Column(
                  children: <Widget>[
                    Flexible(
                      fit: FlexFit.tight,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.only(left: 10.0, bottom: 2.0),
                          child: widget.title.length < 15 ? Text(
                            widget.title,
                            style: TextStyle(
                              //inherit: true,
                              color: Colors.white,
                              fontSize: 32.0,
                              fontWeight: FontWeight.w600,
                              fontFamily: "Exo"
                            ),
                          ):
                          Text(
                            widget.title,
                            style: TextStyle(
                              //inherit: true,
                                color: Colors.white,
                                fontSize: 29.0,
                                fontWeight: FontWeight.w600,
                                fontFamily: "Exo"
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(bottom: 8.0),
                      child: Column(
                        children: <Widget>[
                          Icon(
                            Icons.keyboard_arrow_up,
                            size: 60.0,
                            color: Colors.white,
                          ),
                          Text(
                            'Scroll to read',
                            style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.w400,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ) : Container(
            margin: EdgeInsets.all(0.0),
          )
        ],
      ),
    );
  }
}

class DisplayBody extends StatelessWidget {
  DisplayBody({this.body, this.date, this.author});

  final String body;
  final String date;
  final String author;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('The HIT Times'),
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
      ),
      body: ListView(
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Container(
                alignment: Alignment.topLeft,
                padding: new EdgeInsets.only(left: 10.0, right: 10.0),
                child: new Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    '',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                        fontFamily: "Anson"),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.bottomRight,
                padding: new EdgeInsets.only(left: 10.0, right: 10.0),
                child: new Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    date,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15.0,
                        color: Colors.black54,
                        fontFamily: "Anson"),
                  ),
                ),
              ),
            ],
          ),
          new Container(
            padding: new EdgeInsets.only(left:12.0,right:12.0,bottom: 12.0),
            child: new Padding(
              padding: const EdgeInsets.all(1.0),
              child: new Text(
                body,
                style: new TextStyle(
                    color: Colors.black54,
                    fontSize: 22.0,
                    fontFamily: "Cambo"
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

