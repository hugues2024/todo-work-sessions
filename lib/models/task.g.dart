// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      id: fields[0] as String,
      title: fields[1] as String,
      subtitle: fields[2] as String,
      createdAtTime: fields[3] as DateTime,
      createdAtDate: fields[4] as DateTime,
      isCompleted: fields[5] as bool,
      startDate: fields[6] as DateTime?,
      endDate: fields[7] as DateTime?,
      workingDuration: fields[8] as int,
      priority: fields[9] as int,
      status: fields[10] as String,
      parentId: fields[11] as String?,
      isOngoing: fields[12] as bool,
      history: (fields[13] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.subtitle)
      ..writeByte(3)
      ..write(obj.createdAtTime)
      ..writeByte(4)
      ..write(obj.createdAtDate)
      ..writeByte(5)
      ..write(obj.isCompleted)
      ..writeByte(6)
      ..write(obj.startDate)
      ..writeByte(7)
      ..write(obj.endDate)
      ..writeByte(8)
      ..write(obj.workingDuration)
      ..writeByte(9)
      ..write(obj.priority)
      ..writeByte(10)
      ..write(obj.status)
      ..writeByte(11)
      ..write(obj.parentId)
      ..writeByte(12)
      ..write(obj.isOngoing)
      ..writeByte(13)
      ..write(obj.history);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
