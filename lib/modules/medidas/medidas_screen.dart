import 'package:flutter/material.dart';
import 'package:medioambiente_rd/shared/services/api_service.dart';

class MedidasScreen extends StatefulWidget {
  const MedidasScreen({super.key});

  @override
  State<MedidasScreen> createState() => _MedidasScreenState();
}

class _MedidasScreenState extends State<MedidasScreen> {
  List<Map<String, dynamic>> medidas = [];
  bool _isLoading = true;
  String _selectedCategoria = 'Todas';
  final List<String> categorias = [
    'Todas',
    'Agua',
    'Energía',
    'Residuos',
    'Transporte',
    'Consumo',
    'Jardinería',
  ];

  @override
  void initState() {
    super.initState();
    _cargarMedidas();
  }

  Future<void> _cargarMedidas() async {
    try {
      final api = ApiService();
      final response = await api.get('medidas');
      
      if (response['exito'] == true) {
        setState(() {
          medidas = List<Map<String, dynamic>>.from(response['datos']);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Datos de ejemplo
      medidas = [
        {
          'id': '1',
          'titulo': 'Ahorra agua en casa',
          'descripcion': 'Medidas simples para reducir el consumo de agua',
          'categoria': 'Agua',
          'contenido': '''
• Cierra el grifo mientras te cepillas los dientes
• Revisa y repara fugas de agua
• Instala aireadores en grifos
• Riega plantas por la mañana o tarde
• Usa lavadora y lavavajillas con carga completa
          ''',
          'impacto': 'Alto',
          'dificultad': 'Baja',
          'ahorro_anual': '30,000 litros',
        },
        {
          'id': '2',
          'titulo': 'Reduce el consumo de energía',
          'descripcion': 'Consejos para ahorrar electricidad',
          'categoria': 'Energía',
          'contenido': '''
• Usa bombillas LED
• Desconecta electrodomésticos en standby
• Aprovecha la luz natural
• Usa aire acondicionado a 24°C
• Seca ropa al aire libre
          ''',
          'impacto': 'Alto',
          'dificultad': 'Media',
          'ahorro_anual': 'RD$ 5,000',
        },
      ];
    }
  }

  List<Map<String, dynamic>> get filteredMedidas {
    if (_selectedCategoria == 'Todas') return medidas;
    return medidas
        .where((medida) => medida['categoria'] == _selectedCategoria)
        .toList();
  }

  Color _getImpactColor(String impacto) {
    switch (impacto.toLowerCase()) {
      case 'alto':
        return Colors.green;
      case 'medio':
        return Colors.orange;
      case 'bajo':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _verDetalleMedida(Map<String, dynamic> medida) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(medida['titulo']),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Chip(
                label: Text(medida['categoria']),
                backgroundColor: Colors.green.shade100,
              ),
              const SizedBox(height: 16),
              Text(
                medida['descripcion'],
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                'Cómo implementar:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                medida['contenido'],
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildMetricCard('Impacto', medida['impacto'],
                      _getImpactColor(medida['impacto'])),
                  const SizedBox(width: 10),
                  _buildMetricCard('Dificultad', medida['dificultad'],
                      Colors.orange),
                  const SizedBox(width: 10),
                  _buildMetricCard('Ahorro Anual', medida['ahorro_anual'],
                      Colors.blue),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              _marcarComoCompletada(medida);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Marcar como Completada'),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _marcarComoCompletada(Map<String, dynamic> medida) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¡Felicidades!'),
        content: Text(
          'Has completado la medida: "${medida['titulo']}"\n'
          'Tu acción ayuda al medio ambiente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medidas Ambientales'),
        leading: Container(
          margin: const EdgeInsets.all(8),
          child: const CircleAvatar(
            backgroundImage: AssetImage('assets/avatars/estudiante1.jpg'),
          ),
        ),
      ),
      body: Column(
        children: [
          // Banner motivacional
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.green.shade50,
            child: const Column(
              children: [
                Icon(Icons.eco, size: 40, color: Colors.green),
                SizedBox(height: 10),
                Text(
                  'Pequeñas acciones, grandes cambios',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Cada medida que implementas ayuda a proteger nuestro planeta',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Categorías
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categorias.length,
              itemBuilder: (context, index) {
                final categoria = categorias[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8, top: 8),
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
          // Estadísticas
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Medidas', '${medidas.length}'),
                _buildStat('Completadas', '0'),
                _buildStat('Impacto', 'Alto'),
              ],
            ),
          ),
          // Lista de medidas
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredMedidas.isEmpty
                    ? const Center(
                        child: Text('No hay medidas disponibles'),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredMedidas.length,
                        itemBuilder: (context, index) {
                          final medida = filteredMedidas[index];
                         