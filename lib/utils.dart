/// Enum for the frequency of the reminder.
///
/// [none] is the default value.
/// [daily] is the frequency of the reminder.
/// [weekly] is the frequency of the reminder.
/// [monthly] is the frequency of the reminder.
/// [yearly] is the frequency of the reminder.
enum ReminderFrequency { none, daily, weekly, monthly, yearly }

/// Enum for the proximity of the location-based reminder.
///
/// [enter] triggers when entering the location.
/// [leave] triggers when leaving the location.
enum ReminderProximity { enter, leave }

/// Extension for the ReminderFrequency enum.
///
/// [name] is the name of the reminder frequency.
extension ReminderFrequencyExt on ReminderFrequency {
  String get name {
    switch (this) {
      case ReminderFrequency.daily:
        return 'daily';
      case ReminderFrequency.weekly:
        return 'weekly';
      case ReminderFrequency.monthly:
        return 'monthly';
      case ReminderFrequency.yearly:
        return 'yearly';
      default:
        return 'none';
    }
  }
}
