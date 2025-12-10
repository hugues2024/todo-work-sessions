// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_auth.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAuthAdapter extends TypeAdapter<UserAuth> {
  @override
  final int typeId = 4;

  @override
  UserAuth read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserAuth(
      email: fields[0] as String,
      password: fields[1] as String,
      isLoggedIn: fields[2] as bool,
      lastLogin: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserAuth obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.email)
      ..writeByte(1)
      ..write(obj.password)
      ..writeByte(2)
      ..write(obj.isLoggedIn)
      ..writeByte(3)
      ..write(obj.lastLogin);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAuthAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
