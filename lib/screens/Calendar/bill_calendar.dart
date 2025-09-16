import 'package:flutter/material.dart';
import 'package:mywallet/providers/profile_provider.dart';
import 'package:mywallet/utils/Design/chart_legend.dart';
import 'package:provider/provider.dart';
import 'package:mywallet/providers/bill_provider.dart';
import 'package:mywallet/models/bill.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:mywallet/widgets/Bills/bill_card.dart'; // ✅ import your BillCard

class BillCalendarScreen extends StatefulWidget {
  const BillCalendarScreen({super.key});

  @override
  State<BillCalendarScreen> createState() => _BillCalendarScreenState();
}

class _BillCalendarScreenState extends State<BillCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final billProvider = context.watch<BillProvider>();
    final bills = billProvider.bills;
    final profile = context.watch<ProfileProvider>().profile;
    final baseColor =
        profile?.colorPreference != null
            ? Color(int.parse(profile!.colorPreference!))
            : Colors.blue;

    final firstDay = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final lastDay = DateTime(DateTime.now().year, 12, 31);

    /// group bills by dueDate
    Map<DateTime, List<Bill>> events = {};
    for (var bill in bills) {
      final date = DateTime(
        bill.dueDate.year,
        bill.dueDate.month,
        bill.dueDate.day,
      );
      events.putIfAbsent(date, () => []).add(bill);
    }

    List<Bill> getEventsForDay(DateTime day) {
      final key = DateTime(day.year, day.month, day.day);
      return events[key] ?? [];
    }

    final selectedBills =
        _selectedDay != null ? getEventsForDay(_selectedDay!) : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Bills Calendar"),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        scrolledUnderElevation: 0,
        elevation: 0,
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Legend
            ChartLegend(
              labels: const ["Pending", "Paid"],
              colors: const [Colors.red, Colors.green],
            ),
            const SizedBox(height: 12),

            /// Calendar
            TableCalendar<Bill>(
              firstDay: firstDay,
              lastDay: lastDay,
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                if (!selectedDay.isBefore(firstDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                }
              },
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: const {CalendarFormat.month: 'Month'},
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  size: 24,
                  color: Theme.of(context).iconTheme.color,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  size: 24,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                weekendStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              calendarStyle: CalendarStyle(
                isTodayHighlighted: true,
                todayDecoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                selectedDecoration: BoxDecoration(
                  color: baseColor,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                disabledTextStyle: TextStyle(
                  color: Theme.of(context).disabledColor,
                ),
                weekendTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                defaultDecoration: const BoxDecoration(shape: BoxShape.circle),
                outsideDaysVisible: false,
              ),
              enabledDayPredicate: (day) {
                return !day.isBefore(firstDay);
              },
              eventLoader: getEventsForDay,
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final billsForDay = getEventsForDay(day);
                  if (billsForDay.isNotEmpty) {
                    final isPaid = billsForDay.every(
                      (b) => b.status == BillStatus.paid,
                    );
                    return Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isPaid ? Colors.green : Colors.red,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }
                  return null;
                },
                markerBuilder: (context, day, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      bottom: 10,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    );
                  }
                  return null;
                },
                selectedBuilder: (context, day, focusedDay) {
                  return Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: baseColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            /// Bills of selected day
            if (selectedBills.isNotEmpty) ...[
              Text(
                "Bills on ${DateFormat('MMMM dd, yyyy').format(_selectedDay!)}",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children:
                    selectedBills.map((bill) {
                      final isPaid = bill.status == BillStatus.paid;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: BillCard(
                          bill: bill,
                          isPaidThisMonth: isPaid,
                          formatter: DateFormat("MMMM dd, yyyy"),
                          compact: true,
                        ),
                      );
                    }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
