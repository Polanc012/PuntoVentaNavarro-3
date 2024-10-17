import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:puntoventanavarro/models/product.dart';
import 'package:puntoventanavarro/widgets/icon_text_field.dart';
import 'package:hive/hive.dart';

class Catalogo extends StatefulWidget {
  const Catalogo({Key? key}) : super(key: key);

  @override
  _CatalogoState createState() => _CatalogoState();
}

class _CatalogoState extends State<Catalogo> {
  final TextEditingController _codigoController = TextEditingController();
  Product? _productoSeleccionado;
  List<Product> _productos = [];

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  void _cargarProductos() {
    final box = Hive.box<Product>('products'); // Usa la caja abierta
    setState(() {
      _productos = box.values.toList();
    });
  }

  void _buscarProducto() {
    final box = Hive.box<Product>('products'); // Usa la caja abierta
    String codigo = _codigoController.text;

    Product? producto = box.values.cast<Product>().firstWhere(
          (p) => p.codigo == codigo,
      orElse: () => Product(
        codigo: '',
        nombre: 'Producto no encontrado',
        costo: 0.0,
        precio: 0.0,
        cantidad: 0,

      ),
    );

    setState(() {
      _productoSeleccionado = producto;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catálogo', style: GoogleFonts.josefinSans(fontSize: 45)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            IconTextField(
              icon: Icons.qr_code,
              hintText: 'Ingrese el código de barras',
              controller: _codigoController,
              hintStyle: GoogleFonts.josefinSans(),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                itemCount: _productos.length,
                itemBuilder: (context, index) {
                  final producto = _productos[index];
                  return ListTile(
                    title: Text(producto.nombre, style: GoogleFonts.josefinSans()),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cantidad: ${producto.cantidad}', style: GoogleFonts.josefinSans()),
                        Text('Precio: \$${producto.precio.toStringAsFixed(2)}', style: GoogleFonts.josefinSans()),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, index) => const Divider(), // Línea horizontal entre productos
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _buscarProducto,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min, // Hace que el botón se ajuste al contenido
                children: [
                  const Icon(Icons.search, size: 24), // Icono de búsqueda
                  const SizedBox(width: 8),
                  Text(
                    'Buscar',
                    style: GoogleFonts.cabin(fontSize: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _productoSeleccionado != null
                ? Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Producto: ${_productoSeleccionado!.nombre}', // Cambiado a `nombre`
                    style: GoogleFonts.cabin(fontSize: 18),
                  ),
                  Text(
                    'Precio: \$${_productoSeleccionado!.precio.toStringAsFixed(2)}', // Cambiado a `precio`
                    style: GoogleFonts.cabin(fontSize: 18),
                  ),
                  Text(
                    'Cantidad: ${_productoSeleccionado!.cantidad}', // Cambiado a `cantidad`
                    style: GoogleFonts.cabin(fontSize: 18),
                  ),
                ],
              ),
            )
                : const Text(
              'No se encontró ningún producto',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}