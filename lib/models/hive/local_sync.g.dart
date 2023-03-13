// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_sync.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalSyncHiveAdapter extends TypeAdapter<LocalSyncHive> {
  @override
  final int typeId = 0;

  @override
  LocalSyncHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalSyncHive()
      ..object = fields[1] as String?
      ..added = (fields[2] as List?)?.cast<String>()
      ..updated = (fields[3] as List?)?.cast<String>()
      ..deleted = (fields[4] as List?)?.cast<String>();
  }

  @override
  void write(BinaryWriter writer, LocalSyncHive obj) {
    writer
      ..writeByte(4)
      ..writeByte(1)
      ..write(obj.object)
      ..writeByte(2)
      ..write(obj.added)
      ..writeByte(3)
      ..write(obj.updated)
      ..writeByte(4)
      ..write(obj.deleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalSyncHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
