import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import '../models/product.dart'; // Verifica que esta ruta sea correcta

class Inventario extends StatefulWidget {
  const Inventario({Key? key}) : super(key: key);

  @override
  _InventarioState createState() => _InventarioState();
}

class _InventarioState extends State<Inventario> {
  late Future<Box<Product>> _productBoxFuture;
  Box<Product>? _productBox;
  int? _selectedProductIndex; // Índice del producto seleccionado

  @override
  void initState() {
    super.initState();
    _productBoxFuture = _initializeHive();
  }

  Future<Box<Product>> _initializeHive() async {
    final box = await Hive.openBox<Product>('products');
    setState(() {
      _productBox = box;
    });
    return box;
  }

  Future<void> _addProduct(String codigo, String nombre, double costo, double precio, int cantidad) async {
    if (_productBox != null) {
      final newProduct = Product(
        codigo: codigo,
        nombre: nombre,
        costo: costo,
        precio: precio,
        cantidad: cantidad,
      );
      await _productBox!.add(newProduct);
      setState(() {}); // Actualizar la UI
    }
  }

  Future<void> _deleteProduct(String codigo) async {
    if (_productBox != null) {
      final productIndex = _productBox!.values.toList().indexWhere((product) => product.codigo == codigo);
      if (productIndex != -1) {
        await _productBox!.deleteAt(productIndex);
        setState(() {}); // Actualizar la UI
      } else {
        _mostrarAlerta(context, 'Código de barras incorrecto o inexistente');
      }
    }
  }

  Future<void> _modifyProduct(String codigo) async {
    if (_productBox != null) {
      final productIndex = _productBox!.values.toList().indexWhere((product) => product.codigo == codigo);
      if (productIndex != -1) {
        final existingProduct = _productBox!.getAt(productIndex)!;

        String? nombre = await _mostrarDialogoInput(context, 'Nuevo Nombre', existingProduct.nombre);
        String? costoStr = await _mostrarDialogoInput(context, 'Nuevo Costo', existingProduct.costo.toString());
        String? precioStr = await _mostrarDialogoInput(context, 'Nuevo Precio', existingProduct.precio.toString());
        String? cantidadStr = await _mostrarDialogoInput(context, 'Nueva Cantidad', existingProduct.cantidad.toString());

        if (nombre != null && costoStr != null && precioStr != null && cantidadStr != null) {
          int cantidad = int.parse(cantidadStr);
          double costo = double.parse(costoStr);
          double precio = double.parse(precioStr);

          final updatedProduct = Product(
            codigo: codigo,
            nombre: nombre,
            costo: costo,
            precio: precio,
            cantidad: cantidad,

          );

          await _productBox!.putAt(productIndex, updatedProduct);
          setState(() {}); // Actualizar la UI
        }
      } else {
        _mostrarAlerta(context, 'Código de barras incorrecto o inexistente');
      }
    }
  }

  Future<String?> _mostrarDialogoInput(BuildContext context, String titulo, [String? textoInicial]) {
    TextEditingController controller = TextEditingController(text: textoInicial);
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titulo),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Ingrese el $titulo'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
              child: const Text('Aceptar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _mostrarAlerta(BuildContext context, String mensaje) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Advertencia'),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'INVENTARIO',
          style: GoogleFonts.josefinSans(
              fontSize: 41, color: Colors.lightBlueAccent),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(15.0),
                ),
                padding: const EdgeInsets.all(8.0),
                child: FutureBuilder<Box<Product>>(
                  future: _productBoxFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }

                    _productBox = snapshot.data;
                    final products = _productBox!.values.toList();

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Table(
                          border: TableBorder.all(color: Colors.grey),
                          columnWidths: const {
                            0: FixedColumnWidth(120.0),
                            1: FixedColumnWidth(150.0),
                            2: FixedColumnWidth(80.0),
                            3: FixedColumnWidth(80.0),
                            4: FixedColumnWidth(110.0),
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                color: Colors.blueGrey[100],
                              ),
                              children: [
                                _buildTableHeader(' Código'),
                                _buildTableHeader(' Producto'),
                                _buildTableHeader(' Costo'),
                                _buildTableHeader(' Precio'),
                                _buildTableHeader(' Cantidad'),
                              ],
                            ),
                            ...products.asMap().entries.map((entry) {
                              int index = entry.key;
                              Product product = entry.value;
                              return TableRow(
                                decoration: BoxDecoration(
                                  color: _selectedProductIndex == index
                                      ? Colors.blue[100]
                                      : Colors.white,
                                ),
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedProductIndex = index;
                                      });
                                    },
                                    child: _buildTableCell(product.codigo),
                                  ),
                                  _buildTableCell(product.nombre),
                                  _buildTableCell('\$${product.costo.toStringAsFixed(2)}'),
                                  _buildTableCell('\$${product.precio.toStringAsFixed(2)}'),
                                  _buildTableCell(product.cantidad.toString()),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    String? codigo = await _mostrarDialogoInput(context, 'Código de Barras');
                    String? nombre = await _mostrarDialogoInput(context, 'Nombre del Producto');
                    String? costoStr = await _mostrarDialogoInput(context, 'Costo');
                    String? precioStr = await _mostrarDialogoInput(context, 'Precio');
                    String? cantidadStr = await _mostrarDialogoInput(context, 'Cantidad');

                    if (codigo != null && nombre != null && costoStr != null && precioStr != null && cantidadStr != null) {
                      int cantidad = int.parse(cantidadStr);
                      double costo = double.parse(costoStr);
                      double precio = double.parse(precioStr);

                      await _addProduct(codigo, nombre, costo, precio, cantidad);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: Text(
                    'Agregar',
                    style: GoogleFonts.josefinSans(fontSize: 18, color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_selectedProductIndex != null) {
                      final product = _productBox!.getAt(_selectedProductIndex!);
                      if (product != null) {
                        await _deleteProduct(product.codigo);
                      }
                    } else {
                      String? codigo = await _mostrarDialogoInput(context, 'Código de Barras para Eliminar');
                      if (codigo !=

                          null) {
                        await _deleteProduct(codigo);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: Text(
                    'Eliminar',
                    style: GoogleFonts.josefinSans(fontSize: 18, color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_selectedProductIndex != null) {
                      final product = _productBox!.getAt(_selectedProductIndex!);
                      if (product != null) {
                        await _modifyProduct(product.codigo);
                      }
                    } else {
                      String? codigo = await _mostrarDialogoInput(context, 'Código de Barras para Modificar');
                      if (codigo != null) {
                        await _modifyProduct(codigo);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                  child: Text(
                    'Modificar',
                    style: GoogleFonts.josefinSans(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: GoogleFonts.josefinSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: GoogleFonts.josefinSans(fontSize: 14, color: Colors.black),
        textAlign: TextAlign.center,
      ),
    );
  }
}