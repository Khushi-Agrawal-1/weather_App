import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(WeatherApp());
}

class WeatherApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

// since we will change the temperature variable when user eraches therefore we have used stateful widget
class _WeatherAppState extends State<WeatherApp> {
  int temperature = 10;
  String location = 'London';
  int woeid =44418;
  String weather ='clear';

  //we need to have to have a URL where we want data from...
  String searchApiUrl ='https://www.metaweather.com/api/location/search/?query=';
  String locationApiUrl ='https://www.metaweather.com/api/location/';

  void fetchSearch(String input) async {
    //FOR FETCHING DATA FROM THE INTERNET WE NEED TO USE HTTP DART PACKAGE
    // because http.get is an asynchronous operation we need to use await
    var searchResult = await http.get(Uri.parse(searchApiUrl + input));
    //EXAMPLE -  https://www.metaweather.com/api/location/search/?query=san

    //we will use the json decode function to selct only the 0th element of this list 
    var result = json.decode(searchResult.body)[0];

    setState(() {
      
      location=result["title"];
      woeid = result["woeid"];
    });
  }

  void fetchLocation() async {
    var locationResult = await http.get(Uri.parse(locationApiUrl + woeid.toString()));
    var result = json.decode(locationResult.body);
    var consolidatedWeather = result["consolidated_weather"];
    var data = consolidatedWeather[0];

    setState(() {
      temperature= data["the_temp"].round();
      
      // we are getting this from the API "weather_state_name":"Heavy Rain"
      // but we cant have space in between images we have imported and we have to have to name same for images & the one provided by api
      weather =data['weather_state_name'].replaceAll(' ','').toLowerCase();

    });
  }

  void onTextFieldSubitted(String input){
    fetchSearch(input);
    fetchLocation();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/$weather.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Column(
                children: [
                  Center(
                    child: Text(
                      temperature.toString() + ' °C',
                      style: TextStyle(color: Colors.white, fontSize: 60.0),
                    ),
                  ),
                  Center(
                    child: Text(
                      location,
                      style: TextStyle(color: Colors.white, fontSize: 40.0),
                    ),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  Container(
                    width: 300,
                    child: TextField(
                      onSubmitted: (String input){
                        onTextFieldSubitted(input);
                      },
                        style: TextStyle(color: Colors.white, fontSize: 25),
                        decoration: InputDecoration(
                          hintText: 'Search location...',
                          hintStyle:
                              TextStyle(color: Colors.white, fontSize: 18.0),
                          prefixIcon: Icon(Icons.search, color: Colors.white),
                        )),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
