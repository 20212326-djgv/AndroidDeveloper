import 'package:flutter/material.dart';
import 'package:medioambiente_rd/data/database/database_helper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class MisReportesScreen extends StatefulWidget {
  const MisReportesScreen({super.key});

  @override
  State<MisReportesScreen> createState() => _MisReportesScreenState();
}

class _MisReportesScreenState extends State<MisReportesScreen> {
  List<Map<String, dynamic>> reportes = [];
  bool _isLoading = true;
  String _selectedFilter = 'Todos';
  final List<String> _filters = ['Todos', 'Pendiente', 'En revisión', 'Resuelto', 'Rechazado'];

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
        reportes = datos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Datos de ejemplo
      reportes = [
        {
          'id': 1,
          'codigo': 'REP-2025-001',
          'titulo': 'Tala ilegal en bosque',
          'descripcion': 'Se observa tala de árboles sin permiso...',
          'foto': '',
          'latitud': 18.7357,
          'longitud': -70.1627,
          'fecha': '2025-11-20T10:30:00',
          'estado': 'En revisión',
          'comentario': 'Reporte recibido, en proceso de verificación',
          'categoria': 'Deforestación',
          'urgencia': 'Alta',
        },
        {
          'id': 2,
          'codigo': 'REP-2025-002',
          'titulo': 'Contaminación de río',
          'descripcion': 'Vertido de desechos en el río...',
          'foto': '',
          'latitud': 18.4567,
          'longitud': -69.9500,
          'fecha': '2025-11-18T14:20:00',
          'estado': 'Resuelto',
          'comentario': 'Situación controlada, se aplicaron sanciones',
          'categoria': 'Contaminación del agua',
          'urgencia': 'Media',
        },
      ];
    }
  }

  List<Map<String, dynamic>> get filteredReportes {
    if (_selectedFilter == 'Todos') return reportes;
    return reportes.where((reporte) => reporte['estado'] == _selectedFilter).toList();
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

  IconData _getEstadoIcon(String estado) {
    switch (estado) {
      case 'Pendiente':
        return Icons.access_time;
      case 'En revisión':
        return Icons.search;
      case 'Resuelto':
        return Icons.check_circle;
      case 'Rechazado':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return dateString;
    }
  }

  void _verDetalleReporte(Map<String, dynamic> reporte) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        maxChildSize: 1.0,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Detalle del Reporte',
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
                const SizedBox(height: 20),
                // Código y estado
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        color: Colors.green.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              const Text(
                                'Código',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                reporte['codigo'] ?? 'N/A',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Card(
                        color: _getEstadoColor(reporte['estado']).withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              const Text(
                                'Estado',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                reporte['estado'],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _getEstadoColor(reporte['estado']),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Información básica
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reporte['titulo'],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.date_range, size: 16, color: Colors.grey),
                            const SizedBox(width: 5),
                            Text(
                              _formatDate(reporte['fecha']),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(Icons.category, size: 16, color: Colors.grey),
                            const SizedBox(width: 5),
                            Text(
                              reporte['categoria'] ?? 'Sin categoría',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Descripción:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          reporte['descripcion'],
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Foto si existe
                if (reporte['foto'] != null && reporte['foto'].isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Evidencia fotográfica:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[200],
                        ),
                        child: const Center(
                          child: Icon(Icons.image, size: 50, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                // Comentario del Ministerio
                if (reporte['comentario'] != null && reporte['comentario'].isNotEmpty)
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.message, color: Colors.blue),
                              SizedBox(width: 10),
                              Text(
                                'Comentario del Ministerio',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(reporte['comentario']),
                          const SizedBox(height: 10),
                          Text(
                            'Última actualización: ${_formatDate(reporte['fecha'])}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _verEnMapa(reporte);
                        },
                        icon: const Icon(Icons.map),
                        label: const Text('Ver en Mapa'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _compartirReporte(reporte);
                        },
                        icon: const Icon(Icons.share),
                        label: const Text('Compartir'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (reporte['estado'] == 'Pendiente')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _cancelarReporte(reporte);
                      },
                      icon: const Icon(Icons.cancel),
                      label: const Text('Cancelar Reporte'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _verEnMapa(Map<String, dynamic> reporte) {
    if (reporte['latitud'] == null || reporte['longitud'] == null) return;

    final lat = reporte['latitud'] as double;
    final lng = reporte['longitud'] as double;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubicación del Reporte'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(lat, lng),
              zoom: 15,
            ),
            markers: {
              Marker(
                markerId: MarkerId(reporte['codigo']),
                position: LatLng(lat, lng),
                infoWindow: InfoWindow(
                  title: reporte['titulo'],
                  snippet: reporte['estado'],
                ),
              ),
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final url = Uri.parse(
                'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
              );
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              }
            },
            child: const Text('Abrir en Maps'),
          ),
        ],
      ),
    );
  }

  void _compartirReporte(Map<String, dynamic> reporte) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Compartir Reporte'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copiar código'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Código copiado')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Compartir detalles'),
              onTap: () {
                Navigator.pop(context);
                // Lógica para compartir
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _cancelarReporte(Map<String, dynamic> reporte) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Reporte'),
        content: const Text('¿Está seguro de que desea cancelar este reporte?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _eliminarReporte(reporte['id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _eliminarReporte(int id) async {
    // Lógica para eliminar reporte de la base de datos
    setState(() {
      reportes.removeWhere((reporte) => reporte['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reporte cancelado'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reportes'),
        leading: Container(
          margin: const EdgeInsets.all(8),
          child: const CircleAvatar(
            backgroundImage: AssetImage('assets/images/profile.jpg'),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/reportar');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Resumen estadístico
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green.shade50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard('Total', '${reportes.length}'),
                _buildStatCard('Pendientes', 
                  reportes.where((r) => r['estado'] == 'Pendiente').length.toString()),
                _buildStatCard('Resueltos', 
                  reportes.where((r) => r['estado'] == 'Resuelto').length.toString()),
              ],
            ),
          ),
          // Filtros
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: _selectedFilter == filter,
                      onSelected: (selected) {
                        setState(() {
                          _selectedFilter = selected ? filter : 'Todos';
                        });
                      },
                      selectedColor: Colors.green,
                      labelStyle: TextStyle(
                        color: _selectedFilter == filter
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Lista de reportes
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredReportes.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.report, size: 60, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No hay reportes',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            Text(
                              'Crea tu primer reporte',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredReportes.length,
                        itemBuilder: (context, index) {
                          final reporte = filteredReportes[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 3,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: _getEstadoColor(reporte['estado']).withOpacity(0.1),
                                child: Icon(
                                  _getEstadoIcon(reporte['estado']),
                                  color: _getEstadoColor(reporte['estado']),
                                ),
                              ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    reporte['titulo'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    reporte['codigo'],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.date_range,
                                        size: 14,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatDate(reporte['fecha']),
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Chip(
                                    label: Text(reporte['estado']),
                                    backgroundColor: _getEstadoColor(reporte['estado']).withOpacity(0.1),
                                    labelStyle: TextStyle(
                                      color: _getEstadoColor(reporte['estado']),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () => _verDetalleReporte(reporte),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/reportar');
        },
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Reporte'),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}