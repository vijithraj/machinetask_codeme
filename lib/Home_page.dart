import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'constraints.dart' as k;

class Home_page extends StatefulWidget {
  const Home_page({Key? key}) : super(key: key);

  @override
  State<Home_page> createState() => _Home_pageState();
}

class _Home_pageState extends State<Home_page> {
  bool isDark = false;
  bool isLoaded = false;
  num? temp;
  num? pressure;
  num? humidity;
  num? cover;
  String cityname = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentLocation();
  }

  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Weather App",
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.all(0),
              decoration: BoxDecoration(
                  color: Colors.cyan,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(0),
                    bottomLeft: Radius.circular(70),
                    bottomRight: Radius.circular(70),
                  )),
              height: 430,
              width: screenWidth,
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SearchAnchor(builder:
                      (BuildContext context, SearchController controller) {
                    return SearchBar(
                      controller: controller,
                      padding: const MaterialStatePropertyAll<EdgeInsets>(
                          EdgeInsets.symmetric(horizontal: 16.0)),
                      onTap: () {
                        controller.openView();
                      },
                      onChanged: (_) {
                        controller.openView();
                      },
                      leading: const Icon(Icons.search),
                      trailing: <Widget>[
                        Tooltip(
                          message: 'Change brightness mode',
                          child: IconButton(
                            isSelected: isDark,
                            onPressed: () {
                              setState(() {
                                isDark = !isDark;
                              });
                            },
                            icon: const Icon(Icons.wb_sunny_outlined),
                            selectedIcon:
                                const Icon(Icons.brightness_2_outlined),
                          ),
                        )
                      ],
                    );
                  }, suggestionsBuilder:
                      (BuildContext context, SearchController controller) {
                    return List<ListTile>.generate(5, (int index) {
                      final String item = 'item $index';
                      return ListTile(
                        title: Text(item),
                        onTap: () {
                          setState(() {
                            controller.closeView(item);
                          });
                        },
                      );
                    });
                  }),
                ),
                SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_city_outlined,
                        size: 60,
                        color: Colors.white,
                      ),
                      Text(
                        cityname,
                        style: const TextStyle(
                          fontSize: 45,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.cloud,
                  size: 100,
                  color: Colors.white,
                ),
                Text(
                  '${temp?.toInt()}',
                  style: const TextStyle(
                    fontSize: 60,
                    color: Colors.black,
                  ),
                ),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(
                    Icons.wb_cloudy_outlined,
                    size: 50,
                    color: Colors.black,
                  ),
                  SizedBox(
                    width: 70,
                  ),
                  Text(
                    "Weather",
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                  SizedBox(
                    width: 50,
                  ),
                  Text(
                    '${temp?.toInt()}',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(
                    Icons.hot_tub,
                    size: 50,
                    color: Colors.black,
                  ),
                  SizedBox(
                    width: 70,
                  ),
                  Text(
                    "Humidity",
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                  SizedBox(
                    width: 50,
                  ),
                  Text(
                    '${humidity?.toInt()}%',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(
                    Icons.wind_power_outlined,
                    size: 50,
                    color: Colors.black,
                  ),
                  SizedBox(
                    width: 70,
                  ),
                  Text(
                    "Pressure",
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                  SizedBox(
                    width: 50,
                  ),
                  Text(
                    '${pressure?.toInt()}hpa',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  getCurrentLocation() async {
    var position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
      forceAndroidLocationManager: true,
    );
    if (position != null) {
      print('lat:${position.latitude},long:${position.longitude}');
      getCurrentCityWeather(position);
    } else {
      print('Data Unavailable');
    }
  }

  getCurrentCityWeather(Position pos) async {
    var url =
        '${k.domain}lat=${pos.latitude}&lon=${pos.longitude}&appid=${k.apiKey}';
    var uri = Uri.parse(url);

    var response = await http.get(uri);
    print(response.body);
    if (response.statusCode == 200) {
      var data = response.body;
      var decodeData = jsonDecode(data);
      print(data);
      updateUI(decodeData);
      setState(() {
        isLoaded = true;
      });
    } else {
      print(response.statusCode);
    }
  }

  updateUI(var decodeData) {
    setState(() {
      if (decodeData == null) {
        temp = 0;
        pressure = 0;
        humidity = 0;
        cover = 0;
        cityname = "Not available";
      } else {
        temp = decodeData['main']['temp'] - 273;
        pressure = decodeData['main']['pressure'];
        humidity = decodeData['clouds']['all'];
        cityname = decodeData['name'];
      }
    });
  }
}
