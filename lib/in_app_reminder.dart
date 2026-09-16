import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:in_app_reminder/utils.dart';

class InAppReminder {
  /// Private constructor to prevent instantiation.
  InAppReminder._();

  /// Singleton instance of the InAppReminder class.
  static final InAppReminder _instance = InAppReminder._();

  /// Singleton instance of the InAppReminder class.
  static InAppReminder get instance => _instance;

  // Method channel for communication with the native iOS code
  static const MethodChannel _channel = MethodChannel('in_app_reminder');

  /// Add a reminder to the device's Reminders app.
  ///
  /// [title] is the title of the reminder.
  /// [notes] is the notes of the reminder.
  /// [dateTime] is the date and time of the reminder.
  /// [frequency] is the frequency of the reminder.
  /// Returns the identifier of the added reminder, or null if it failed.
  static Future<String?> addReminder({
    required String title,
    String? notes,
    DateTime? dateTime,
    ReminderFrequency frequency = ReminderFrequency.none,
  }) async {
    final Map<String, dynamic> args = {
      'title': title,
      if (notes != null) 'notes': notes,
      if (dateTime != null)
        'dateTime': dateTime.toUtc().toIso8601String(),
      if (frequency != ReminderFrequency.none)
        'frequency': frequency.name,
    };
    try {
      final String? identifier = await _channel.invokeMethod<String>('addReminder', args);
      return identifier;
    } catch (e) {
      log('Failed to add reminder: $e');
      return null;
    }
  }

  /// Remove a reminder from the device's Reminders app.
  ///
  /// [identifier] is the identifier of the reminder to remove.
  /// Returns true if the reminder was removed successfully, false otherwise.
  static Future<bool> removeReminder(String identifier) async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('removeReminder', {
        'identifier': identifier,
      });
      return result ?? false;
    } catch (e) {
      log('Failed to remove reminder: $e');
      return false;
    }
  }
}
