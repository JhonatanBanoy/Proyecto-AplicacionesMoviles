import 'package:flutter/material.dart';

enum ItemType {
  room,
  equipment,
}

enum ItemStatus {
  available,
  inUse,
  maintenance,
}

class Classroom {
  final int id;
  final int floor;
  final String hasEquipment;
  final String roomNumber;
  final String roomType;
  final String tower;

  Classroom({
    required this.id,
    required this.floor,
    required this.hasEquipment,
    required this.roomNumber,
    required this.roomType,
    required this.tower,
  });

  factory Classroom.fromJson(Map<String, dynamic> json) {
    return Classroom(
      id: json['id'],
      floor: json['floor'],
      hasEquipment: json['has_equipment'],
      roomNumber: json['room_number'],
      roomType: json['room_type'],
      tower: json['tower'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'floor': floor,
      'has_equipment': hasEquipment,
      'room_number': roomNumber,
      'room_type': roomType,
      'tower': tower,
    };
  }
}

class InventoryItem {
  String id;
  String name;
  ItemType type;
  String? location; // For equipment: where it's stored
  String? description;
  ItemStatus status;
  DateTime lastUpdated;

  InventoryItem({
    required this.id,
    required this.name,
    required this.type,
    this.location,
    this.description,
    this.status = ItemStatus.available,
    required this.lastUpdated,
  });

  // Create a copy of this item with some fields modified
  InventoryItem copyWith({
    String? name,
    ItemType? type,
    String? location,
    String? description,
    ItemStatus? status,
    DateTime? lastUpdated,
  }) {
    return InventoryItem(
      id: this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      location: location ?? this.location,
      description: description ?? this.description,
      status: status ?? this.status,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
} 