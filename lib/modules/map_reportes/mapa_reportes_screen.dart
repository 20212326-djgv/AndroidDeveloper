import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medioambiente_rd/data/database/database_helper.dart';

class MapaReportesScreen extends StatefulWidget {
  const MapaReportesScreen({super.key});

  @override
  State<MapaReportesScreen> createState() => _MapaReportesScreenState();
}

class _MapaReportesScreenState extends State<MapaReportesScreen> {
  late GoogleMapController _mapController;
  List<Map<String, dynamic>> _reportes = [];
  Set<Marker> _markers = {};
  bool _isLoading = true;
  String _selectedFilter = 'Todos';
  LatLng _initialPosition = const LatLng(18.7357, -70.1627); // Centro de RD

  final List<String> _filters = ['Todos', 'Pendiente', 'En revisión', 'Resuelto', 'Rechazado'];
  final List<String> _categorias = ['Todos', 'Deforestación', 'Contaminación', 'Fauna', 'Otros'];

  @override
  void initState() {
    super.initState();
    _cargarReportes();
  }

  Future<void> _cargarReportes() async {
    try {
      final db = DatabaseHelper();
      final datos = await db.getReportes();
      
      setState(() {
        _reportes = datos;
        _crearMarkers();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Datos de ejemplo
      _reportes = [
        {
          'id': 1,
          'codigo': 'REP-2025-001',
          'titulo': 'Tala ilegal',
          'descripcion': 'Tala de árboles en zona protegida',
          'latitud': 18.7357,
          'longitud': -70.1627,
          'estado': 'En revisión',
          'categoria': 'Deforestación',
        },
        {
          'id': 2,
          'codigo': 'REP-2025-002',
          'titulo': 'Contaminación de río',
          'descripcion': 'Vertido de químicos',
          'latitud': 18.4567,
          'longitud': -69.9500,
          'estado': 'Resuelto',
          'categoria': 'Contaminación',
        },
      ];
      _crearMarkers();
    }
  }

  List<Map<String, dynamic>> get filteredReportes {
    var filtered = _reportes;

    if (_selectedFilter != 'Todos') {
      filtered = filtered.where((reporte) => reporte['estado'] == _selectedFilter).toList();
    }

    return filtered;
  }

  void _crearMarkers() {
    Set<Marker> markers = {};

    for (var reporte in filteredReportes) {
      try {
        final lat = reporte['latitud'] as double? ?? 0.0;
        final lng = reporte['longitud'] as double? ?? 0.0;

        if (lat != 0.0 && lng != 0.0) {
          final marker = Marker(
            markerId: MarkerId(reporte['codigo'] ?? reporte['id'].toString()),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: reporte['titulo'],
              snippet: '${reporte['estado']} - ${reporte['categoria']}',
              onTap: () {
                _mostrarDetalleReporte(reporte);
              },
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              _getMarkerColor(reporte['estado']),
            ),
            onTap: () {
              _mostrarDetalleReporte(reporte);
            },
          );
          markers.add(marker);
        }
      } catch (e) {
        // Ignorar errores
      }
    }

    setState(() {
      _markers = markers;
    });
  }

  double _getMarkerColor(String estado) {
    switch (estado) {
      case 'Pendiente':
        return BitmapDescriptor.hueOrange;
      case 'En revisión':
        return BitmapDescriptor.hueBlue;
      case 'Resuelto':
        return BitmapDescriptor.hueGreen;
      case 'Rechazado':
        return BitmapDescriptor.hueRed;
      default:
        return BitmapDescriptor.hueYellow;
    }
  }

  void _mostrarDetalleReporte(Map<String, dynamic> reporte) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    reporte['titulo'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Chip(
              label: Text(reporte['estado']),
              backgroundColor: _getEstadoColor(reporte['estado']).withOpacity(0.1),
              labelStyle: TextStyle(
                color: _getEstadoColor(reporte['estado']),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              reporte['descripcion'],
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final lat = reporte['latitud'] as double? ?? 0.0;
                  final lng = reporte['longitud'] as double? ?? 0.0;
                  if (lat != 0.0 && lng != 0.0) {
                    _mapController.animateCamera(
                      CameraUpdate.newLatLngZoom(
                        LatLng(lat, lng),
                        15,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('Centrar en este punto'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'Pendiente':
        return Colors.orange;
      case 'En revisión':
        return Colors.blue;
      case 'Resuelto':
        return Colors.green;
      case 'Rechazado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _mostrarFiltros() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtrar Reportes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Estado:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _filters.map((filter) {
                return ChoiceChip(
                  label: Text(filter),
                  selected: _selectedFilter == filter,
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = selected ? filter : 'Todos';
                      _crearMarkers();
                    });
                    Navigator.pop(context);
                  },
                  selectedColor: Colors.green,
                  labelStyle: TextStyle(
                    color: _selectedFilter == filter
                        ? Colors.white
                        : Colors.black,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              'Categoría:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categorias.map((categoria) {
                return FilterChip(
                  label: Text(categoria),
                  selected: false,
                  onSelected: (selected) {
                    // Implementar filtro por categoría
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Reportes'),
        leading: Container(
          margin: const EdgeInsets.all(8),
          child: const CircleAvatar(
            backgroundImage: AssetImage('assets/avatars/estudiante7.jpg'),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _mostrarFiltros,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarReportes,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _initialPosition,
                    zoom: 8,
                  ),
                  markers: _markers,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  zoomControlsEnabled: true,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
                // Leyenda
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Leyenda',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildLegendItem('Pendiente', Colors.orange),
                        _buildLegendItem('En revisión', Colors.blue),
                        _buildLegendItem('Resuelto', Colors.green),
                        _buildLegendItem('Rechazado', Colors.red),
                      ],
                    ),
                  ),
                ),
                // Contador
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${filteredReportes.length} reportes',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              _mapController.animateCamera(
                CameraUpdate.newLatLngZoom(_initialPosition, 8),
              );
            },
            backgroundColor: Colors.green,
            mini: true,
            child: const Icon(Icons.center_focus_strong),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/reportar');
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}