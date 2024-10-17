import 'package:hive/hive.dart';

part 'venta.g.dart';

@HiveType(typeId: 2)
class Venta {
  @HiveField(0)
  final String codigo;

  @HiveField(1)
  final String nombre;

  @HiveField(2)
  final int cantidad;

  @HiveField(3)
  final double precio;

  @HiveField(4)
  final double total;

  @HiveField(5) // Nuevo campo para fecha y hora
  final DateTime fechaHora;

  Venta({
    required this.codigo,
    required this.nombre,
    required this.cantidad,
    required this.precio,
    required this.total,
    DateTime? fechaHora, // Parámetro opcional
  }) : fechaHora = fechaHora ??
            DateTime
                .now(); // Establece la fecha y hora actual si no se proporciona
}

// Clase para agrupar ventas
class VentaAgrupada {
  final String nombre; // Mantener solo el nombre de los productos
  late final int cantidadTotal; // Sumar la cantidad de productos
  late final double total; // Sumar el total de la venta
  final DateTime fechaHora; // Mantener la fecha y hora de la venta

  VentaAgrupada({
    required this.nombre,
    required this.cantidadTotal,
    required this.total,
    required this.fechaHora,
  });
}
