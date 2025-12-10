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
      title: fields[1] as String,
      description: fields[2] as String,
      workDurationMinutes: fields[3] as int,
      breakDurationMinutes: fields[4] as int,
      createdAt: fields[5] as DateTime,
      isCompleted: fields[6] as bool?,
      completedAt: fields[7] as DateTime?,
      isRunning: fields[8] as bool?,
      elapsedSeconds: fields[9] as int,
      isOnBreak: fields[10] as bool?,
    )..id = fields[0] as String;
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
      ..write(obj.workDurationMinutes)
      ..writeByte(4)
      ..write(obj.breakDurationMinutes)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.isCompleted)
      ..writeByte(7)
      ..write(obj.completedAt)
      ..writeByte(8)
      ..write(obj.isRunning)
      ..writeByte(9)
      ..write(obj.elapsedSeconds)
      ..writeByte(10)
      ..write(obj.isOnBreak);
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
