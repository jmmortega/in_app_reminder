import 'dart:developer';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:in_app_reminder/in_app_reminder.dart';
import 'package:in_app_reminder/utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _lastReminderId;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final hasPermission = await InAppReminder.hasReminderPermission();
    setState(() {
      _hasPermission = hasPermission;
    });
  }

  Future<void> _requestPermission() async {
    final granted = await InAppReminder.requestReminderPermission();
    setState(() {
      _hasPermission = granted;
    });
    log('Permission granted: $granted');
  }

  /// Add a reminder to the device's Reminders app.
  ///
  /// [title] is the title of the reminder.
  /// [notes] is the notes of the reminder.
  /// [dateTime] is the date and time of the reminder.
  /// [frequency] is the frequency of the reminder.
  Future<void> addToReminder() async {
    try {
      final id = await InAppReminder.addReminder(
        title: 'Title for Reminder',
        notes: 'Notes for the reminder',
        frequency: ReminderFrequency.daily,
      );
      if (id != null) {
        setState(() {
          _lastReminderId = id;
        });
        log('Reminder added successfully with ID: $id');
      } else {
        log('Failed to add reminder');
      }
    } catch (e) {
      log('Error adding reminder: $e');
    }
  }

  Future<void> addLocationReminder() async {
    try {
      // Coordinates for Apple Park
      final id = await InAppReminder.addReminderWithLocation(
        title: 'Arrive at Apple Park',
        latitude: 37.3349,
        longitude: -122.0090,
        proximity: ReminderProximity.enter,
        radius: 200.0,
      );
      if (id != null) {
        setState(() {
          _lastReminderId = id;
        });
        log('Location reminder added with ID: $id');
      } else {
        log('Failed to add location reminder');
      }
    } catch (e) {
      log('Error adding location reminder: $e');
    }
  }

  Future<void> removeReminder() async {
    if (_lastReminderId == null) return;
    try {
      final success = await InAppReminder.removeReminder(_lastReminderId!);
      if (success) {
        setState(() {
          _lastReminderId = null;
        });
        log('Reminder removed successfully');
      } else {
        log('Failed to remove reminder');
      }
    } catch (e) {
      log('Error removing reminder: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('In-App Reminder Example')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Has Permission: $_hasPermission'),
              const SizedBox(height: 10),
              if (!_hasPermission)
                ElevatedButton(
                  onPressed: _requestPermission,
                  child: const Text("Request Permission"),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _hasPermission ? addToReminder : null,
                child: const Text("Add iOS Reminder"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _hasPermission ? addLocationReminder : null,
                child: const Text("Add Location Reminder (Apple Park)"),
              ),
              if (_lastReminderId != null) ...[
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: removeReminder,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, foregroundColor: Colors.white),
                  child: const Text("Remove Last Reminder"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
