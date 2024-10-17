// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venta.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VentaAdapter extends TypeAdapter<Venta> {
  @override
  final int typeId = 3;

  @override
  Venta read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Venta(
      codigo: fields[0] as String,
      nombre: fields[1] as String,
      cantidad: fields[2] as int,
      precio: fields[3] as double,
      total: fields[4] as double,
      fechaHora: fields[5] as DateTime, // Lee el nuevo campo

    );
  }

  @override
  void write(BinaryWriter writer, Venta obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.codigo)
      ..writeByte(1)
      ..write(obj.nombre)
      ..writeByte(2)
      ..write(obj.cantidad)
      ..writeByte(3)
      ..write(obj.precio)
      ..writeByte(4)
      ..write(obj.total)
      ..writeByte(5)
      ..write(obj.fechaHora);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VentaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
