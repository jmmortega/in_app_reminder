import Flutter
import UIKit
import EventKit


public class InAppReminderPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "in_app_reminder", binaryMessenger: registrar.messenger())
    let instance = InAppReminderPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let eventStore = EKEventStore()
    switch call.method {
    case "addReminder":
      addReminder(call: call, eventStore: eventStore, result: result)
    case "removeReminder":
      removeReminder(call: call, eventStore: eventStore, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func addReminder(call: FlutterMethodCall, eventStore: EKEventStore, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let title = args["title"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing or invalid title", details: nil))
      return
    }
    let notes = args["notes"] as? String
    let dateTimeString = args["dateTime"] as? String
    let frequencyString = args["frequency"] as? String

    eventStore.requestAccess(to: .reminder) { _, error in
      if let error = error {
        result(FlutterError(code: "PERMISSION_ERROR", message: error.localizedDescription, details: nil))
        return
      }

      let reminder = EKReminder(eventStore: eventStore)
      reminder.title = title
      reminder.notes = notes
      reminder.calendar = eventStore.defaultCalendarForNewReminders()

      if let dateTimeString = dateTimeString {
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions.insert(.withFractionalSeconds)

        if let isoDate = isoFormatter.date(from: dateTimeString) {
          let calendar = Calendar.current
          let components = calendar.dateComponents(in: TimeZone.current, from: isoDate)

          var dueDate = DateComponents()
          dueDate.calendar = calendar
          dueDate.timeZone = TimeZone.current
          dueDate.year = components.year
          dueDate.month = components.month
          dueDate.day = components.day
          dueDate.hour = components.hour
          dueDate.minute = components.minute
          dueDate.second = components.second

          reminder.dueDateComponents = dueDate
          reminder.addAlarm(EKAlarm(absoluteDate: isoDate))

          if let frequencyString = frequencyString {
            let frequency: EKRecurrenceFrequency?
            switch frequencyString {
            case "daily": frequency = .daily
            case "weekly": frequency = .weekly
            case "monthly": frequency = .monthly
            case "yearly": frequency = .yearly
            default: frequency = nil
            }

            if let frequency = frequency {
              let rule = EKRecurrenceRule(recurrenceWith: frequency, interval: 1, end: nil)
              reminder.addRecurrenceRule(rule)
            }
          }
        } else {
          result(FlutterError(code: "INVALID_DATE_FORMAT", message: "Invalid dateTime format", details: nil))
          return
        }
      }

      do {
        try eventStore.save(reminder, commit: true)
        result(reminder.calendarItemIdentifier)
      } catch {
        result(FlutterError(code: "SAVE_ERROR", message: error.localizedDescription, details: nil))
      }
    }
  }

  private func removeReminder(call: FlutterMethodCall, eventStore: EKEventStore, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let identifier = args["identifier"] as? String else {
      result(FlutterError(code: "INVALID_ARGUMENT", message: "Missing or invalid identifier", details: nil))
      return
    }

    eventStore.requestAccess(to: .reminder) { _, error in
      if let error = error {
        result(FlutterError(code: "PERMISSION_ERROR", message: error.localizedDescription, details: nil))
        return
      }

      if let reminder = eventStore.calendarItem(withIdentifier: identifier) as? EKReminder {
        do {
          try eventStore.remove(reminder, commit: true)
          result(true)
        } catch {
          result(FlutterError(code: "REMOVE_ERROR", message: error.localizedDescription, details: nil))
        }
      } else {
        result(FlutterError(code: "NOT_FOUND", message: "Reminder not found", details: nil))
      }
    }
  }
}