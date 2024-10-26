import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meno_moni/profile_manager.dart';

import 'home_page.dart';
import 'profile.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  DateTime? _selectedDate;
  List<String> symptoms = ["Headache", "Fever", "Cough", "Fatigue"];
  List<String> selectedSymptoms = [];

  void _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _toggleSymptom(String symptom) {
    setState(() {
      if (selectedSymptoms.contains(symptom)) {
        selectedSymptoms.remove(symptom);
      } else {
        selectedSymptoms.add(symptom);
      }
    });
  }

  Future<void> _createProfileAndNavigate() async{
    if (_nameController.text.isNotEmpty && _selectedDate != null) {
        ProfileManager profileManager = new ProfileManager();
        var profile = await profileManager.CreateProfile(_nameController.text, _selectedDate!, selectedSymptoms);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(profile: profile),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill in all fields")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Profile")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                width: double.infinity, // Set infinite width for birthday field
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _selectedDate == null
                      ? "Select Birthday"
                      : "Birthday: ${DateFormat.yMd().format(_selectedDate!)}",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text("Select Symptoms:"),
            Wrap(
              spacing: 8,
              children: symptoms.map((symptom) {
                final isSelected = selectedSymptoms.contains(symptom);
                return ChoiceChip(
                  label: Text(symptom),
                  selected: isSelected,
                  onSelected: (bool selected) {
                    _toggleSymptom(symptom);
                  },
                );
              }).toList(),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: _createProfileAndNavigate,
              child: Text("Next"),
            ),
          ],
        ),
      ),
    );
  }
}