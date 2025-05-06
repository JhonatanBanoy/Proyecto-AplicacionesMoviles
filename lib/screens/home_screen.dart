import 'package:flutter/material.dart';
import '../models/inventory_item.dart';
import '../screens/inventory_dashboard.dart';
import 'record_manager_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<InventoryItem> _inventoryItems = [];
  
  @override
  void initState() {
    super.initState();
    // No cargar datos de muestra
  }
  
  void _onItemAdded(InventoryItem item) {
    setState(() {
      _inventoryItems.add(item);
    });
  }
  
  void _onItemUpdated(InventoryItem updatedItem) {
    setState(() {
      final index = _inventoryItems.indexWhere((item) => item.id == updatedItem.id);
      if (index != -1) {
        _inventoryItems[index] = updatedItem;
      }
    });
  }
  
  void _onItemDeleted(String id) {
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
          // Records Manager
          RecordManagerScreen(inventoryItems: _inventoryItems),
          
          // Inventory Dashboard
          InventoryDashboard(
            inventoryItems: _inventoryItems,
            onItemAdded: _onItemAdded,
            onItemUpdated: _onItemUpdated,
            onItemDeleted: _onItemDeleted,
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
          BottomNavigationBar.item(
            icon: Icon(Icons.calendar_today),
            label: 'Records',
          ),
          BottomNavigationBar.item(
            icon: Icon(Icons.inventory_2),
            label: 'Inventory',
          ),
        ],
      ),
    );
  }
} 