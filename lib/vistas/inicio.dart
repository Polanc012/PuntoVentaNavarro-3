import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:puntoventanavarro/widgets/date_time_display.dart'; // Asegúrate de importar el nuevo widget

class Inicio extends StatelessWidget {
  final String username;
  final String userType;

  const Inicio({Key? key, required this.username, required this.userType})
      : super(key: key);

  void _navigateTo(BuildContext context, String route) {
    if (userType == 'empleado' &&
        (route == '/usuarios' || route == '/reporte_ventas')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Acceso denegado a esta sección.'),
        ),
      );
    } else {
      Navigator.pushNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'INICIO',
              style: GoogleFonts.josefinSans(),
            ),
            const DateTimeDisplay(),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(5.0),
              child: Column(
                children: [
                  Text(
                    '  Bienvenido:',
                    style: GoogleFonts.jost(
                        fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    (username).toUpperCase(),
                    style: GoogleFonts.outfit(fontSize: 35),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tipo de usuario:',
                    style: GoogleFonts.jost(
                        fontSize: 20, fontStyle: FontStyle.italic),
                  ),
                  Text(
                    (' $userType').toUpperCase(),
                    style: GoogleFonts.cabin(fontSize: 20),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                children: [
                  // Botón Usuarios
                  Container(
                    margin: const EdgeInsets.all(10.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        minimumSize: const Size(110, 140),
                      ),
                      onPressed: () {
                        _navigateTo(context, '/usuarios');
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.person, color: Colors.black),
                          Text('Usuarios',
                              style: GoogleFonts.cabin(
                                  fontSize: 22, color: Colors.black)),
                        ],
                      ),
                    ),
                  ),
                  // Botón Generar Ventas
                  Container(
                    margin: const EdgeInsets.all(10.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        minimumSize: const Size(110, 140),
                      ),
                      onPressed: () {
                        _navigateTo(context, '/generar_ventas');
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shopping_cart, color: Colors.black),
                          FittedBox(
                            child: Text('Generar Ventas',
                                style: GoogleFonts.cabin(
                                    fontSize: 25, color: Colors.black)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Botón Catálogo
                  Container(
                    margin: const EdgeInsets.all(10.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        minimumSize: const Size(110, 140),
                      ),
                      onPressed: () {
                        _navigateTo(context, '/catalogo');
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.list, color: Colors.black),
                          Text('Catalogo',
                              style: GoogleFonts.cabin(
                                  fontSize: 22, color: Colors.black)),
                        ],
                      ),
                    ),
                  ),
                  // Botón Inventario
                  Container(
                    margin: const EdgeInsets.all(10.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        minimumSize: const Size(110, 140),
                      ),
                      onPressed: () {
                        _navigateTo(context, '/inventario');
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.inventory, color: Colors.black),
                          Text('Inventario',
                              style: GoogleFonts.cabin(
                                  fontSize: 22, color: Colors.black)),
                        ],
                      ),
                    ),
                  ),
                  // Botón Reporte Ventas
                  Container(
                    margin: const EdgeInsets.all(10.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        minimumSize: const Size(110, 140),
                      ),
                      onPressed: () {
                        _navigateTo(context, '/reporte_ventas');
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.monetization_on,
                              color: Colors.black),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text('Reporte Ventas',
                                style: GoogleFonts.cabin(
                                    fontSize: 22, color: Colors.black)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
