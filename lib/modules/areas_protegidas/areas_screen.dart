import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:medioambiente_rd/shared/services/api_service.dart';

class AreasProtegidasScreen extends StatefulWidget {
  const AreasProtegidasScreen({super.key});

  @override
  State<AreasProtegidasScreen> createState() => _AreasProtegidasScreenState();
}

class _AreasProtegidasScreenState extends State<AreasProtegidasScreen> {
  List<Map<String, dynamic>> areas = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedProvincia = 'Todas';
  String _selectedTipo = 'Todos';

  final List<String> provincias = [
    'Todas',
    'Santo Domingo',
    'Santiago',
    'La Altagracia',
    'Puerto Plata',
    'Barahona',
    'Azua',
    'San Cristóbal',
    'La Vega',
    'San Juan',
    'Elías Piña',
    'Dajabón',
    'Monte Cristi',
  ];

  final List<String> tipos = [
    'Todos',
    'Parque Nacional',
    'Reserva Científica',
    'Refugio de Vida Silvestre',
    'Monumento Natural',
    'Reserva Biológica',
    'Vía Panorámica',
    'Corredor Ecológico',
  ];

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
          'descripcion': 'Sistema de manglares más importante del Caribe',
          'imagen': 'https://adamix.net/medioambiente/imagenes/haitises.jpg',
          'latitud': '19.0333',
          'longitud': '-69.5833',
          'tipo': 'Parque Nacional',
          'extension': '1600',
          'provincia': 'Samaná',
          'flora': 'Más de 700 especies de plantas',
          'fauna': 'Manatíes, tortugas, aves migratorias',
          'actividades': ['Senderismo', 'Observación de aves', 'Paseos en bote'],
          'horario': '8:00 AM - 5:00 PM',
          'telefono': '809-240-1234',
          'mejor_epoca': 'Diciembre a Abril',
        },
        {
          'id': '2',
          'nombre': 'Parque Nacional Jaragua',
          'descripcion': 'Área protegida más grande del Caribe',
          'imagen': 'https://adamix.net/medioambiente/imagenes/jaragua.jpg',
          'latitud': '17.8000',
          'longitud': '-71.4667',
          'tipo': 'Parque Nacional',
          'extension': '1374',
          'provincia': 'Barahona',
          'flora': 'Bosque seco subtropical',
          'fauna': 'Iguana rinoceronte, flamencos',
          'actividades': ['Fotografía', 'Caminatas', 'Observación de fauna'],
          'horario': '7:00 AM - 6:00 PM',
          'telefono': '809-524-5678',
          'mejor_epoca': 'Noviembre a Mayo',
        },
      ];
    }
  }

  List<Map<String, dynamic>> get filteredAreas {
    var filtered = areas;

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((area) {
        return area['nombre'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
               area['descripcion'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
               area['provincia'].toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filtrar por provincia
    if (_selectedProvincia != 'Todas') {
      filtered = filtered
          .where((area) => area['provincia'] == _selectedProvincia)
          .toList();
    }

    // Filtrar por tipo
    if (_selectedTipo != 'Todos') {
      filtered = filtered
          .where((area) => area['tipo'] == _selectedTipo)
          .toList();
    }

    return filtered;
  }

  void _verDetalleArea(Map<String, dynamic> area) {
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
                // Imagen
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: area['imagen'],
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
                      child: const Icon(Icons.image),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Badges
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      backgroundColor: Colors.green.shade100,
                      label: Text(area['tipo']),
                    ),
                    Chip(
                      backgroundColor: Colors.blue.shade100,
                      label: Text(area['provincia']),
                    ),
                    Chip(
                      backgroundColor: Colors.orange.shade100,
                      label: Text('${area['extension']} km²'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Nombre
                Text(
                  area['nombre'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                // Descripción
                Text(
                  area['descripcion'],
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 30),
                // Información detallada
                const Text(
                  'Información Detallada',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                _buildInfoRow('🏞️', 'Tipo', area['tipo']),
                _buildInfoRow('📍', 'Ubicación', area['provincia']),
                _buildInfoRow('📏', 'Extensión', '${area['extension']} km²'),
                _buildInfoRow('🌡️', 'Mejor época', area['mejor_epoca'] ?? 'Todo el año'),
                _buildInfoRow('⏰', 'Horario', area['horario'] ?? '8:00 AM - 5:00 PM'),
                _buildInfoRow('📞', 'Contacto', area['telefono'] ?? 'No disponible'),
                const SizedBox(height: 20),
                // Flora y Fauna
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              const Icon(Icons.forest, color: Colors.green),
                              const SizedBox(height: 8),
                              const Text(
                                'Flora',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                area['flora'] ?? 'Diversa',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              const Icon(Icons.pets, color: Colors.green),
                              const SizedBox(height: 8),
                              const Text(
                                'Fauna',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                area['fauna'] ?? 'Variada',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Actividades
                if (area['actividades'] != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Actividades Disponibles',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (area['actividades'] as List)
                            .map((actividad) => Chip(
                                  label: Text(actividad),
                                  backgroundColor: Colors.green.shade50,
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                const SizedBox(height: 30),
                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/mapa-areas',
                            arguments: area,
                          );
                        },
                        icon: const Icon(Icons.map),
                        label: const Text('Ver en Mapa'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Guardar como favorito
                        },
                        icon: const Icon(Icons.favorite_border),
                        label: const Text('Favorito'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String emoji, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Áreas Protegidas'),
        leading: Container(
          margin: const EdgeInsets.all(8),
          child: const CircleAvatar(
            backgroundImage: AssetImage('assets/avatars/estudiante6.jpg'),
          ),
        ),
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar áreas protegidas...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          // Filtros
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Filtro por provincia
                DropdownButton<String>(
                  value: _selectedProvincia,
                  items: provincias.map((String provincia) {
                    return DropdownMenuItem<String>(
                      value: provincia,
                      child: Text(provincia),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedProvincia = value!;
                    });
                  },
                ),
                const SizedBox(width: 10),
                // Filtro por tipo
                DropdownButton<String>(
                  value: _selectedTipo,
                  items: tipos.map((String tipo) {
                    return DropdownMenuItem<String>(
                      value: tipo,
                      child: Text(tipo),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTipo = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          // Contador
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text(
                  'Áreas encontradas: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${filteredAreas.length}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Lista de áreas
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredAreas.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 60, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No se encontraron áreas',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredAreas.length,
                        itemBuilder: (context, index) {
                          final area = filteredAreas[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 4,
                            child: InkWell(
                              onTap: () => _verDetalleArea(area),
                              borderRadius: BorderRadius.circular(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Imagen
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      bottomLeft: Radius.circular(12),
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl: area['imagen'],
                                      width: 120,
                                      height: 140,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        width: 120,
                                        height: 140,
                                        color: Colors.grey[200],
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        width: 120,
                                        height: 140,
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.image),
                                      ),
                                    ),
                                  ),
                                  // Información
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            area['nombre'],
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on,
                                                  size: 14, color: Colors.green),
                                              const SizedBox(width: 4),
                                              Text(
                                                area['provincia'],
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.category,
                                                  size: 14, color: Colors.green),
                                              const SizedBox(width: 4),
                                              Text(
                                                area['tipo'],
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.aspect_ratio,
                                                  size: 14, color: Colors.green),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${area['extension']} km²',
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            area['descripcion'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
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
    );
  }
}