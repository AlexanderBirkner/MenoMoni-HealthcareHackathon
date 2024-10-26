import 'package:device_calendar/device_calendar.dart';
import 'package:meno_moni/calendar_accessor.dart';
import 'package:meno_moni/health_data_accessor.dart';
import 'package:meno_moni/profile.dart';

class ProfileManager {

  Future<Profile> CreateProfile(String name, DateTime birthday, List<String> symptoms) async{
      final profile = Profile(
        name: name,
        birthday: birthday,
        symptoms: symptoms,
      );

      CalendarAccessor calendarAccessor = new CalendarAccessor();
      List<Event>? events = await calendarAccessor.fetchEventsFromPastDaysFromFirstCalendar(30);
      if(events != null){
        List<String> eventTitles = [];
        for (var event in events) {
          eventTitles.add("${event.title}am${event.start?.toIso8601String()}");
        }
        profile.eventTitles = eventTitles;
      }

      HealthDataAccessor healthDataAccessor = new HealthDataAccessor();
      int? dailySteps = await healthDataAccessor.readDailySteps();
      if(dailySteps != null){
        profile.healtEntries.add("Daily Steps: " + dailySteps.toString());
      }

      return profile;
  }

  Profile AddChatMessagesToExistingProfile(Profile existingProfile, List<String> chatMessages){
    existingProfile.promptHistory.addAll(chatMessages);
    return existingProfile;
  }
}