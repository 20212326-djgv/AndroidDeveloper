import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:medioambiente_rd/shared/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

class EquipoScreen extends StatefulWidget {
  const EquipoScreen({super.key});

  @override
  State<EquipoScreen> createState() => _EquipoScreenState();
}

class _EquipoScreenState extends State<EquipoScreen> {
  List<Map<String, dynamic>> equipo = [];
  bool _isLoading = true;
  String _selectedDepartamento = 'Todos';
  final Map<String, List<Map<String, dynamic>>> _equipoPorDepartamento = {};

  @override
  void initState() {
    super.initState();
    _cargarEquipo();
  }

  Future<void> _cargarEquipo() async {
    try {
      final api = ApiService();
      final response = await api.get('equipo');
      
      if (response['exito'] == true) {
        final datos = List<Map<String, dynamic>>.from(response['datos']);
        
        // Organizar por departamento
        final Map<String, List<Map<String, dynamic>>> equiposPorDepto = {};
        
        for (var persona in datos) {
          final depto = persona['departamento'] ?? 'Sin Departamento';
          if (!equiposPorDepto.containsKey(depto)) {
            equiposPorDepto[depto] = [];
          }
          equiposPorDepto[depto]!.add(persona);
        }
        
        setState(() {
          equipo = datos;
          _equipoPorDepartamento.addAll(equiposPorDepto);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Datos de ejemplo
      final datosEjemplo = [
        {
          'id': '1',
          'nombre': 'Miguel Ceara Hatton',
          'cargo': 'Ministro',
          'departamento': 'Dirección',
          'email': 'ministro@medioambiente.gob.do',
          'telefono': '809-567-4301',
          'foto': 'https://adamix.net/medioambiente/imagenes/ministro.jpg',
          'biografia': 'Economista y político dominicano...',
          'redes_sociales': {
            'twitter': '@mceara',
            'linkedin': 'mceara'
          }
        },
        {
          'id': '2',
          'nombre': 'María Alicia Urbaneja',
          'cargo': 'Viceministra',
          'departamento': 'Dirección',
          'email': 'vice@medioambiente.gob.do',
          'telefono': '809-567-4302',
          'foto': 'https://adamix.net/medioambiente/imagenes/viceministra.jpg',
          'biografia': 'Especialista en gestión ambiental...',
          'redes_sociales': {
            'twitter': '@maliciaurban',
            'linkedin': 'maliciaurban'
          }
        },
      ];
      
      final Map<String, List<Map<String, dynamic>>> equiposPorDepto = {};
      for (var persona in datosEjemplo) {
        final depto = persona['departamento'] ?? 'Sin Departamento';
        if (!equiposPorDepto.containsKey(depto)) {
          equiposPorDepto[depto] = [];
        }
        equiposPorDepto[depto]!.add(persona);
      }
      
      setState(() {
        equipo = datosEjemplo;
        _equipoPorDepartamento.addAll(equiposPorDepto);
      });
    }
  }

  List<String> get departamentos {
    final deptos = _equipoPorDepartamento.keys.toList();
    deptos.insert(0, 'Todos');
    return deptos;
  }

  List<Map<String, dynamic>> get filteredEquipo {
    if (_selectedDepartamento == 'Todos') return equipo;
    return _equipoPorDepartamento[_selectedDepartamento] ?? [];
  }

  void _mostrarDetallePersona(Map<String, dynamic> persona) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 1.0,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Foto y nombre
                CircleAvatar(
                  radius: 60,
                  backgroundImage: CachedNetworkImageProvider(
                    persona['foto'] ?? '',
                  ),
                  backgroundColor: Colors.grey[200],
                  child: persona['foto'] == null
                      ? const Icon(Icons.person, size: 60, color: Colors.grey)
                      : null,
                ),
                const SizedBox(height: 20),
                Text(
                  persona['nombre'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Chip(
                  label: Text(persona['cargo']),
                  backgroundColor: Colors.green.shade100,
                ),
                const SizedBox(height: 5),
                Text(
                  persona['departamento'],
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 25),
                // Información de contacto
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Información de Contacto',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.email, color: Colors.green),
                          title: const Text('Email'),
                          subtitle: Text(persona['email'] ?? 'No disponible'),
                          onTap: persona['email'] != null
                              ? () async {
                                  final url = Uri.parse(
                                      'mailto:${persona['email']}');
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  }
                                }
                              : null,
                        ),
                        ListTile(
                          leading:
                              const Icon(Icons.phone, color: Colors.green),
                          title: const Text('Teléfono'),
                          subtitle: Text(persona['telefono'] ?? 'No disponible'),
                          onTap: persona['telefono'] != null
                              ? () async {
                                  final url = Uri.parse(
                                      'tel:${persona['telefono']}');
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  }
                                }
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Biografía
                if (persona['biografia'] != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Biografía',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        persona['biografia'],
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                // Redes sociales
                if (persona['redes_sociales'] != null)
                  Column(
                    children: [
                      const Text(
                        'Redes Sociales',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (persona['redes_sociales']['twitter'] != null)
                            IconButton(
                              onPressed: () async {
                                final url = Uri.parse(
                                    'https://twitter.com/${persona['redes_sociales']['twitter']}');
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                }
                              },
                              icon: Image.asset(
                                'assets/icons/twitter.png',
                                width: 30,
                                height: 30,
                              ),
                            ),
                          if (persona['redes_sociales']['linkedin'] != null)
                            IconButton(
                              onPressed: () async {
                                final url = Uri.parse(
                                    'https://linkedin.com/in/${persona['redes_sociales']['linkedin']}');
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                }
                              },
                              icon: Image.asset(
                                'assets/icons/linkedin.png',
                                width: 30,
                                height: 30,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                const SizedBox(height: 30),
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
        title: const Text('Equipo del Ministerio'),
        leading: Container(
          margin: const EdgeInsets.all(8),
          child: const CircleAvatar(
            backgroundImage: AssetImage('assets/avatars/estudiante2.jpg'),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filtro por departamento
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              value: _selectedDepartamento,
              decoration: InputDecoration(
                labelText: 'Filtrar por departamento',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: const Icon(Icons.filter_list),
              ),
              items: departamentos.map((String depto) {
                return DropdownMenuItem<String>(
                  value: depto,
                  child: Text(depto),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDepartamento = value!;
                });
              },
            ),
          ),
          // Estadísticas
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      'Total Miembros',
                      '${equipo.length}',
                      Icons.people,
                    ),
                    _buildStatCard(
                      'Departamentos',
                      '${departamentos.length - 1}',
                      Icons.business,
                    ),
                    _buildStatCard(
                      'Dirección',
                      '2',
                      Icons.leaderboard,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Lista del equipo
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredEquipo.isEmpty
                    ? const Center(
                        child: Text('No hay miembros en este departamento'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredEquipo.length,
                        itemBuilder: (context, index) {
                          final persona = filteredEquipo[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 3,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundImage: CachedNetworkImageProvider(
                                  persona['foto'] ?? '',
                                ),
                                backgroundColor: Colors.grey[200],
                                child: persona['foto'] == null
                                    ? const Icon(Icons.person,
                                        size: 30, color: Colors.grey)
                                    : null,
                              ),
                              title: Text(
                                persona['nombre'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(persona['cargo']),
                                  Text(
                                    persona['departamento'],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios),
                              onTap: () => _mostrarDetallePersona(persona),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mostrarOrganigrama();
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.account_tree),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.green),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  void _mostrarOrganigrama() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Organigrama del Ministerio'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nivel 1: Ministro
                _buildOrganigramaNivel(
                  'Ministro',
                  'Miguel Ceara Hatton',
                  Colors.green,
                ),
                const SizedBox(height: 20),
                // Nivel 2: Viceministros
                const Text(
                  'Viceministros:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildOrganigramaNivel(
                  'Viceministra',
                  'María Alicia Urbaneja',
                  Colors.green.shade300,
                  nivel: 2,
                ),
                _buildOrganigramaNivel(
                  'Viceministro',
                  'Federico Franco',
                  Colors.green.shade300,
                  nivel: 2,
                ),
                const SizedBox(height: 20),
                // Nivel 3: Directores
                const Text(
                  'Directores de Departamento:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...List.generate(
                  5,
                  (index) => _buildOrganigramaNivel(
                    'Director ${index + 1}',
                    'Nombre Director',
                    Colors.green.shade100,
                    nivel: 3,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrganigramaNivel(
    String cargo,
    String nombre,
    Color color, {
    int nivel = 1,
  }) {
    return Container(
      margin: EdgeInsets.only(left: (nivel - 1) * 20.0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            cargo,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: nivel == 1 ? 16 : 14,
            ),
          ),
          Text(
            nombre,
            style: TextStyle(
              fontSize: nivel == 1 ? 14 : 12,
            ),
          ),
        ],
      ),
    );
  }
}