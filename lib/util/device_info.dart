import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class DeviceUtil {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  static late String deviceData;

  static Future<String> get deviceId async {
    await getPlatformData();
    return deviceData;
  }

  static Future<void> getPlatformData() async {
    try {
      if (kIsWeb) {
        var data = await deviceInfoPlugin.webBrowserInfo;
        deviceData = data.appCodeName!;
      } else {
        if (Platform.isAndroid) {
          var data = await deviceInfoPlugin.androidInfo;
          deviceData = data.serialNumber;
        } else if (Platform.isIOS) {
          var data = await deviceInfoPlugin.iosInfo;
          deviceData = data.identifierForVendor!;
        } else if (Platform.isLinux) {
          var data = await deviceInfoPlugin.linuxInfo;
          deviceData = data.machineId!;
        } else if (Platform.isMacOS) {
          var data = await deviceInfoPlugin.macOsInfo;
          deviceData = data.computerName;
        } else if (Platform.isWindows) {
          var data = await deviceInfoPlugin.windowsInfo;
          deviceData = data.deviceId;
        }
      }
    } on PlatformException {
      log('Error: Failed to get platform version.');
    }
  }
}
