import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 2)
class Product {
  @HiveField(0)
  final String codigo;

  @HiveField(1)
  final String nombre;

  @HiveField(2)
  final double costo;

  @HiveField(3)
  final double precio;

  @HiveField(4)
  int cantidad;


  // Agregar el campo 'key' aquí

  Product({
    required this.codigo,
    required this.nombre,
    required this.costo,
    required this.precio,
    required this.cantidad,
  });

  void restarCantidad(int cantidadARestar) {
    if (cantidad >= cantidadARestar) {
      cantidad -= cantidadARestar;
    } else {
      throw Exception('Cantidad insuficiente en inventario');
    }
  }
}