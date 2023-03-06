// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fragment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FragmentHiveAdapter extends TypeAdapter<FragmentHive> {
  @override
  final int typeId = 0;

  @override
  FragmentHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FragmentHive()
      ..id = fields[0] as String?
      ..category = fields[1] as String?
      ..title = fields[2] as String?
      ..description = fields[3] as String?
      ..note = fields[4] as String?
      ..linkedItems = (fields[5] as List?)?.cast<String?>()
      ..date = fields[6] as DateTime?;
  }

  @override
  void write(BinaryWriter writer, FragmentHive obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.note)
      ..writeByte(5)
      ..write(obj.linkedItems)
      ..writeByte(6)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FragmentHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
