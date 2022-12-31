
import 'dart:math';

import 'package:calendarapp/controllers/calendar.dart';
import 'package:calendarapp/utils/images.dart';
import 'package:calendarapp/views/settings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.4,
              height: MediaQuery.of(context).size.height,
              decoration: new BoxDecoration(
            image: new DecorationImage(image: new AssetImage(AppImages.background), fit: BoxFit.cover, opacity: 0.9, colorFilter: ColorFilter.mode(Colors.grey, BlendMode.saturation)),
          ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(38.0),
                  child: Text('Cria o teu calendario', style: GoogleFonts.bebasNeue(fontSize: 100, color: Colors.white)),
                ),

                Padding(
                  padding: const EdgeInsets.all(38.0),
                  child: ElevatedButton(onPressed: (){
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Settings()),
                      );
                  }, child: Text('começar a configurar', style: GoogleFonts.bebasNeue(fontSize: 50),),
                  )
                ),
              ],
            ),
            ),

            Container(
              width: MediaQuery.of(context).size.width * 0.6,
              height: MediaQuery.of(context).size.height,
              color: Colors.black,
              child: Transform.rotate(
                angle: pi/2,
                child: FittedBox(child: Text('${DateTime.now().year + 1}', style: GoogleFonts.bebasNeue(fontSize: MediaQuery.of(context).size.height * 0.6, color: Colors.white)))
              ),
            )
            //Container(
            //  color: Colors.black,
            //  width: MediaQuery.of(context).size.width * 0.1,
            //  height: MediaQuery.of(context).size.height,
            //)
          ]
        ),
      ),
    );
  }
}