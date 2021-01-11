import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dictionary_app/api_protocol.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  StreamController _streamController;
  Stream _stream;
  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    _streamController = StreamController();
    _stream = _streamController.stream;
    super.initState();
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.centerRight,
              colors: [Colors.pink, Colors.purple],
            ),
          ),
        ),
        title: Text("Find Words"),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size(double.infinity, 60),
          child: Container(color: Colors.white, child: _buildSearchField()),
        ),
      ),
      body: StreamBuilder(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Center(
              child: Text(
                "Type a Word to search",
                style: Theme.of(context).textTheme.headline4,
              ),
            );
          } else if (snapshot.data == 'waiting') {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.data == 'NoData') {
            return Center(
              child: Text("No Definition Found"),
            );
          }
          String def = snapshot.data['definitions'][0]['definition'];
          String url = snapshot.data['definitions'][0]['image_url'];
          String title = snapshot.data['definitions'][0]['type'];
          return _buildBody(title, def, url);
        },
      ),
      resizeToAvoidBottomPadding: false,
    );
  }

  _buildBody(String title, String definition, String url) => Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title ?? "",
              style: Theme.of(context)
                  .textTheme
                  .headline4
                  .copyWith(fontWeight: FontWeight.bold, color: Colors.black),
            ),
            Text(
              'Type'.toUpperCase(),
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              definition ?? "Nothing Found",
              style: Theme.of(context).textTheme.bodyText1.copyWith(
                    fontSize: 20.0,
                  ),
            ),
            SizedBox(
              height: 10.0,
            ),
            url != null
                ? Image.network(
                    url,
                    height: 200.0,
                    width: 200.0,
                  )
                : Container(),
          ],
        ),
      );

  _buildSearchField() {
    return TextField(
      controller: _textEditingController,
      textInputAction: TextInputAction.search,
      onSubmitted: (value) {
        _searchWord();
      },
      onChanged: (String value) {},
      decoration: InputDecoration(
        hintText: 'search word',
        suffixIcon: IconButton(
          onPressed: () {
            _searchWord();
          },
          icon: Icon(Icons.search),
        ),
        hintStyle: TextStyle(
          fontSize: 20.0,
          color: Colors.black,
        ),
        border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 2.0)),
        disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black, width: 2.0)),
      ),
    );
  }

  _searchWord() async {
    if (_textEditingController == null ||
        _textEditingController.text.length == 0) {
      _streamController.add(null);
      return;
    } else {
      _streamController.add('waiting');
      final map = {'Authorization': 'Token ' + token};
      final response = await http.get(url + _textEditingController.text.trim(),
          headers: map);
      if (response.body.contains('[{"message":"No definition :("}]')) {
        _streamController.add("NoData");
        return;
      } else {
        final json = jsonDecode(response.body);
        _streamController.add(json);
        return;
      }
    }
  }
}
