import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wisgen/data/wisdoms.dart';
import 'package:connectivity/connectivity.dart';

import 'adviceCard.dart';
import 'data/advice.dart';
import 'data/stockImg.dart';
import 'loadingCard.dart';

class CardFeed extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CardFeedState();
}

class CardFeedState extends State<CardFeed> {
  static const _adviceURI = 'https://api.adviceslip.com/advice';
  static const _imagesURI = 'https://source.unsplash.com/800x600/?';

  static const minQueryWordLenght = 3;
  final RegExp nonLetterPattern = new RegExp("[^a-zA-Z0-9]");
  StreamSubscription networkSubscription;
  final _wisdomList = <Wisdom>[];

  @override
  void initState() {
    super.initState();

    networkSubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        _showDialog("You don’t have an Internet Connection",
            "Sadly we can't provide Wisdom without the Power of the Internet :(");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemBuilder: (context, i) {
          return FutureBuilder(
              future: _createWisdom(),
              builder: (context, wisdom) {
                switch (wisdom.connectionState) {
                  case ConnectionState.done:
                    _wisdomList.add(wisdom.data);
                    return AdviceCard(wisdom: wisdom.data);
                  default:
                    return LoadingCard();
                }
              });
        });
  }

  @override
  dispose() {
    super.dispose();
    networkSubscription.cancel();
  }

  //Async Data Fetchers to get Data from external APIs ------
  Future<Wisdom> _createWisdom() async {
    try {
      final advice = await _fetchAdvice();
      final img = await _fetchImage(stringToQuery(advice.text));
      return Wisdom(advice, img);
    } catch (err) {
      return Wisdom(
          Advice(text: "Try using the internet once in a while", id: "0000"),
          StockImg(url: ""));
    }
  }

  Future<Advice> _fetchAdvice() async {
    final response = await http.get(_adviceURI);
    return Advice.fromJson(json.decode(response.body));
  }

  Future<StockImg> _fetchImage(String query) async {
    final String url = _imagesURI + query;
    return StockImg(url: url);
  }

  //Helper Functions ------
  String stringToQuery(String input) {
    final List<String> dirtyWords = input.split(nonLetterPattern);
    String query = "";
    dirtyWords.forEach((w) {
      if (w.isNotEmpty && w.length > minQueryWordLenght) {
        query += w + ",";
      }
    });
    return query;
  }

  void _showDialog(String title, String body) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(title),
          content: new Text(body),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
