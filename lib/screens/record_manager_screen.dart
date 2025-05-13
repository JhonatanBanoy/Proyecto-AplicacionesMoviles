import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../main_dashboard.dart';

class RecordManagerScreen extends StatefulWidget {
  final List<Record> records;
  final List<InventoryItem> inventoryItems;
  final Function(Record) onRecordAdded;
  final Function(Record) onRecordUpdated;
  final Function(String) onRecordDeleted;
  final Function(String, bool) onRecordStatusChanged;

  const RecordManagerScreen({
    super.key,
    required this.records,
    required this.inventoryItems,
    required this.onRecordAdded,
    required this.onRecordUpdated,
    required this.onRecordDeleted,
    required this.onRecordStatusChanged,
  });

  @override
  State<RecordManagerScreen> createState() => _RecordManagerScreenState();
}

class _RecordManagerScreenState extends State<RecordManagerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  String _selectedTeacher = 'Brayan';
  RecordType _selectedType = RecordType.room;
  String? _selectedTower;
  String? _selectedRoom;
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();
  Record? _editingRecord;
  String? _timeConflictError;

  final List<String> teachers = [
    'Brayan',
    'Leyder',
    'Sharry',
    'Shirley',
    'Pedro',
    'Mario',
    'Adriana',
    'Dahiana',
    'Coordinador Wilmer',
    'Camila',
  ];

  @override
  void initState() {
    super.initState();
    // Depurar el inventario al iniciar la pantalla
    _debugInventory();
  }

  @override
  void didUpdateWidget(RecordManagerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Verificar si el inventario ha cambiado
    if (widget.inventoryItems.length != oldWidget.inventoryItems.length) {
      print('El inventario ha cambiado. Actualizando RecordManagerScreen...');
      _debugInventory();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  // Método para depurar el inventario disponible
  void _debugInventory() {
    print('=== DEPURACIÓN DE INVENTARIO ===');
    print('Total de elementos en inventario: ${widget.inventoryItems.length}');
    
    final rooms = widget.inventoryItems.where((item) => item.type == RecordType.room).toList();
    print('Total de salones: ${rooms.length}');
    
    for (var room in rooms) {
      print('Salón: ${room.name}, Ubicación: ${room.location}, ID: ${room.id}');
    }
    
    print('=== FIN DEPURACIÓN ===');
  }

  List<String> getRoomsForTower(String tower) {
    print('Obteniendo salones para torre: $tower');
    
    // Filtrar salones disponibles del inventario para la torre seleccionada
    final List<String> availableRooms = [];
    
    // Depurar el inventario actual
    print('Inventario actual: ${widget.inventoryItems.length} elementos');
    for (var item in widget.inventoryItems) {
      print('Item: ${item.name}, Tipo: ${item.type}, Ubicación: ${item.location}, ID: ${item.id}');
    }
    
    // Filtrar solo los salones que comienzan con la torre seleccionada
    for (var item in widget.inventoryItems) {
      if (item.type == RecordType.room && 
          item.location != null) {
        // Verificar si el salón pertenece a la torre seleccionada
        if (item.location!.startsWith(tower)) {
          print('✓ Agregando salón: ${item.location} para torre $tower (ID: ${item.id})');
          availableRooms.add(item.location!);
        } else {
          print('✗ Salón no coincide con torre $tower: ${item.location}');
        }
      }
    }
    
    print('Salones disponibles para torre $tower: $availableRooms');
    
    // Si no hay salones disponibles en el inventario, usar valores por defecto
    if (availableRooms.isEmpty) {
      print('No se encontraron salones para la torre $tower, usando valores por defecto');
      return ['$tower-101', '$tower-102', '$tower-103'];
    }
    
    return availableRooms;
  }

  // Check if there's a time conflict with existing records
  bool _hasTimeConflict(Record newRecord) {
    for (var record in widget.records) {
      // Skip checking against the record being edited
      if (_editingRecord != null && record.id == _editingRecord!.id) {
        continue;
      }
      
      if (newRecord.hasTimeConflictWith(record)) {
        return true;
      }
    }
    return false;
  }

  void _validateTimeRange() {
    // If end time is earlier than start time, assume it's for the next day
    int startMinutes = _startTime.hour * 60 + _startTime.minute;
    int endMinutes = _endTime.hour * 60 + _endTime.minute;
    
    if (endMinutes <= startMinutes) {
      // Keep track that end time is on the next day
      print('End time is on the next day');
    }
  }

  void _addRecord() {
    _validateTimeRange();
    
    final newRecord = Record(
      id: DateTime.now().toString(),
      title: _titleController.text,
      teacher: _selectedTeacher,
      type: _selectedType,
      room: _selectedType == RecordType.room ? _selectedRoom : null,
      startTime: _startTime,
      endTime: _endTime,
      createdAt: DateTime.now(),
    );

    // Check for time conflicts
    if (_hasTimeConflict(newRecord)) {
      setState(() {
        _timeConflictError = 'Conflicto de horario: Este salón ya está reservado durante este periodo de tiempo.';
      });
      return;
    }

    widget.onRecordAdded(newRecord);
    _resetForm();
    Navigator.pop(context);
  }

  void _updateRecord() {
    _validateTimeRange();
    
    final updatedRecord = Record(
      id: _editingRecord!.id,
      title: _titleController.text,
      teacher: _selectedTeacher,
      type: _selectedType,
      room: _selectedType == RecordType.room ? _selectedRoom : null,
      startTime: _startTime,
      endTime: _endTime,
      isDelivered: _editingRecord!.isDelivered,
      createdAt: _editingRecord!.createdAt,
    );

    // Check for time conflicts
    if (_hasTimeConflict(updatedRecord)) {
      setState(() {
        _timeConflictError = 'Conflicto de horario: Este salón ya está reservado durante este periodo de tiempo.';
      });
      return;
    }

    widget.onRecordUpdated(updatedRecord);
    _resetForm();
    Navigator.pop(context);
  }

  void _deleteRecord(String id) {
    widget.onRecordDeleted(id);
  }

  void _toggleDeliveryStatus(String id) {
    final index = widget.records.indexWhere((record) => record.id == id);
    if (index != -1) {
      final newStatus = !widget.records[index].isDelivered;
      widget.onRecordStatusChanged(id, newStatus);
    }
  }

  void _resetForm() {
    _titleController.clear();
    _selectedTeacher = 'Brayan';
    _selectedType = RecordType.room;
    _selectedTower = null;
    _selectedRoom = null;
    _startTime = TimeOfDay.now();
    _endTime = TimeOfDay.now();
    _editingRecord = null;
    _timeConflictError = null;
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
          
          // If start time is after end time, adjust end time
          int startMinutes = _startTime.hour * 60 + _startTime.minute;
          int endMinutes = _endTime.hour * 60 + _endTime.minute;
          
          if (startMinutes >= endMinutes) {
            // Set end time to start time + 1 hour
            int newEndHour = (_startTime.hour + 1) % 24;
            _endTime = TimeOfDay(hour: newEndHour, minute: _startTime.minute);
          }
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _showRecordDialog([Record? record]) {
    _editingRecord = record;
    _timeConflictError = null;
    
    // Actualizar y depurar el inventario actual al mostrar el diálogo
    _debugInventory();
    
    // Verificar si hay elementos de inventario disponibles
    final hasRooms = widget.inventoryItems.any((item) => item.type == RecordType.room);
    print('¿Hay salones disponibles? ${hasRooms ? "Sí" : "No"}');
    
    if (!hasRooms && record == null) {
      // Mostrar mensaje si no hay habitaciones disponibles
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('No hay inventario disponible'),
          content: const Text('Debe agregar salones o equipos al inventario antes de crear registros.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
      return;
    }
    
    if (record != null) {
      _titleController.text = record.title;
      _selectedTeacher = record.teacher;
      _selectedType = record.type;
      if (record.room != null) {
        _selectedTower = record.room!.split('-')[0];
        _selectedRoom = record.room;
      }
      _startTime = record.startTime;
      _endTime = record.endTime;
    } else {
      _resetForm();
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            record == null ? 'Añadir Nuevo Registro' : 'Editar Registro',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_timeConflictError != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Conflicto de horario: Este salón ya está reservado durante este periodo de tiempo.',
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  DropdownButtonFormField<RecordType>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      labelText: 'Tipo',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.category),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: RecordType.room,
                        child: Text('Salón'),
                      ),
                      DropdownMenuItem(
                        value: RecordType.equipment,
                        child: Text('Equipamiento'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedType = value;
                          if (value == RecordType.equipment) {
                            _selectedTower = null;
                            _selectedRoom = null;
                          }
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Título',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.title),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese un título';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedTeacher,
                    decoration: InputDecoration(
                      labelText: 'Profesor',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    items: teachers.map((teacher) {
                      return DropdownMenuItem(
                        value: teacher,
                        child: Text(teacher),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedTeacher = value;
                        });
                      }
                    },
                  ),
                  if (_selectedType == RecordType.room) ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedTower,
                      decoration: InputDecoration(
                        labelText: 'Torre',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.business),
                      ),
                      items: ['C', 'B'].map((tower) {
                        return DropdownMenuItem(
                          value: tower,
                          child: Text('Torre $tower'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedTower = value;
                            _selectedRoom = null;
                          });
                        }
                      },
                      validator: (value) {
                        if (_selectedType == RecordType.room && (value == null || value.isEmpty)) {
                          return 'Por favor seleccione una torre';
                        }
                        return null;
                      },
                    ),
                    if (_selectedTower != null) ...[
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedRoom,
                        decoration: InputDecoration(
                          labelText: 'Salón',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.room),
                        ),
                        items: getRoomsForTower(_selectedTower!).map((room) {
                          // Add a status indicator next to each room
                          final roomItem = widget.inventoryItems.firstWhere(
                            (item) => item.type == RecordType.room && item.location == room,
                            orElse: () => InventoryItem(
                              id: 'temp',
                              name: room,
                              type: RecordType.room,
                              location: room,
                              status: ItemStatus.available,
                              lastUpdated: DateTime.now(),
                            ),
                          );
                          
                          return DropdownMenuItem(
                            value: room,
                            child: Row(
                              children: [
                                Text(room),
                                const SizedBox(width: 8),
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: roomItem.status == ItemStatus.available 
                                        ? Colors.green 
                                        : roomItem.status == ItemStatus.inUse 
                                            ? Colors.orange 
                                            : Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedRoom = value;
                              _timeConflictError = null; // Reset error when room changes
                            });
                          }
                        },
                        validator: (value) {
                          if (_selectedType == RecordType.room && (value == null || value.isEmpty)) {
                            return 'Por favor seleccione un salón';
                          }
                          return null;
                        },
                      ),
                    ],
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: const Text('Hora de Inicio'),
                          subtitle: Text(_startTime.format(context)),
                          trailing: const Icon(Icons.access_time),
                          onTap: () => _selectTime(context, true).then((_) {
                            setState(() {
                              _timeConflictError = null; // Reset error when time changes
                            });
                          }),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          title: const Text('Hora de Fin'),
                          subtitle: Text(_endTime.format(context)),
                          trailing: const Icon(Icons.access_time),
                          onTap: () => _selectTime(context, false).then((_) {
                            setState(() {
                              _timeConflictError = null; // Reset error when time changes
                            });
                          }),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Si la hora de fin es anterior a la hora de inicio, se considerará como el día siguiente.',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final tempRecord = Record(
                    id: _editingRecord?.id ?? DateTime.now().toString(),
                    title: _titleController.text,
                    teacher: _selectedTeacher,
                    type: _selectedType,
                    room: _selectedType == RecordType.room ? _selectedRoom : null,
                    startTime: _startTime,
                    endTime: _endTime,
                    isDelivered: _editingRecord?.isDelivered ?? false,
                    createdAt: _editingRecord?.createdAt ?? DateTime.now(),
                  );
                  
                  // Check for time conflict within the dialog
                  if (_hasTimeConflict(tempRecord)) {
                    setState(() {
                      _timeConflictError = 'Conflicto de horario: Este salón ya está reservado durante este periodo de tiempo.';
                    });
                    return;
                  }
                  
                  if (record == null) {
                    _addRecord();
                  } else {
                    _updateRecord();
                  }
                }
              },
              child: Text(record == null ? 'Añadir Registro' : 'Actualizar Registro'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gestor de Registros',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: widget.records.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.list_alt,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay registros',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Primero agrega salones y equipos en la sección de inventario',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton.icon(
                    onPressed: () {
                      // Cambiar a la pestaña de inventario
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HomeDashboard(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.inventory_2),
                    label: const Text('Ir al Inventario'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.records.length,
              itemBuilder: (context, index) {
                final record = widget.records[index];
                
                // Find inventory status for this room or equipment 
                ItemStatus itemStatus = ItemStatus.available;
                if (record.type == RecordType.room && record.room != null) {
                  final roomItem = widget.inventoryItems.firstWhere(
                    (item) => item.type == RecordType.room && item.location == record.room,
                    orElse: () => InventoryItem(
                      id: 'temp',
                      name: record.room!,
                      type: RecordType.room,
                      location: record.room,
                      status: ItemStatus.available,
                      lastUpdated: DateTime.now(),
                    ),
                  );
                  itemStatus = roomItem.status;
                }
                
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Row(
                      children: [
                        Text(
                          record.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: record.isDelivered ? Colors.grey : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: record.type == RecordType.room
                                ? Colors.blue.withOpacity(0.1)
                                : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            record.type == RecordType.room ? 'Salón' : 'Equipamiento',
                            style: TextStyle(
                              color: record.type == RecordType.room
                                  ? Colors.blue
                                  : Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.person,
                                size: 16,
                                color: Colors.blue,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                record.teacher,
                                style: TextStyle(
                                  color: record.isDelivered ? Colors.grey : Colors.blue,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (record.type == RecordType.room && record.room != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.room,
                                size: 16,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                record.room!,
                                style: TextStyle(
                                  color: record.isDelivered ? Colors.grey : Colors.orange,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: itemStatus == ItemStatus.available 
                                      ? Colors.green 
                                      : itemStatus == ItemStatus.inUse 
                                          ? Colors.orange 
                                          : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${record.startTime.format(context)} - ${record.endTime.format(context)}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Creado: ${DateFormat('dd/MM/yyyy').format(record.createdAt)}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    leading: Checkbox(
                      value: record.isDelivered,
                      onChanged: (_) => _toggleDeliveryStatus(record.id),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showRecordDialog(record),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteRecord(record.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Depurar el inventario antes de mostrar el diálogo
          print('Presionado botón "Añadir Registro" - Verificando inventario actual');
          _debugInventory();
          _showRecordDialog();
        },
        icon: const Icon(Icons.add),
        label: const Text('Añadir Registro'),
      ),
    );
  }
} 