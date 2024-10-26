import 'package:meno_moni/profile.dart';

class PromptCreator {
  String createPersonalizedPromt(String message, Profile profile){

    String personalizedPrompt = "Hi, my name is " + profile.name + "\n";
    personalizedPrompt += "First some information about me:" + "\n";
    personalizedPrompt += "i am " + _calculateAge(profile.birthday).toString() + " year old." + "\n";
    personalizedPrompt += "This is my health data: " + profile.healtEntries.join(", ") + "\n";
    personalizedPrompt += "I have realized the following symtphoms lately: " + profile.symptoms.join(",") + "\n";
    //personalizedPrompt += "This is how my calendar looked like in the last 30 months: " + profile.eventTitles.join(",");
    personalizedPrompt += "Can you answer me the following question or message: \n";
    personalizedPrompt += message;

    return personalizedPrompt;
  }

    int _calculateAge(DateTime birthday) {
    DateTime today = DateTime.now();
    int age = today.year - birthday.year;
    if (today.month < birthday.month ||
        (today.month == birthday.month && today.day < birthday.day)) {
      age--;
    }
    return age;
  }
}