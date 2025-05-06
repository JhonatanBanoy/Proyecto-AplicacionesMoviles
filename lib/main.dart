import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'main_dashboard.dart';
import 'theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD App',
      debugShowCheckedModeBanner: false,
      theme: appTheme, 
      home: const HomeDashboard(),
    );
  }
}

enum RecordType {
  room,
  equipment,
}

class Record {
  String id;
  String title;
  String teacher;
  RecordType type;
  String? room;
  TimeOfDay startTime;
  TimeOfDay endTime;
  bool isDelivered;
  DateTime createdAt;

  Record({
    required this.id,
    required this.title,
    required this.teacher,
    required this.type,
    this.room,
    required this.startTime,
    required this.endTime,
    this.isDelivered = false,
    required this.createdAt,
  });

  // Check if this record's time overlaps with another record
  bool hasTimeConflictWith(Record other) {
    if (room != other.room) return false; // Different rooms, no conflict
    if (type != RecordType.room || other.type != RecordType.room) return false; // Not a room booking

    // Convert TimeOfDay to minutes for easier comparison
    int thisStart = startTime.hour * 60 + startTime.minute;
    int thisEnd = endTime.hour * 60 + endTime.minute;
    int otherStart = other.startTime.hour * 60 + other.startTime.minute;
    int otherEnd = other.endTime.hour * 60 + other.endTime.minute;

    // Handle case where end time is on the next day (after midnight)
    if (thisEnd <= thisStart) {
      thisEnd += 24 * 60; // Add 24 hours in minutes
    }
    if (otherEnd <= otherStart) {
      otherEnd += 24 * 60; // Add 24 hours in minutes
    }

    // Check for any overlap:
    // 1. This booking starts during other booking: otherStart <= thisStart < otherEnd
    // 2. This booking ends during other booking: otherStart < thisEnd <= otherEnd
    // 3. This booking completely contains other booking: thisStart <= otherStart && otherEnd <= thisEnd
    return (otherStart <= thisStart && thisStart < otherEnd) || 
           (otherStart < thisEnd && thisEnd <= otherEnd) || 
           (thisStart <= otherStart && otherEnd <= thisEnd);
  }
} 