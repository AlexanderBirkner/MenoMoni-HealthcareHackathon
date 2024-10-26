import 'package:flutter/material.dart';
import 'package:device_calendar/device_calendar.dart';
import 'package:permission_handler/permission_handler.dart';

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:carp_serializable/carp_serializable.dart';

import 'package:permission_handler/permission_handler.dart';

class HealthDataAccessor {
  Future<void> requestActivityRecognitionPermission() async {
    var status = await Permission.activityRecognition.request();
    if (status.isGranted) {
      print("Activity recognition permission granted");
    } else {
      print("Activity recognition permission denied");
    }
  }

  Future<int?> readDailySteps() async {
    await requestActivityRecognitionPermission();

    // configure the health plugin before use.
    Health().configure();

    if (Platform.isAndroid) {
      // request permissions to write steps and blood glucose
      var types = [HealthDataType.STEPS];
      var permissions = [HealthDataAccess.READ_WRITE];
      var resultTest =
          await Health().requestAuthorization(types, permissions: permissions);
      var check = await Health().hasPermissions([HealthDataType.STEPS],
          permissions: [HealthDataAccess.READ]);
      //stepsAuth = check;

      if (check == null || !check) {
        return null;
      }
    }
    // define the types to get
    var types = [HealthDataType.STEPS];

    // requesting access to the data types before reading them
    bool requested = await Health().requestAuthorization(types);

    var now = DateTime.now();

    // fetch health data from the last 24 hours
    // List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
    //     types: types,
    //     startTime: DateTime.now().subtract(const Duration(days: 1)),
    //     endTime: DateTime.now());

    var midnight = DateTime(now.year, now.month, now.day);

    // bool success = await Health().writeHealthData(
    //     value: 5000,
    //     unit: HealthDataUnit.COUNT,
    //     type: HealthDataType.STEPS,
    //     startTime: midnight,
    //     endTime: now);

    int? steps = await Health().getTotalStepsInInterval(midnight, now);
    return steps;
  }

  // Future<void> _writeSteps() async {
  //   // configure the health plugin before use.
  //   await requestActivityRecognitionPermission();
  //   Health().configure();

  //   if (Platform.isAndroid) {
  //     // request permissions to write steps and blood glucose
  //     var types = [HealthDataType.STEPS];
  //     var permissions = [HealthDataAccess.READ_WRITE];
  //     var resultTest =
  //         await Health().requestAuthorization(types, permissions: permissions);

  //     var check = await Health().hasPermissions([HealthDataType.STEPS],
  //         permissions: [HealthDataAccess.READ]);
  //     //stepsAuth = check;

  //     if (check == null || !check) {
  //       return;
  //     }
  //   }
  //   // define the types to get
  //   var types = [HealthDataType.STEPS];

  //   // requesting access to the data types before reading them
  //   bool requested = await Health().requestAuthorization(types);

  //   var now = DateTime.now();

  //   // fetch health data from the last 24 hours
  //   List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
  //       types: types,
  //       startTime: DateTime.now().subtract(const Duration(days: 1)),
  //       endTime: DateTime.now());

  //   // write steps and blood glucose
  //   bool success = await Health().writeHealthData(
  //       value: 10,
  //       unit: HealthDataUnit.COUNT,
  //       type: HealthDataType.STEPS,
  //       startTime: now.subtract(Duration(minutes: 5)),
  //       endTime: now);

  //   // get the number of steps for today
  //   var midnight = DateTime(now.year, now.month, now.day);
  //   int? steps = await Health().getTotalStepsInInterval(midnight, now);
  // }
}
