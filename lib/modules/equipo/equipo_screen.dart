import 'package:flutter/material.dart';
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
  late Map<String, List<Map<String, dynamic>>> _equipoPorDepartamento;

  @override
  void initState() {
    super.initState();
    _equipoPorDepartamento = {}; // Inicializar aquí
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
          final depto = persona['departamento']?.toString() ?? 'Sin Departamento';
          if (!equiposPorDepto.containsKey(depto)) {
            equiposPorDepto[depto] = [];
          }
          equiposPorDepto[depto]!.add(persona);
        }
        
        setState(() {
          equipo = datos;
          _equipoPorDepartamento = equiposPorDepto; // Asignar directamente
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
          'biografia': 'Economista y político dominicano con amplia experiencia en políticas ambientales.',
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
          'biografia': 'Especialista en gestión ambiental con más de 15 años de experiencia.',
          'redes_sociales': {
            'twitter': '@maliciaurban',
            'linkedin': 'maliciaurban'
          }
        },
      ];
      
      final Map<String, List<Map<String, dynamic>>> equiposPorDepto = {};
      for (var persona in datosEjemplo) {
        final depto = persona['departamento']?.toString() ?? 'Sin Departamento';
        if (!equiposPorDepto.containsKey(depto)) {
          equiposPorDepto[depto] = [];
        }
        equiposPorDepto[depto]!.add(persona);
      }
      
      setState(() {
        equipo = datosEjemplo;
        _equipoPorDepartamento = equiposPorDepto; // Asignar directamente
        _isLoading = false;
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
                  backgroundColor: Colors.grey[200],
                  child: persona['foto'] != null && persona['foto'].toString().isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            persona['foto'].toString(),
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey,
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const CircularProgressIndicator();
                            },
                          ),
                        )
                      : const Icon(Icons.person, size: 60, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Text(
                  persona['nombre']?.toString() ?? 'Nombre no disponible',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Chip(
                  label: Text(persona['cargo']?.toString() ?? 'Cargo no disponible'),
                  backgroundColor: Colors.green.shade100,
                ),
                const SizedBox(height: 5),
                Text(
                  persona['departamento']?.toString() ?? 'Sin departamento',
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
                          subtitle: Text(persona['email']?.toString() ?? 'No disponible'),
                          onTap: persona['email'] != null && persona['email'].toString().isNotEmpty
                              ? () async {
                                  final url = Uri.parse('mailto:${persona['email']}');
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  }
                                }
                              : null,
                        ),
                        ListTile(
                          leading: const Icon(Icons.phone, color: Colors.green),
                          title: const Text('Teléfono'),
                          subtitle: Text(persona['telefono']?.toString() ?? 'No disponible'),
                          onTap: persona['telefono'] != null && persona['telefono'].toString().isNotEmpty
                              ? () async {
                                  final url = Uri.parse('tel:${persona['telefono']}');
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
                if (persona['biografia'] != null && persona['biografia'].toString().isNotEmpty)
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
                        persona['biografia'].toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                
                const SizedBox(height: 20),
                
                // Redes sociales
                if (persona['redes_sociales'] != null && persona['redes_sociales'] is Map)
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
                          if ((persona['redes_sociales'] as Map)['linkedin'] != null)
                            IconButton(
                              onPressed: () async {
                                final linkedin = (persona['redes_sociales'] as Map)['linkedin'].toString();
                                final url = Uri.parse('https://linkedin.com/in/$linkedin');
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                }
                              },
                              icon: const Icon(Icons.linked_camera, size: 30, color: Colors.blue),
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
            backgroundColor: Colors.green,
            child: Icon(Icons.people, color: Colors.white),
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
                filled: true,
                fillColor: Colors.grey[50],
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
                    _buildStatCard('Total Miembros', '${equipo.length}', Icons.people),
                    _buildStatCard('Departamentos', '${departamentos.length - 1}', Icons.business),
                    _buildStatCard('Dirección', '2', Icons.leaderboard),
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 60, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No hay miembros en este departamento',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
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
                                backgroundColor: Colors.green.shade100,
                                backgroundImage: persona['foto'] != null && persona['foto'].toString().isNotEmpty
                                    ? NetworkImage(persona['foto'].toString())
                                    : null,
                                child: persona['foto'] == null || persona['foto'].toString().isEmpty
                                    ? const Icon(Icons.person, size: 30, color: Colors.green)
                                    : null,
                              ),
                              title: Text(
                                persona['nombre']?.toString() ?? 'Sin nombre',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(persona['cargo']?.toString() ?? 'Sin cargo'),
                                  Text(
                                    persona['departamento']?.toString() ?? 'Sin departamento',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.green),
                              onTap: () => _mostrarDetallePersona(persona),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarOrganigrama,
        backgroundColor: Colors.green,
        child: const Icon(Icons.account_tree, color: Colors.white),
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
                  3,
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