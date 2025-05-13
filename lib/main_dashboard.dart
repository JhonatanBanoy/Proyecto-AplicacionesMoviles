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
    // Cargar datos de muestra para pruebas
    _loadSampleData();
  }
  
  // Método para refrescar el estado - asegura que la UI se actualice cuando navega entre secciones
  void _refreshState() {
    setState(() {
      // Forzar la reconstrucción de los widgets
      print('Actualizando estado de la aplicación');
      print('Inventario actual: ${_inventoryItems.length} elementos');
      print('Registros actuales: ${_records.length} elementos');
    });
  }
  
  void _loadSampleData() {
    // Agregar algunos salones de muestra
    _inventoryItems.addAll([
      // Salones de la torre C
      InventoryItem(
        id: '1',
        name: 'Salón C-101',
        type: RecordType.room,
        location: 'C-101',
        description: 'Salón de clases en torre C',
        status: ItemStatus.available,
        lastUpdated: DateTime.now(),
      ),
      InventoryItem(
        id: '2',
        name: 'Salón C-102',
        type: RecordType.room,
        location: 'C-102',
        description: 'Salón de clases en torre C',
        status: ItemStatus.available,
        lastUpdated: DateTime.now(),
      ),
      // Salones de la torre B
      InventoryItem(
        id: '3',
        name: 'Salón B-201',
        type: RecordType.room,
        location: 'B-201',
        description: 'Salón de clases en torre B',
        status: ItemStatus.available,
        lastUpdated: DateTime.now(),
      ),
      InventoryItem(
        id: '4',
        name: 'Salón B-202',
        type: RecordType.room,
        location: 'B-202',
        description: 'Salón de clases en torre B',
        status: ItemStatus.available,
        lastUpdated: DateTime.now(),
      ),
      // Equipamiento
      InventoryItem(
        id: '5',
        name: 'Proyector HDMI',
        type: RecordType.equipment,
        location: 'Bodega Central',
        description: 'Proyector con entrada HDMI',
        status: ItemStatus.available,
        lastUpdated: DateTime.now(),
      ),
      InventoryItem(
        id: '6',
        name: 'Laptop Dell',
        type: RecordType.equipment,
        location: 'Bodega Central',
        description: 'Laptop Dell para préstamo',
        status: ItemStatus.available,
        lastUpdated: DateTime.now(),
      ),
    ]);
    
    print('Datos de muestra cargados: ${_inventoryItems.length} elementos en el inventario');
  }
  
  void _onInventoryItemAdded(InventoryItem item) {
    setState(() {
      _inventoryItems.add(item);
      print('Nuevo elemento añadido al inventario: ${item.name} (ID: ${item.id})');
      print('Total elementos en inventario: ${_inventoryItems.length}');
      
      // Refresh para asegurar que la UI se actualice
      _refreshState();
    });
  }
  
  void _onInventoryItemUpdated(InventoryItem updatedItem) {
    setState(() {
      final index = _inventoryItems.indexWhere((item) => item.id == updatedItem.id);
      if (index != -1) {
        _inventoryItems[index] = updatedItem;
        print('Elemento de inventario actualizado: ${updatedItem.name} (ID: ${updatedItem.id})');
      }
      
      // Refresh para asegurar que la UI se actualice
      _refreshState();
    });
  }
  
  void _onInventoryItemDeleted(String id) {
    setState(() {
      final item = _inventoryItems.firstWhere((item) => item.id == id, orElse: () => _inventoryItems.first);
      _inventoryItems.removeWhere((item) => item.id == id);
      print('Elemento de inventario eliminado: ${item.name} (ID: $id)');
      print('Total elementos en inventario restantes: ${_inventoryItems.length}');
      
      // Refresh para asegurar que la UI se actualice
      _refreshState();
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
            print('Cambiando a pestaña: ${index == 0 ? "Registros" : "Inventario"}');
            
            // Al cambiar entre pantallas, asegurarnos de que los datos estén actualizados
            _refreshState();
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Registros',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Inventario',
          ),
        ],
      ),
    );
  }
  
  void _updateInventoryItemStatus(RecordType type, String identifier, ItemStatus status) {
    print('Intentando actualizar estado de: $type, $identifier a $status');
    print('Inventario actual: ${_inventoryItems.length} elementos');
    
    // Depuración: imprimir todos los elementos de inventario
    for (var item in _inventoryItems) {
      print('Item: ${item.name}, Tipo: ${item.type}, Ubicación: ${item.location}, Estado actual: ${item.status}');
    }
    
    final index = _inventoryItems.indexWhere(
      (item) => item.type == type && item.location == identifier
    );
    
    if (index != -1) {
      setState(() {
        _inventoryItems[index] = _inventoryItems[index].copyWith(
          status: status,
          lastUpdated: DateTime.now(),
        );
        print('Estado actualizado para ${_inventoryItems[index].name} a ${_inventoryItems[index].status}');
      });
    } else {
      print('No se encontró el item $identifier en el inventario para actualizar su estado');
    }
  }
} 