import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medioambiente_rd/shared/services/api_service.dart';

class MapaAreasScreen extends StatefulWidget {
  const MapaAreasScreen({super.key});

  @override
  State<MapaAreasScreen> createState() => _MapaAreasScreenState();
}

class _MapaAreasScreenState extends State<MapaAreasScreen> {
  late GoogleMapController _mapController;
  List<Map<String, dynamic>> areas = [];
  Set<Marker> _markers = {};
  bool _isLoading = true;
  LatLng _initialPosition = const LatLng(18.7357, -70.1627); // Centro de RD

  @override
  void initState() {
    super.initState();
    _cargarAreas();
  }

  Future<void> _cargarAreas() async {
    try {
      final api = ApiService();
      final response = await api.get('areas-protegidas');
      
      if (response['exito'] == true) {
        setState(() {
          areas = List<Map<String, dynamic>>.from(response['datos']);
          _crearMarkers();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Datos de ejemplo
      areas = [
        {
          'id': '1',
          'nombre': 'Parque Nacional Los Haitises',
          'latitud': '19.0333',
          'longitud': '-69.5833',
          'tipo': 'Parque Nacional',
        },
        {
          'id': '2',
          'nombre': 'Parque Nacional Jaragua',
          'latitud': '17.8000',
          'longitud': '-71.4667',
          'tipo': 'Parque Nacional',
        },
      ];
      _crearMarkers();
    }
  }

  void _crearMarkers() {
    Set<Marker> markers = {};

    for (var area in areas) {
      try {
        final lat = double.tryParse(area['latitud'].toString()) ?? 0.0;
        final lng = double.tryParse(area['longitud'].toString()) ?? 0.0;

        if (lat != 0.0 && lng != 0.0) {
          final marker = Marker(
            markerId: MarkerId(area['id']),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: area['nombre'],
              snippet: area['tipo'],
              onTap: () {
                _mostrarDetalleArea(area);
              },
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              _getMarkerColor(area['tipo']),
            ),
            onTap: () {
              _mostrarDetalleArea(area);
            },
          );
          markers.add(marker);
        }
      } catch (e) {
        // Ignorar errores de parsing
      }
    }

    setState(() {
      _markers = markers;
    });
  }

  double _getMarkerColor(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'parque nacional':
        return BitmapDescriptor.hueGreen;
      case 'reserva científica':
        return BitmapDescriptor.hueBlue;
      case 'refugio de vida silvestre':
        return BitmapDescriptor.hueOrange;
      case 'monumento natural':
        return BitmapDescriptor.hueViolet;
      default:
        return BitmapDescriptor.hueRed;
    }
  }

  void _mostrarDetalleArea(Map<String, dynamic> area) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Área Protegida',
                    style: TextStyle(
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
            const SizedBox(height: 16),
            Text(
              area['nombre'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(area['tipo']),
              backgroundColor: Colors.green.shade100,
            ),
            const SizedBox(height: 16),
            if (area['descripcion'] != null)
              Text(
                area['descripcion'],
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Centrar mapa en esta área
                      final lat = double.tryParse(area['latitud'].toString()) ?? 0.0;
                      final lng = double.tryParse(area['longitud'].toString()) ?? 0.0;
                      if (lat != 0.0 && lng != 0.0) {
                        _mapController.animateCamera(
                          CameraUpdate.newLatLngZoom(
                            LatLng(lat, lng),
                            12,
                          ),
                        );
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Centrar en Mapa'),
                  ),
                ),
              ],
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
        title: const Text('Mapa de Áreas Protegidas'),
        leading: Container(
          margin: const EdgeInsets.all(8),
          child: const CircleAvatar(
            backgroundImage: AssetImage('assets/avatars/estudiante7.jpg'),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _mostrarFiltros();
            },
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              // Centrar en ubicación actual
            },
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
                  mapType: MapType.normal,
                  onTap: (latLng) {
                    // Acción al tocar el mapa
                  },
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
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildLegendItem('Parque Nacional', Colors.green),
                        _buildLegendItem('Reserva Científica', Colors.blue),
                        _buildLegendItem('Refugio de Vida', Colors.orange),
                        _buildLegendItem('Monumento Natural', Colors.purple),
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
                      '${areas.length} Áreas',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mapController.animateCamera(
            CameraUpdate.newLatLngZoom(_initialPosition, 8),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.center_focus_strong),
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
              'Filtrar Áreas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Aquí puedes agregar filtros por tipo, provincia, etc.
            ListTile(
              leading: const Icon(Icons.filter_alt),
              title: const Text('Mostrar solo Parques Nacionales'),
              trailing: Switch(
                value: false,
                onChanged: (value) {
                  // Implementar filtro
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.filter_alt),
              title: const Text('Mostrar solo Reservas'),
              trailing: Switch(
                value: false,
                onChanged: (value) {
                  // Implementar filtro
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text('Aplicar Filtros'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}