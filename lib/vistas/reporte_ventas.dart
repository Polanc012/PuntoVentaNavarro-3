import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:puntoventanavarro/models/venta.dart';
import 'package:intl/intl.dart';

class ReporteVentas extends StatefulWidget {
  const ReporteVentas({Key? key}) : super(key: key);

  @override
  _ReporteVentasState createState() => _ReporteVentasState();
}

class _ReporteVentasState extends State<ReporteVentas> {
  List<VentaAgrupada> _ventasAgrupadas = []; // Lista para las ventas agrupadas

  @override
  void initState() {
    super.initState();
    _cargarVentas();
  }

  void _cargarVentas() {
    final ventasBox = Hive.box<Venta>('ventasBox'); // Accede a la caja abierta
    final List<VentaAgrupada> ventasAgrupadas = []; // Lista para almacenar ventas agrupadas

    for (var venta in ventasBox.values) {
      // Buscar si ya existe una venta agrupada con la misma fecha y hora
      var ventaExistente = ventasAgrupadas.firstWhere(
              (v) => v.fechaHora == venta.fechaHora,
          orElse: () => VentaAgrupada(
              nombre: venta.nombre,
              cantidadTotal: 0,
              total: 0.0,
              fechaHora: venta.fechaHora));

      // Si existe, actualizamos los valores; si no, se añade como nueva
      if (ventasAgrupadas.contains(ventaExistente)) {
        ventaExistente.cantidadTotal += venta.cantidad;
        ventaExistente.total += venta.total;
      } else {
        ventasAgrupadas.add(VentaAgrupada(
          nombre: venta.nombre,
          cantidadTotal: venta.cantidad,
          total: venta.total,
          fechaHora: venta.fechaHora,
        ));
      }
    }

    setState(() {
      _ventasAgrupadas = ventasAgrupadas;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte Ventas'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _ventasAgrupadas.isEmpty
                ? const Center(
              child: Text(
                'No hay ventas registradas',
                style: TextStyle(fontSize: 24),
              ),
            )
                : ListView.builder(
              itemCount: _ventasAgrupadas.length,
              itemBuilder: (context, index) {
                final venta = _ventasAgrupadas[index];
                return ListTile(
                  title: Text('Producto: ${venta.nombre}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cantidad: ${venta.cantidadTotal}'),
                      Text('Total: \$${venta.total.toStringAsFixed(2)}'),
                      Text(
                        'Fecha y hora: ${DateFormat('dd/MM/yyyy HH:mm').format(venta.fechaHora)}',
                      ), // Muestra la fecha y hora
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total de ventas: \$${_calcularTotal().toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  double _calcularTotal() {
    return _ventasAgrupadas.fold(0, (sum, venta) => sum + venta.total);
  }
}