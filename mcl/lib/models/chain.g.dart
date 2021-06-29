// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chain.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChainAdapter extends TypeAdapter<Chain> {
  @override
  final int typeId = 1;

  @override
  Chain read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Chain(
      title: fields[0] as String,
      username: fields[1] as String,
      address: fields[2] as String,
      port: fields[3] as int,
      getinfo: (fields[4] as Map?)?.cast<String, dynamic>(),
      marmarainfo: (fields[5] as Map?)?.cast<String, dynamic>(),
      refreshTime: fields[6] as DateTime?,
      getGenerate: (fields[7] as Map?)?.cast<String, dynamic>(),
    )
      ..marmaraholderloops = (fields[8] as Map?)?.cast<String, dynamic>()
      ..marmaraholderloopsdetail = (fields[9] as Map?)?.cast<String, dynamic>();
  }

  @override
  void write(BinaryWriter writer, Chain obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.address)
      ..writeByte(3)
      ..write(obj.port)
      ..writeByte(4)
      ..write(obj.getinfo)
      ..writeByte(5)
      ..write(obj.marmarainfo)
      ..writeByte(6)
      ..write(obj.refreshTime)
      ..writeByte(7)
      ..write(obj.getGenerate)
      ..writeByte(8)
      ..write(obj.marmaraholderloops)
      ..writeByte(9)
      ..write(obj.marmaraholderloopsdetail);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChainAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
