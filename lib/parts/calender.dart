import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:collection';

class createcallender {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selected;

  create(_eventsList) {
    int getHashCode(DateTime key) {
      return key.day * 1000000 + key.month * 10000 + key.year;
    }

    final _events = LinkedHashMap<DateTime, List>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(_eventsList);

    List getEvent(DateTime day) {
      return _events[day] ?? [];
    }

    return Column(children: [
      TableCalendar(
        firstDay: DateTime.utc(2020, 4, 1),
        lastDay: DateTime.utc(2025, 12, 31),
        eventLoader: getEvent,
        selectedDayPredicate: (day) {
          return isSameDay(_selected, day);
        },
        onDaySelected: (selectedDay, focusedDay) {
          if (!isSameDay(_selected, selectedDay)) {
            _selected = selectedDay;
            _focusedDay = focusedDay;
          }
        },
        focusedDay: _focusedDay,
      ),
      ListView(
        shrinkWrap: true,
        children: getEvent(_selected!)
            .map((event) => ListTile(
                  title: Text(event.toString()),
                ))
            .toList(),
      ),
    ]);
  }
}
