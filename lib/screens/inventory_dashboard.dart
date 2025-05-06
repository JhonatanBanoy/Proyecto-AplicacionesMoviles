import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main_dashboard.dart';

class InventoryDashboard extends StatefulWidget {
  final List<InventoryItem> inventoryItems;
  final Function(InventoryItem) onItemAdded;
  final Function(InventoryItem) onItemUpdated;
  final Function(String) onItemDeleted;

  const InventoryDashboard({
    super.key,
    required this.inventoryItems,
    required this.onItemAdded,
    required this.onItemUpdated,
    required this.onItemDeleted,
  });

  @override
  State<InventoryDashboard> createState() => _InventoryDashboardState();
}

class _InventoryDashboardState extends State<InventoryDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  RecordType _selectedType = RecordType.equipment;
  ItemStatus _selectedStatus = ItemStatus.available;
  InventoryItem? _editingItem;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _nameController.clear();
    _locationController.clear();
    _descriptionController.clear();
    _selectedType = RecordType.equipment;
    _selectedStatus = ItemStatus.available;
    _editingItem = null;
  }

  void _addItem() {
    final newItem = InventoryItem(
      id: DateTime.now().toString(),
      name: _nameController.text,
      type: _selectedType,
      location: _locationController.text.isEmpty ? null : _locationController.text,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      status: _selectedStatus,
      lastUpdated: DateTime.now(),
    );

    widget.onItemAdded(newItem);
    _resetForm();
    Navigator.pop(context);
  }

  void _updateItem() {
    final updatedItem = _editingItem!.copyWith(
      name: _nameController.text,
      type: _selectedType,
      location: _locationController.text.isEmpty ? null : _locationController.text,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      status: _selectedStatus,
      lastUpdated: DateTime.now(),
    );

    widget.onItemUpdated(updatedItem);
    _resetForm();
    Navigator.pop(context);
  }

  void _showItemDialog([InventoryItem? item]) {
    _editingItem = item;
    
    if (item != null) {
      _nameController.text = item.name;
      _selectedType = item.type;
      _locationController.text = item.location ?? '';
      _descriptionController.text = item.description ?? '';
      _selectedStatus = item.status;
    } else {
      _resetForm();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          item == null ? 'Add Inventory Item' : 'Edit Inventory Item',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<RecordType>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.category),
                  ),
                  items: RecordType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.label),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: _selectedType == RecordType.room ? 'Room Number' : 'Storage Location',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: _selectedType == RecordType.room ? const Icon(Icons.room) : const Icon(Icons.storage),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.description),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ItemStatus>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.sync),
                  ),
                  items: ItemStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                if (item == null) {
                  _addItem();
                } else {
                  _updateItem();
                }
              }
            },
            child: Text(item == null ? 'Add Item' : 'Update Item'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final equipmentItems = widget.inventoryItems.where((item) => item.type == RecordType.equipment).toList();
    final roomItems = widget.inventoryItems.where((item) => item.type == RecordType.room).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Inventory Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white,
          tabs: [
            Tab(
              text: 'Equipment',
              icon: Icon(Icons.videocam, color: Color(0xFFFFD700)),
            ),
            Tab(
              text: 'Rooms',
              icon: Icon(Icons.meeting_room, color: Color(0xFFFFD700)),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Equipment Tab
          _buildInventoryList(equipmentItems),
          
          // Rooms Tab
          _buildInventoryList(roomItems),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showItemDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }

  Widget _buildInventoryList(List<InventoryItem> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              items.isEmpty && _tabController.index == 0 ? Icons.videocam_off : Icons.meeting_room_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No hay ${_tabController.index == 0 ? 'equipos' : 'salones'} registrados',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Añade ${_tabController.index == 0 ? 'equipos' : 'salones'} usando el botón "+"',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Row(
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(item.status),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.location != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        item.type == RecordType.room ? Icons.room : Icons.storage,
                        size: 16,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.location!,
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
                if (item.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    item.description!,
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.update,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Updated: ${DateFormat('MMM dd, yyyy HH:mm').format(item.lastUpdated)}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            leading: Icon(
              item.type == RecordType.equipment ? Icons.videocam : Icons.meeting_room,
              color: Colors.blue,
              size: 36,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _showItemDialog(item),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => widget.onItemDeleted(item.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(ItemStatus status) {
    Color backgroundColor;
    Color textColor;
    
    switch (status) {
      case ItemStatus.available:
        backgroundColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        break;
      case ItemStatus.inUse:
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        break;
      case ItemStatus.maintenance:
        backgroundColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toString().split('.').last,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
} 