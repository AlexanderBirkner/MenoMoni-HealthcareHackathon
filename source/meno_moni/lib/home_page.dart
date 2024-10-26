import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:meno_moni/llm_communication_client.dart';
import 'package:meno_moni/profile_manager.dart';
import 'package:meno_moni/prompt_creator.dart';

import 'profile.dart';
import 'profile_page.dart';

void main() {
  runApp(MenoMoniApp());
}

class MenoMoniApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meno Moni',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: ProfilePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  Profile profile;

  HomePage({required this.profile});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _messageController = TextEditingController();
  List<String> _chatMessages = [];
  bool _isLoading = false;

  int _calculateAge(DateTime birthday) {
    DateTime today = DateTime.now();
    int age = today.year - birthday.year;
    if (today.month < birthday.month ||
        (today.month == birthday.month && today.day < birthday.day)) {
      age--;
    }
    return age;
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text;

    if (message.isEmpty) return;

    PromptCreator promptCreator = new PromptCreator();
    String personalizedPrompt =
        promptCreator.createPersonalizedPromt(message, widget.profile);

    setState(() {
      _chatMessages.add("You: $message");
      _chatMessages.add(
          "Prompt with personalized profile information: $personalizedPrompt");
      _isLoading = true;
    });

    _messageController.clear();

    final response = await _sendToLlm(personalizedPrompt);
    setState(() {
      _chatMessages.add("---------------------------------------- \n");
      _chatMessages.add("Moni: $response");
      _isLoading = false;
      ProfileManager profileManager = new ProfileManager();
      widget.profile = profileManager.AddChatMessagesToExistingProfile(
          widget.profile, _chatMessages);
    });
  }

  Future<String> _sendToLlm(String message) async {
    final client = LlmCommunicationClient(message: message);

    return await client.sendMessage();
  }

  @override
  Widget build(BuildContext context) {
    int age = _calculateAge(widget.profile.birthday);
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: _isLoading ? null : _sendMessage,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.send, color: Colors.deepPurple,),),
      appBar: AppBar(title: const Text("Welcome")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Profile Information",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.person, color: Colors.blueAccent),
                        const SizedBox(width: 8),
                        Text("Name: ${widget.profile.name}"),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.cake, color: Colors.blueAccent),
                        const SizedBox(width: 8),
                        Text("Age: $age years"),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.local_hospital,
                            color: Colors.blueAccent),
                        const SizedBox(width: 8),
                        Text("Symptoms: ${widget.profile.symptoms.join(", ")}"),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.data_usage_sharp,
                            color: Colors.blueAccent),
                        const SizedBox(width: 8),
                        Text(
                            "Stored Health Data: ${widget.profile.healtEntries.join(", ")}"),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month,
                            color: Colors.blueAccent),
                        const SizedBox(width: 8),
                        Text(
                            "Calendar Entries (Last 30 Days): ${widget.profile.eventTitles.length}"),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.history,
                            color: Colors.blueAccent),
                        const SizedBox(width: 8),
                        Text(
                            "Past communications with moni: ${((widget.profile.promptHistory.length)/3).ceil()}"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: "Talk to Moni",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _chatMessages.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(_chatMessages[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
