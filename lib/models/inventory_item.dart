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