import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'screens/inventory_dashboard.dart';
import 'screens/record_manager_screen.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeDashboard(),
    );
  }
}

// Enum definitions
enum RecordType {
  room,
  equipment,
}

enum ItemStatus {
  available,
  inUse,
  maintenance,
}

// Model classes
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

    // Check for any overlap
    return (otherStart <= thisStart && thisStart < otherEnd) || 
           (otherStart < thisEnd && thisEnd <= otherEnd) || 
           (thisStart <= otherStart && otherEnd <= thisEnd);
  }
}

class InventoryItem {
  String id;
  String name;
  RecordType type;
  String? location; // For equipment: where it's stored, for rooms: room number
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
    RecordType? type,
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

// Main Dashboard
class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  int _selectedIndex = 0;
  List<Record> _records = [];
  List<InventoryItem> _inventoryItems = [];

  @override
  void initState() {
    super.initState();
    // No cargar datos de muestra
  }
  
  void _onInventoryItemAdded(InventoryItem item) {
    setState(() {
      _inventoryItems.add(item);
    });
  }
  
  void _onInventoryItemUpdated(InventoryItem updatedItem) {
    setState(() {
      final index = _inventoryItems.indexWhere((item) => item.id == updatedItem.id);
      if (index != -1) {
        _inventoryItems[index] = updatedItem;
      }
    });
  }
  
  void _onInventoryItemDeleted(String id) {
    setState(() {
      _inventoryItems.removeWhere((item) => item.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Records Manager Screen
          RecordManagerScreen(
            records: _records,
            inventoryItems: _inventoryItems,
            onRecordAdded: (record) {
              setState(() {
                _records.add(record);
                
                // Update inventory item status
                if (record.type == RecordType.room && record.room != null) {
                  _updateInventoryItemStatus(RecordType.room, record.room!, ItemStatus.inUse);
                }
              });
            },
            onRecordUpdated: (record) {
              setState(() {
                final index = _records.indexWhere((r) => r.id == record.id);
                if (index != -1) {
                  _records[index] = record;
                }
              });
            },
            onRecordDeleted: (id) {
              setState(() {
                final record = _records.firstWhere((r) => r.id == id);
                _records.removeWhere((r) => r.id == id);
                
                // Update inventory item status if needed
                if (record.type == RecordType.room && record.room != null) {
                  _updateInventoryItemStatus(RecordType.room, record.room!, ItemStatus.available);
                }
              });
            },
            onRecordStatusChanged: (id, isDelivered) {
              setState(() {
                final index = _records.indexWhere((r) => r.id == id);
                if (index != -1) {
                  _records[index].isDelivered = isDelivered;
                  
                  // Update inventory item status
                  final record = _records[index];
                  if (record.type == RecordType.room && record.room != null) {
                    _updateInventoryItemStatus(
                      RecordType.room, 
                      record.room!, 
                      isDelivered ? ItemStatus.available : ItemStatus.inUse
                    );
                  }
                }
              });
            },
          ),
          
          // Inventory Dashboard
          InventoryDashboard(
            inventoryItems: _inventoryItems,
            onItemAdded: _onInventoryItemAdded,
            onItemUpdated: _onInventoryItemUpdated,
            onItemDeleted: _onInventoryItemDeleted,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Records',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Inventory',
          ),
        ],
      ),
    );
  }
  
  void _updateInventoryItemStatus(RecordType type, String identifier, ItemStatus status) {
    final index = _inventoryItems.indexWhere(
      (item) => item.type == type && item.location == identifier
    );
    
    if (index != -1) {
      setState(() {
        _inventoryItems[index] = _inventoryItems[index].copyWith(
          status: status,
          lastUpdated: DateTime.now(),
        );
      });
    }
  }
} 