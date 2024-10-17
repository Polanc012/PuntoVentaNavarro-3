import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:puntoventanavarro/models/product.dart';
import 'package:puntoventanavarro/models/venta.dart';
import 'package:puntoventanavarro/widgets/icon_text_field.dart';

class GenerarVentas extends StatefulWidget {
  const GenerarVentas({Key? key}) : super(key: key);

  @override
  _GenerarVentasState createState() => _GenerarVentasState();
}

class _GenerarVentasState extends State<GenerarVentas> {
  final TextEditingController _codigoController = TextEditingController();
  List<Product> _productos = [];
  final List<Map<String, dynamic>> _productosAnadidos = [];
  double _total = 0.0;

  get codigoProducto => null;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  void _cargarProductos() {
    final box = Hive.box<Product>('products');
    if (box.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay productos disponibles')),
      );
    } else {
      setState(() {
        _productos = box.values.toList();
      });
    }
  }

  void _buscarProducto() {
    final box = Hive.box<Product>('products');
    String codigo = _codigoController.text;

    if (codigo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingrese un código de barras')),
      );
      return;
    }

    Product producto = box.values.cast<Product>().firstWhere(
          (p) => p.codigo == codigo,
          orElse: () => Product(
            codigo: '',
            nombre: 'Producto no encontrado',
            costo: 0.0,
            precio: 0.0,
            cantidad: 0,
          ),
        );

    if (producto.nombre == 'Producto no encontrado') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Producto no encontrado')),
      );
    } else {
      _mostrarDialogoProducto(producto);
    }
  }

  void _mostrarDialogoProducto(Product producto) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int cantidad = 1;
        return AlertDialog(
          title: Text('Producto encontrado: ${producto.nombre}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Código: ${producto.codigo}'),
              Text('Precio: \$${producto.precio.toStringAsFixed(2)}'),
              Text('Cantidad disponible: ${producto.cantidad}'),
              TextField(
                decoration:
                    const InputDecoration(labelText: 'Cantidad a añadir'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  cantidad = int.tryParse(value) ?? 1;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (producto.cantidad >= cantidad) {
                  setState(() {
                    _productosAnadidos.add({
                      'producto': producto,
                      'cantidad': cantidad,
                    });
                    _total += producto.precio * cantidad;
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Producto añadido')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cantidad insuficiente')),
                  );
                }
              },
              child: Text('Añadir', style: GoogleFonts.josefinSans()),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar', style: GoogleFonts.josefinSans()),
            ),
          ],
        );
      },
    );
  }

  void _guardarVenta() {
    final nuevaVenta = Venta(
      codigo: '123456',
      nombre: 'Producto Ejemplo',
      cantidad: 1, // Asegúrate de que sea int
      precio: 50.0, // Asegúrate de que sea double
      total: 50.0, // Asegúrate de que sea double
    );

    final ventasBox = Hive.box<Venta>('ventasBox');
    ventasBox.add(nuevaVenta);
  }

  void _finalizarCompra() {
    double total = 0.0;
    for (var item in _productosAnadidos) {
      Product producto = item['producto'];
      int cantidad = item['cantidad'];
      total += producto.precio * cantidad;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Compra'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ..._productosAnadidos.map((item) {
                Product producto = item['producto'];
                int cantidad = item['cantidad'];
                return ListTile(
                  title: Text(producto.nombre),
                  subtitle: Text(
                      'Cantidad: $cantidad - Precio: \$${producto.precio.toStringAsFixed(2)}'),
                );
              }),
              const SizedBox(height: 10),
              Text('Total: \$${total.toStringAsFixed(2)}',
                  style: GoogleFonts.josefinSans(fontSize: 18)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar', style: GoogleFonts.josefinSans()),
            ),
            TextButton(
              onPressed: () {
                _guardarCompra();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Compra realizada con éxito')),
                );
              },
              child: Text('Pagar', style: GoogleFonts.josefinSans()),
            ),
          ],
        );
      },
    );
  }

  void _guardarCompra() {
    final ventasBox = Hive.box<Venta>('ventasBox');
    final productosBox = Hive.box<Product>('products');

    for (var item in _productosAnadidos) {
      Product producto = item['producto'];
      int cantidad = item['cantidad'];

      // Crear una instancia de Venta
      Venta venta = Venta(
        codigo: producto.codigo,
        nombre: producto.nombre,
        precio: producto.precio,
        cantidad: cantidad,
        total: producto.precio * cantidad,
      );

      // Guardar en ventasBox
      ventasBox.add(venta);

      // Actualizar el inventario en la caja de productos
      _actualizarInventario(producto.codigo, cantidad);
    }

    // Limpiar el carrito de productos añadidos y el total después de la compra
    setState(() {
      _productosAnadidos.clear();
      _total = 0.0;
    });
  }

  void _actualizarInventario(String codigoProducto, int cantidadVendida) {
    var box = Hive.box<Product>('products');

    // Buscar el producto usando el código de barras
    Product? producto;
    try {
      producto = box.values.firstWhere((p) => p.codigo == codigoProducto);
    } catch (e) {
      producto = null;
    }

    if (producto != null) {
      if (producto.cantidad >= cantidadVendida) {
        // Restar la cantidad vendida del inventario
        producto.cantidad -= cantidadVendida;

        // Guardar el producto actualizado en la misma posición
        int index = box.values.toList().indexOf(producto);
        box.putAt(index, producto);

        print(
            "Producto actualizado: ${producto.nombre}, nueva cantidad: ${producto.cantidad}");
      } else {
        print("Cantidad insuficiente para ${producto.nombre}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Cantidad insuficiente para ${producto.nombre}")),
        );
      }
    } else {
      print("Producto no encontrado");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Producto no encontrado")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generar Ventas',
            style: GoogleFonts.josefinSans(fontSize: 24)),
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
              child: ListView.builder(
                itemCount: _productos.length,
                itemBuilder: (context, index) {
                  final producto = _productos[index];
                  return ListTile(
                    title:
                        Text(producto.nombre, style: GoogleFonts.josefinSans()),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Cantidad: ${producto.cantidad}',
                            style: GoogleFonts.josefinSans()),
                        Text('Precio: \$${producto.precio.toStringAsFixed(2)}',
                            style: GoogleFonts.josefinSans()),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        _mostrarDialogoProducto(producto);
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _buscarProducto,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.search, size: 24),
                      const SizedBox(width: 8),
                      Text('Buscar', style: GoogleFonts.cabin(fontSize: 20)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _finalizarCompra,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check, size: 24),
                      const SizedBox(width: 8),
                      Text('Finalizar Compra',
                          style: GoogleFonts.cabin(fontSize: 20)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Total: \$${_total.toStringAsFixed(2)}',
              style: GoogleFonts.josefinSans(fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }
}
