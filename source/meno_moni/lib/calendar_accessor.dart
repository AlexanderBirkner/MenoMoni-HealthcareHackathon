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

class CalendarAccessor {
  DeviceCalendarPlugin _deviceCalendarPlugin = DeviceCalendarPlugin();

  Future<List<Event>?> fetchEventsFromPastDaysFromFirstCalendar(
      int days) async {
    List<Calendar>? calendars = await _fetchCalendars();
    if (calendars != null && calendars.isNotEmpty) {
      if (calendars.first.id != null) {
        String? calendarId = calendars.first.id;
        if (calendarId != null) {
          return await _fetchEvents(calendarId, days);
        }
      }
    }
    return [];
  }

  Future<List<Calendar>?> _fetchCalendars() async {
    // Request permissions
    if (await Permission.calendar.request().isGranted) {
      // Retrieve calendars
      var result = await _deviceCalendarPlugin.retrieveCalendars();

      return result?.data ?? [];
    }
  }

  Future<List<Event>?> _fetchEvents(String calendarId, int pastDays) async {
    var startDate = DateTime.now().subtract(Duration(days: pastDays));
    var endDate = DateTime.now();
    var result = await _deviceCalendarPlugin.retrieveEvents(
      calendarId,
      RetrieveEventsParams(startDate: startDate, endDate: endDate),
    );

    return result?.data ?? [];
  }

  Future<void> _createEvent(String calendarId) async {
    // Define a new event
    final event = Event(
      calendarId,
      title: 'TESTEVENT!!!!!',
      description: 'This is a test event',
      location: 'Offline',
      start: TZDateTime.now(getLocation('America/Detroit'))
          .add(Duration(hours: 1)), // Start time 1 hour from now
      end: TZDateTime.now(getLocation('America/Detroit'))
          .add(Duration(hours: 2)), // End time 2 hours from now
    );

    // Add the event to the calendar
    var result = await _deviceCalendarPlugin.createOrUpdateEvent(event);
  }
}
