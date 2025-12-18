// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkSessionAdapter extends TypeAdapter<WorkSession> {
  @override
  final int typeId = 3;

  @override
  WorkSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkSession(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      createdAt: fields[3] as DateTime,
      completedAt: fields[4] as DateTime?,
      elapsedSeconds: fields[5] as int,
      taskId: fields[6] as String?,
      isPersonal: fields[7] as bool,
      sessionType: fields[8] as String,
      workDurationMinutes: fields[9] as int,
      breakDurationMinutes: fields[10] as int,
    );
  }

  @override
  void write(BinaryWriter writer, WorkSession obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.completedAt)
      ..writeByte(5)
      ..write(obj.elapsedSeconds)
      ..writeByte(6)
      ..write(obj.taskId)
      ..writeByte(7)
      ..write(obj.isPersonal)
      ..writeByte(8)
      ..write(obj.sessionType)
      ..writeByte(9)
      ..write(obj.workDurationMinutes)
      ..writeByte(10)
      ..write(obj.breakDurationMinutes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
