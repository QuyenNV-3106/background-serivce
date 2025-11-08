// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:fpit_demo_api/utils/LocalStorage.dart';

class MyBackgroundService {
  final MyLocalStorage storage = MyLocalStorage();
  
  // Future<void> writeLog(String content) async{
  //   await storage.writeFile(content);
  // }
  Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      iosConfiguration: IosConfiguration(),
      androidConfiguration: AndroidConfiguration(
        onStart: MyBackgroundService.onStart,
        autoStart: true,
        isForegroundMode: true,
      ),
    );
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    // service.on("setAsForeground").listen((event) {
    //   service.setAsForegroundService();
    // });

    service.on('setAsBackground').listen((event) async {
      print("Start background service...");
      service.setAsBackgroundService();
      print("Background service is started...");
    });

    service.on('stopService').listen((event) async {
      print("Stop service...");
      await service.stopSelf();
      print("Service is stoped...");
    });
  }
  int count = 0;
 
  Timer.periodic(const Duration(seconds: 3), (timer) async {
    if (service is AndroidServiceInstance) {
      // if (await service.isForegroundService()) {
        print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');
        // print("isForegroundService: ${count++}");
      // }

      // writeLog
      MyLocalStorage.writeFile('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');
    }
  });

  // print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

  String? device;
  final deviceInfo = DeviceInfoPlugin();
  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    device = androidInfo.model;
  }

  service.invoke(
    'update',
    {
      "current_date": DateTime.now().toIso8601String(),
      "device": device,
    },
  );
}

}
