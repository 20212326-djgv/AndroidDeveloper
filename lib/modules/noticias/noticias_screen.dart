import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:medioambiente_rd/shared/services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class NoticiasScreen extends StatefulWidget {
  const NoticiasScreen({super.key});

  @override
  State<NoticiasScreen> createState() => _NoticiasScreenState();
}

class _NoticiasScreenState extends State<NoticiasScreen> {
  List<Map<String, dynamic>> noticias = [];
  bool _isLoading = true;
  String _selectedCategory = 'Todas';
  final List<String> categories = [
    'Todas',
    'Cambio Climático',
    'Biodiversidad',
    'Reciclaje',
    'Políticas',
    'Eventos',
  ];

  @override
  void initState() {
    super.initState();
    _cargarNoticias();
  }

  Future<void> _cargarNoticias() async {
    try {
      final api = ApiService();
      final response = await api.get('noticias');
      
      if (response['exito'] == true) {
        setState(() {
          noticias = List<Map<String, dynamic>>.from(response['datos']);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Datos de ejemplo
      noticias = [
        {
          'id': '1',
          'titulo': 'Ministerio lanza campaña de reforestación nacional',
          'descripcion': 'Se plantarán más de 100,000 árboles en áreas protegidas',
          'contenido': 'El Ministerio de Medio Ambiente inició una campaña nacional...',
          'fecha': '2025-11-15',
          'categoria': 'Eventos',
          'imagen': 'https://adamix.net/medioambiente/imagenes/noticia1.jpg',
          'fuente': 'Ministerio de Medio Ambiente',
          'enlace': 'https://medioambiente.gob.do/noticia1',
        },
        {
          'id': '2',
          'titulo': 'RD reduce emisiones de carbono en 15%',
          'descripcion': 'Logros significativos en la lucha contra el cambio climático',
          'contenido': 'La República Dominicana ha logrado reducir...',
          'fecha': '2025-11-10',
          'categoria': 'Cambio Climático',
          'imagen': 'https://adamix.net/medioambiente/imagenes/noticia2.jpg',
          'fuente': 'ONU Medio Ambiente',
          'enlace': 'https://medioambiente.gob.do/noticia2',
        },
        {
          'id': '3',
          'titulo': 'Nueva especie descubierta en Parque Nacional Jaragua',
          'descripcion': 'Científicos identifican nueva especie de anfibio endémico',
          'contenido': 'Investigadores del Ministerio descubrieron...',
          'fecha': '2025-11-05',
          'categoria': 'Biodiversidad',
          'imagen': 'https://adamix.net/medioambiente/imagenes/noticia3.jpg',
          'fuente': 'National Geographic',
          'enlace': 'https://medioambiente.gob.do/noticia3',
        },
      ];
    }
  }

  List<Map<String, dynamic>> get filteredNoticias {
    if (_selectedCategory == 'Todas') return noticias;
    return noticias
        .where((noticia) => noticia['categoria'] == _selectedCategory)
        .toList();
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy', 'es').format(date);
    } catch (e) {
      return dateString;
    }
  }

  void _verDetalleNoticia(Map<String, dynamic> noticia) {
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
                        'Noticia Ambiental',
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
                if (noticia['imagen'] != null && noticia['imagen'].isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: noticia['imagen'],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 200,
                        color: Colors.grey[200],
                        child: const Icon(Icons.error),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Chip(
                  backgroundColor: Colors.green.shade100,
                  label: Text(noticia['categoria'] ?? 'General'),
                ),
                const SizedBox(height: 10),
                Text(
                  noticia['titulo'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.date_range, size: 16, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text(
                      _formatDate(noticia['fecha']),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(width: 15),
                    const Icon(Icons.source, size: 16, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text(
                      noticia['fuente'] ?? 'Fuente no disponible',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  noticia['contenido'] ?? noticia['descripcion'],
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 30),
                if (noticia['enlace'] != null && noticia['enlace'].isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final url = Uri.parse(noticia['enlace']);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url);
                        }
                      },
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text('Ver noticia completa'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 15),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Noticias Ambientales'),
        leading: Container(
          margin: const EdgeInsets.all(8),
          child: const CircleAvatar(
            backgroundImage: AssetImage('assets/avatars/estudiante4.jpg'),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarNoticias,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtro de categorías
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8, top: 12),
                  child: FilterChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? category : 'Todas';
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: Colors.green,
                    labelStyle: TextStyle(
                      color: _selectedCategory == category
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),
          // Lista de noticias
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredNoticias.isEmpty
                    ? const Center(
                        child: Text('No hay noticias disponibles'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredNoticias.length,
                        itemBuilder: (context, index) {
                          final noticia = filteredNoticias[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 3,
                            child: InkWell(
                              onTap: () => _verDetalleNoticia(noticia),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Imagen
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                    ),
                                    child: Stack(
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl: noticia['imagen'],
                                          height: 180,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
                                            height: 180,
                                            color: Colors.grey[200],
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                            height: 180,
                                            color: Colors.grey[200],
                                            child: const Icon(Icons.image),
                                          ),
                                        ),
                                        Positioned(
                                          top: 10,
                                          left: 10,
                                          child: Chip(
                                            backgroundColor: Colors.green
                                                .withOpacity(0.8),
                                            label: Text(
                                              noticia['categoria'] ?? 'General',
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Contenido
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          noticia['titulo'],
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          noticia['descripcion'],
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 14,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(Icons.date_range,
                                                    size: 14, color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Text(
                                                  _formatDate(noticia['fecha']),
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Icon(Icons.source,
                                                    size: 14, color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Text(
                                                  noticia['fuente'] ??
                                                      'Ministerio',
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _cargarNoticias,
        backgroundColor: Colors.green,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}