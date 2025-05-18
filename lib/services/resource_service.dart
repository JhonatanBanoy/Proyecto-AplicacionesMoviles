import '../models/inventory_item.dart';

class ClassroomService {
  final List<Classroom> _classrooms = [
    Classroom(
      id: 1,
      floor: 1,
      hasEquipment: 'Sí',
      roomNumber: 'C-101',
      roomType: 'Teórica',
      tower: 'C',
    ),
    Classroom(
      id: 2,
      floor: 2,
      hasEquipment: 'No',
      roomNumber: 'B-201',
      roomType: 'Laboratorio',
      tower: 'B',
    ),
  ];
  int _nextId = 3;

  Future<List<Classroom>> getClassrooms() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List<Classroom>.from(_classrooms);
  }

  Future<void> addClassroom(Classroom classroom) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _classrooms.add(classroom.copyWith(id: _nextId++));
  }

  Future<void> updateClassroom(Classroom classroom) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _classrooms.indexWhere((c) => c.id == classroom.id);
    if (index != -1) {
      _classrooms[index] = classroom;
    }
  }

  Future<void> deleteClassroom(int id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _classrooms.removeWhere((c) => c.id == id);
  }
}

extension ClassroomCopy on Classroom {
  Classroom copyWith({
    int? id,
    int? floor,
    String? hasEquipment,
    String? roomNumber,
    String? roomType,
    String? tower,
  }) {
    return Classroom(
      id: id ?? this.id,
      floor: floor ?? this.floor,
      hasEquipment: hasEquipment ?? this.hasEquipment,
      roomNumber: roomNumber ?? this.roomNumber,
      roomType: roomType ?? this.roomType,
      tower: tower ?? this.tower,
    );
  }
} 