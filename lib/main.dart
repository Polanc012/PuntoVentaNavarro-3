import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:puntoventanavarro/models/product.dart';
import 'package:puntoventanavarro/models/user.dart';
import 'package:puntoventanavarro/models/venta.dart'; // Asegúrate de importar el modelo Venta
import 'package:puntoventanavarro/vistas/vista_principal.dart';
import 'package:puntoventanavarro/vistas/inicio.dart';
import 'package:puntoventanavarro/vistas/inventario.dart';
import 'package:puntoventanavarro/vistas/usuarios.dart';
import 'package:puntoventanavarro/vistas/catalogo.dart';
import 'package:puntoventanavarro/vistas/generar_ventas.dart';
import 'package:puntoventanavarro/vistas/reporte_ventas.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Registra los adaptadores
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(VentaAdapter()); // Registra el adaptador de Venta

  // Elimina la caja de ventas si ya existe para evitar conflictos de tipo
  await Hive.deleteBoxFromDisk('ventasBox');

  // Abre todas las cajas necesarias
  await Future.wait([
    Hive.openBox<Product>('products'),
    Hive.openBox<User>('users'),
    Hive.openBox<Venta>('ventasBox'), // Abre la caja de ventas
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Punto de Venta',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VistaPrincipal(),
      routes: {
        '/inicio': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return Inicio(
            username: args['username'] ?? '',
            userType: args['userType'] ?? '',
          );
        },
        '/usuarios': (context) => const Usuarios(
            userType: ''), // Asegúrate de que Usuarios no requiera parámetros
        '/inventario': (context) => const Inventario(),
        '/catalogo': (context) =>
            const Catalogo(), // Asegúrate de tener esta vista
        '/generar_ventas': (context) =>
            const GenerarVentas(), // Asegúrate de tener esta vista
        '/reporte_ventas': (context) =>
            const ReporteVentas(), // Asegúrate de tener esta vista
      },
    );
  }
}
