// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:fpit_demo_api/api_services/background_service.dart';
import 'package:fpit_demo_api/api_services/fpit_service.dart';
import 'package:fpit_demo_api/model/ApiModel.dart';
import 'package:fpit_demo_api/model/User.dart';
import 'package:fpit_demo_api/pages/list_employee_page.dart';
import 'package:fpit_demo_api/utils/LocalStorage.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() async {
  HttpOverrides.global = FpitService();
  WidgetsFlutterBinding.ensureInitialized();
  await MyBackgroundService().initializeService();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FPIT Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 250, 58, 0)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'FPIT Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<User> users = [];
  String contentInfile = "";
  String status = "";

  late final Timer timer;

  Future<Database> getConnection() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'fpit.db');
    Database database = await openDatabase(path, version: 1);

    return database;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<void> creatDB() async {
    Database database = await openDatabase(
      join(await getDatabasesPath(), 'fpit.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE user(id INTEGER PRIMARY KEY AUTOINCREMENT, userCd INTEGER, userCode TEXT," +
              " userName TEXT, groupCd INTEGER, groupCode TEXT, groupName TEXT, notificationGroup INTEGER," +
              " notifyNumber INTEGER, groupTableName TEXT, lastMessTime TEXT)",
        );
      },
      version: 1,
    );
    await database.close();
  }

  Future<void> insertUser(User user, Database db) async {
    await db.transaction((txn) async {
      await txn.rawInsert(
          'INSERT INTO user(userCd, userCode, userName, groupCd, groupCode, groupName, notificationGroup, notifyNumber, groupTableName, lastMessTime)' +
              ' VALUES(${user.userCd}, "${user.userCode}", "${user.userName}", ${user.groupCd}, "${user.userCode}", "${user.groupName}", ' +
              '${user.notificationGroup! ? 1 : 0}, ${user.notifyNumber}, "${user.groupTableName}", "${user.lastMessTime}")');
    });
  }

  Future<List<User>> getUsers(Database db) async {
    List<Map<String, dynamic>> userMaps = await db.query('user');

    // List<User> list = [];

    return List.generate(userMaps.length, (i) {
      return User(
        id: userMaps[i]['id'],
        userCd: userMaps[i]['userCd'],
        userCode: userMaps[i]['userCode'],
        userName: userMaps[i]['userName'],
        groupCd: userMaps[i]['groupCd'],
        groupCode: userMaps[i]['groupCode'],
        groupName: userMaps[i]['groupName'],
        notificationGroup: userMaps[i]['notificationGroup'] == 1 ? true : false,
        notifyNumber: userMaps[i]['notifyNumber'],
        groupTableName: userMaps[i]['groupTableName'],
        lastMessTime: userMaps[i]['lastMessTime'],
      );
    });
    // return list;
  }

  Future<void> fetch_api() async {
    FpitService fpitService = FpitService();

    var rsp = await fpitService.postDemo("MES_fetchListGroup");
    List<dynamic> list = jsonDecode(apiModelFromJson(rsp.body).data!);
    setState(() {
      list.forEach((element) {
        users.add(User.fromJson(element));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(status),
            // ElevatedButton(
            //     onPressed: () async {
            //       await databaseFactory.deleteDatabase(
            //           join(await getDatabasesPath(), 'fpit.db'));
            //       await creatDB();
            //       await fetch_api();
            //       Database db = await getConnection();
            //       users.forEach((element) async {
            //         await insertUser(element, db);
            //         // await db.close();
            //       });

            //       // await db.close();
            //     },
            //     child: const Text("Set data vào sqlite")),
            // ElevatedButton(
            //     onPressed: () async {
            //       Database db = await getConnection();
            //       List<User> u = await getUsers(db);
            //       await db.close();

            //       Navigator.push(
            //         context,
            //         MaterialPageRoute(
            //           builder: (context) => ListEmployeePage(employees: u),
            //         ),
            //       );
            //     },
            //     child: const Text("Data từ api")),
            
            ElevatedButton(
              onPressed: () async {
                final service = FlutterBackgroundService();
                MyBackgroundService myBackgroundService = MyBackgroundService();
                var isRunning = await service.isRunning();

                if (isRunning) {
                  setState(() {
                    status = "Service: off";
                  });
                  service.invoke("stopService");
                } else {
                  setState(() {
                    status = "Service: on";
                  });
                  myBackgroundService.initializeService();
                  // service.invoke("setAsBackground");
                }
              },
              child: const Text("On/Off Service"),
            ),
            
          ],
        ),
      ),
    );
  }
}
