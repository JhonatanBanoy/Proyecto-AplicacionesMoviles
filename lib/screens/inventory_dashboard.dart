import 'package:flutter/material.dart';
import '../models/inventory_item.dart';
import '../services/resource_service.dart';
import '../theme.dart';

class InventoryDashboard extends StatefulWidget {
  const InventoryDashboard({super.key});

  @override
  State<InventoryDashboard> createState() => _InventoryDashboardState();
}

class _InventoryDashboardState extends State<InventoryDashboard> {
  final ClassroomService _service = ClassroomService();
  List<Classroom> _classrooms = [];
  List<Classroom> _filteredClassrooms = [];

  final _formKey = GlobalKey<FormState>();
  final _floorController = TextEditingController();
  final _hasEquipmentController = TextEditingController();
  final _roomNumberController = TextEditingController();
  final _roomTypeController = TextEditingController();
  final _towerController = TextEditingController();
  final _searchController = TextEditingController();
  Classroom? _editingClassroom;

  Color get gold => const Color(0xFFFFD700);
  Color get blue => AppColors.azulOscuro;
  Color get lightGrey => Colors.grey.shade100;
  Color get darkGrey => Colors.grey.shade700;

  @override
  void initState() {
    super.initState();
    _loadClassrooms();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _floorController.dispose();
    _hasEquipmentController.dispose();
    _roomNumberController.dispose();
    _roomTypeController.dispose();
    _towerController.dispose();
    super.dispose();
  }

  Future<void> _loadClassrooms() async {
    final classrooms = await _service.getClassrooms();
    setState(() {
      _classrooms = classrooms;
      _filteredClassrooms = classrooms;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredClassrooms = _classrooms.where((c) =>
        c.roomNumber.toLowerCase().contains(query) ||
        c.roomType.toLowerCase().contains(query) ||
        c.tower.toLowerCase().contains(query) ||
        c.hasEquipment.toLowerCase().contains(query)
      ).toList();
    });
  }

  void _resetForm() {
    _floorController.clear();
    _hasEquipmentController.clear();
    _roomNumberController.clear();
    _roomTypeController.clear();
    _towerController.clear();
    _editingClassroom = null;
  }

  void _addOrUpdateClassroom() async {
    if (_formKey.currentState!.validate()) {
      final classroom = Classroom(
        id: _editingClassroom?.id ?? 0,
        floor: int.tryParse(_floorController.text) ?? 0,
        hasEquipment: _hasEquipmentController.text,
        roomNumber: _roomNumberController.text,
        roomType: _roomTypeController.text,
        tower: _towerController.text,
      );
      if (_editingClassroom == null) {
        await _service.addClassroom(classroom);
      } else {
        await _service.updateClassroom(classroom);
      }
      _resetForm();
      await _loadClassrooms();
      Navigator.pop(context);
    }
  }

  void _showClassroomDialog([Classroom? classroom]) {
    _editingClassroom = classroom;
    if (classroom != null) {
      _floorController.text = classroom.floor.toString();
      _hasEquipmentController.text = classroom.hasEquipment;
      _roomNumberController.text = classroom.roomNumber;
      _roomTypeController.text = classroom.roomType;
      _towerController.text = classroom.tower;
    } else {
      _resetForm();
    }
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  classroom == null ? 'Agregar Aula' : 'Editar Aula',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: blue,
                  ),
                ),
                const SizedBox(height: 18),
                _buildTextField(_roomNumberController, 'Número de Aula', Icons.meeting_room),
                const SizedBox(height: 12),
                _buildTextField(_towerController, 'Torre', Icons.location_city),
                const SizedBox(height: 12),
                _buildTextField(_floorController, 'Piso', Icons.layers, isNumber: true),
                const SizedBox(height: 12),
                _buildTextField(_roomTypeController, 'Tipo de Aula', Icons.category),
                const SizedBox(height: 12),
                _buildTextField(_hasEquipmentController, '¿Tiene equipamiento?', Icons.check_circle),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gold,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: _addOrUpdateClassroom,
                      child: Text(classroom == null ? 'Agregar' : 'Actualizar'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: gold),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: lightGrey,
      ),
      validator: (value) => value == null || value.isEmpty ? 'Campo requerido' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.school, color: Colors.white, size: 30),
                      const SizedBox(width: 10),
                      const Text(
                        'Educal',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Navegación (Administrador)',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.meeting_room),
              title: const Text('Lista de Salones'),
              selected: true,
              selectedTileColor: blue.withOpacity(0.1),
              selectedColor: blue,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Gestión de Usuarios'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Historial de Reservas'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: const Text('Gestión de Aulas'),
        backgroundColor: blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar aula... (número, tipo, torre, equipamiento)',
                prefixIcon: Icon(Icons.search, color: gold),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: _filteredClassrooms.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.meeting_room_outlined, size: 80, color: gold.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text('No hay aulas registradas', style: TextStyle(color: darkGrey, fontSize: 18)),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _filteredClassrooms.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final classroom = _filteredClassrooms[index];
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Card(
                          color: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                            leading: CircleAvatar(
                              radius: 28,
                              backgroundColor: gold.withOpacity(0.15),
                              child: Icon(Icons.meeting_room, color: blue, size: 32),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  'Aula ${classroom.roomNumber}',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: blue),
                                ),
                                const SizedBox(width: 10),
                                _buildBadge(classroom.hasEquipment),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.location_city, size: 18, color: gold),
                                      const SizedBox(width: 4),
                                      Text('Torre: ${classroom.tower}', style: TextStyle(color: darkGrey)),
                                      const SizedBox(width: 16),
                                      Icon(Icons.layers, size: 18, color: gold),
                                      const SizedBox(width: 4),
                                      Text('Piso: ${classroom.floor}', style: TextStyle(color: darkGrey)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.category, size: 18, color: gold),
                                      const SizedBox(width: 4),
                                      Text('Tipo: ${classroom.roomType}', style: TextStyle(color: darkGrey)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: blue),
                                  onPressed: () => _showClassroomDialog(classroom),
                                  tooltip: 'Editar',
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red.shade400),
                                  onPressed: () async {
                                    await _service.deleteClassroom(classroom.id);
                                    await _loadClassrooms();
                                  },
                                  tooltip: 'Eliminar',
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showClassroomDialog(),
        icon: Icon(Icons.add, color: Colors.black),
        backgroundColor: gold,
        label: const Text('Agregar Aula', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBadge(String hasEquipment) {
    final isYes = hasEquipment.toLowerCase().contains('s');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isYes ? Colors.green.withOpacity(0.2) : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isYes ? Colors.green : Colors.grey.shade400),
      ),
      child: Row(
        children: [
          Icon(isYes ? Icons.check_circle : Icons.cancel, size: 16, color: isYes ? Colors.green : Colors.grey),
          const SizedBox(width: 4),
          Text(
            isYes ? 'Con equipamiento' : 'Sin equipamiento',
            style: TextStyle(fontSize: 12, color: isYes ? Colors.green : Colors.grey),
          ),
        ],
      ),
    );
  }
} 