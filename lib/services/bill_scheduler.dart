// lib/services/bill_scheduler.dart

// ignore_for_file: avoid_print

import 'package:intl/intl.dart';
import 'package:mywallet/models/bill.dart';
import 'package:mywallet/services/notification_service.dart';

class BillScheduler {
  /// Predefined reminder offsets for bills
  static const List<Duration> reminderOffsets = [
    Duration(days: 7),
    Duration(days: 3),
    Duration(days: 1),
    Duration(hours: 12),
    Duration(hours: 1),
    Duration(minutes: 10),
  ];

  /// Generate a safe 32-bit notification ID (using prefix, billId, and offset)
  static int safeNotificationId(String prefix, int billId, int offsetMinutes) {
    final rawId = billId.hashCode ^ prefix.hashCode ^ offsetMinutes.hashCode;
    return rawId & 0x7FFFFFFF;
  }

  /// Simple safe ID generator for generic cases (debug/instant notifications)
  static int simpleSafeId(int rawId) {
    return rawId & 0x7FFFFFFF;
  }

  /// Cancel all scheduled notifications for a specific bill
  static Future<void> cancelBillNotifications(Bill bill) async {
    for (final offset in reminderOffsets) {
      final id = safeNotificationId(
        "bill",
        bill.id ?? bill.dueDate.hashCode,
        offset.inMinutes,
      );
      await NotificationService.cancelNotification(id);
    }
    print("🗑️ All notifications canceled for bill: ${bill.name}");
  }

  /// Format a date nicely: August 19, 2025
  static String formatDate(DateTime date) {
    return DateFormat('MMMM d, y').format(date);
  }

  /// Show an instant notification when a bill is added
  static Future<void> showBillAddedNotification(Bill bill) async {
    await NotificationService.showNotification(
      id: simpleSafeId(DateTime.now().millisecondsSinceEpoch),
      title: "Bill Added",
      body:
          "The bill '${bill.name}' was added and is due on ${formatDate(bill.dueDate)}",
    );
    print("✅ Instant 'added' notification for ${bill.name}");
  }

  /// Show an instant notification when a bill is updated
  static Future<void> showBillUpdatedNotification(Bill bill) async {
    await NotificationService.showNotification(
      id: simpleSafeId(DateTime.now().millisecondsSinceEpoch),
      title: "Bill Updated",
      body:
          "The bill '${bill.name}' was updated and is due on ${formatDate(bill.dueDate)}",
    );
    print("✅ Instant 'updated' notification for ${bill.name}");
  }

  /// Show an instant notification when a bill is paid
  /// and reschedule for next month
  static Future<void> showBillPaidNotification(Bill bill) async {
    final formattedDate = DateFormat('MMMM d, yyyy').format(bill.dueDate);

    await NotificationService.showNotification(
      id: simpleSafeId(DateTime.now().millisecondsSinceEpoch),
      title: "Bill Paid",
      body:
          "The bill '${bill.name}' was paid and rescheduled to pay on $formattedDate",
    );

    print("✅ Instant 'paid & rescheduled' notification for ${bill.name}");
  }

  /// Schedule multiple reminders for a bill
  static Future<void> scheduleBillNotifications(Bill bill) async {
    final now = DateTime.now();
    final dueDate = bill.dueDate;

    for (final reminder in reminderOffsets) {
      final scheduledDate = dueDate.subtract(reminder);

      if (scheduledDate.isAfter(now)) {
        final id = safeNotificationId(
          "bill",
          bill.id ?? dueDate.hashCode,
          reminder.inMinutes,
        );
        await NotificationService.scheduleNotification(
          id: id,
          title: "Upcoming Bill Due",
          body: "${bill.name} is due on ${formatDate(dueDate)}",
          scheduledDate: scheduledDate,
        );

        print("⏰ Scheduled reminder for ${bill.name} at $scheduledDate");
      } else {
        print(
          "⚠️ Skipped reminder (${reminder.inHours}h before) – already past",
        );
      }
    }
  }

  /// Main entry point: call this from your form submit
  /// [action] specifies if this is an 'add', 'update', or 'pay' event
  static Future<void> handleBillScheduling(
    Bill bill, {
    required String action,
  }) async {
    print("📌 DEBUG: Handling '$action' notifications for bill: ${bill.name}");

    // Cancel old reminders first
    await cancelBillNotifications(bill);

    // Instant notification based on action
    switch (action) {
      case 'add':
        await showBillAddedNotification(bill);
        break;
      case 'update':
        await showBillUpdatedNotification(bill);
        break;
      case 'pay':
        await showBillPaidNotification(bill);
        break;
      default:
        print("⚠️ Unknown action: $action");
    }

    // Only schedule reminders if bill is not paid
    if (bill.status != BillStatus.paid || action == 'pay') {
      await scheduleBillNotifications(bill);
    }

    print("✅ All reminders processed for ${bill.name}");
  }
}
