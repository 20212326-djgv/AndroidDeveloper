import 'package:flutter/material.dart';
import 'package:medioambiente_rd/shared/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class NormativasScreen extends StatefulWidget {
  const NormativasScreen({super.key});

  @override
  State<NormativasScreen> createState() => _NormativasScreenState();
}

class _NormativasScreenState extends State<NormativasScreen> {
  List<Map<String, dynamic>> normativas = [];
  bool _isLoading = true;
  String _selectedCategoria = 'Todas';
  String _searchQuery = '';

  final List<String> categorias = [
    'Todas',
    'Leyes',
    'Decretos',
    'Resoluciones',
    'Normas Técnicas',
    'Convenios Internacionales',
  ];

  @override
  void initState() {
    super.initState();
    _cargarNormativas();
  }

  Future<void> _cargarNormativas() async {
    try {
      final api = ApiService();
      final response = await api.get('normativas');
      
      if (response['exito'] == true) {
        setState(() {
          normativas = List<Map<String, dynamic>>.from(response['datos']);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Datos de ejemplo
      normativas = [
        {
          'id': '1',
          'numero': 'Ley 64-00',
          'titulo': 'Ley General sobre Medio Ambiente y Recursos Naturales',
          'descripcion': 'Ley marco que establece los principios y normas para la protección del medio ambiente',
          'categoria': 'Leyes',
          'fecha_emision': '2000-08-18',
          'vigente': true,
          'archivo_url': 'https://medioambiente.gob.do/leyes/64-00.pdf',
          'articulos': '184 artículos',
          'temas': ['Marco legal', 'Principios', 'Competencias']
        },
        {
          'id': '2',
          'numero': 'Decreto 207-21',
          'titulo': 'Reglamento de Evaluación de Impacto Ambiental',
          'descripcion': 'Establece el procedimiento para la evaluación de impactos ambientales',
          'categoria': 'Decretos',
          'fecha_emision': '2021-05-10',
          'vigente': true,
          'archivo_url': 'https://medioambiente.gob.do/decretos/207-21.pdf',
          'articulos': '45 artículos',
          'temas': ['EIA', 'Permisos', 'Procedimientos']
        },
      ];
    }
  }

  List<Map<String, dynamic>> get filteredNormativas {
    var filtered = normativas;

    // Filtrar por búsqueda
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((normativa) {
        return normativa['titulo'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
               normativa['numero'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
               normativa['descripcion'].toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filtrar por categoría
    if (_selectedCategoria != 'Todas') {
      filtered = filtered
          .where((normativa) => normativa['categoria'] == _selectedCategoria)
          .toList();
    }

    return filtered;
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  void _verDetalleNormativa(Map<String, dynamic> normativa) {
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
                        'Normativa Ambiental',
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
                // Badges
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Chip(
                      label: Text(normativa['categoria']),
                      backgroundColor: Colors.green.shade100,
                    ),
                    Chip(
                      label: Text(normativa['vigente'] ? 'Vigente' : 'Derogada'),
                      backgroundColor: normativa['vigente']
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                    ),
                    if (normativa['articulos'] != null)
                      Chip(
                        label: Text(normativa['articulos']),
                        backgroundColor: Colors.blue.shade100,
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                // Título
                Text(
                  normativa['numero'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  normativa['titulo'],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                // Fecha
                Row(
                  children: [
                    const Icon(Icons.date_range, size: 16, color: Colors.grey),
                    const SizedBox(width: 5),
                    Text(
                      'Fecha de emisión: ${_formatDate(normativa['fecha_emision'])}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Descripción
                const Text(
                  'Descripción:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  normativa['descripcion'],
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 20),
                // Temas
                if (normativa['temas'] != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Temas principales:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (normativa['temas'] as List)
                            .map((tema) => Chip(
                                  label: Text(tema),
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
                        onPressed: () async {
                          if (normativa['archivo_url'] != null) {
                            final url = Uri.parse(normativa['archivo_url']);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            }
                          }
                        },
                        icon: const Icon(Icons.file_download),
                        label: const Text('Ver PDF'),
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
                          _compartirNormativa(normativa);
                        },
                        icon: const Icon(Icons.share),
                        label: const Text('Compartir'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
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

  void _compartirNormativa(Map<String, dynamic> normativa) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Compartir Normativa'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copiar enlace'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enlace copiado')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Enviar por email'),
              onTap: () {
                Navigator.pop(context);
                // Lógica para compartir por email
              },
            ),
            ListTile(
              leading: const Icon(Icons.message),
              title: const Text('Compartir por mensaje'),
              onTap: () {
                Navigator.pop(context);
                // Lógica para compartir por mensaje
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Normativas Ambientales'),
        leading: Container(
          margin: const EdgeInsets.all(8),
          child: const CircleAvatar(
            backgroundImage: AssetImage('assets/avatars/estudiante4.jpg'),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: _NormativaSearchDelegate(normativas),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Categorías
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categorias.length,
                    itemBuilder: (context, index) {
                      final categoria = categorias[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(categoria),
                          selected: _selectedCategoria == categoria,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategoria = selected ? categoria : 'Todas';
                            });
                          },
                          selectedColor: Colors.green,
                          labelStyle: TextStyle(
                            color: _selectedCategoria == categoria
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                // Estadísticas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard('Total', '${normativas.length}'),
                    _buildStatCard('Leyes', '12'),
                    _buildStatCard('Vigentes', '45'),
                  ],
                ),
              ],
            ),
          ),
          // Lista de normativas
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredNormativas.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.gavel, size: 60, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No hay normativas disponibles',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredNormativas.length,
                        itemBuilder: (context, index) {
                          final normativa = filteredNormativas[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 3,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: Colors.green.shade100,
                                child: const Icon(Icons.gavel, color: Colors.green),
                              ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    normativa['numero'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  Text(
                                    normativa['titulo'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Text(
                                    normativa['descripcion'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Chip(
                                        label: Text(normativa['categoria']),
                                        backgroundColor: Colors.green.shade50,
                                        labelStyle:
                                            const TextStyle(fontSize: 12),
                                      ),
                                      const SizedBox(width: 8),
                                      Chip(
                                        label: Text(
                                            normativa['vigente'] ? 'Vigente' : 'Derogada'),
                                        backgroundColor: normativa['vigente']
                                            ? Colors.green.shade50
                                            : Colors.red.shade50,
                                        labelStyle:
                                            const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () => _verDetalleNormativa(normativa),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _cargarNormativas,
        backgroundColor: Colors.green,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
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

class _NormativaSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> normativas;

  _NormativaSearchDelegate(this.normativas);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final results = normativas.where((normativa) {
      return normativa['titulo'].toLowerCase().contains(query.toLowerCase()) ||
             normativa['numero'].toLowerCase().contains(query.toLowerCase()) ||
             normativa['descripcion'].toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final normativa = results[index];
        return ListTile(
          leading: const Icon(Icons.gavel, color: Colors.green),
          title: Text(normativa['titulo']),
          subtitle: Text(normativa['numero']),
          onTap: () {
            // Mostrar detalle de la normativa
            close(context, normativa);
          },
        );
      },
    );
  }
}