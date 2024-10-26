class Profile {
  String name;
  DateTime birthday;
  List<String> symptoms;
  List<String> eventTitles = [];
  List<String> healtEntries = [];
  List<String> promptHistory = [];

  Profile({
    required this.name,
    required this.birthday,
    required this.symptoms,
  });
}