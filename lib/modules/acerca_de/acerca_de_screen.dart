import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AcercaDeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> desarrolladores = [
    {
      'nombre': 'Juan Pérez',
      'matricula': '2021-1234',
      'telefono': '809-123-4567',
      'telegram': '@juanperez',
      'foto': 'assets/avatars/estudiante1.jpg',
      'rol': 'Desarrollador Flutter',
    },
    {
      'nombre': 'María García',
      'matricula': '2021-5678',
      'telefono': '809-987-6543',
      'telegram': '@mariagarcia',
      'foto': 'assets/avatars/estudiante2.jpg',
      'rol': 'Diseñadora UI/UX',
    },
    {
      'nombre': 'Carlos Rodríguez',
      'matricula': '2021-9012',
      'telefono': '829-555-1234',
      'telegram': '@carlosrod',
      'foto': 'assets/avatars/estudiante3.jpg',
      'rol': 'Backend Developer',
    },
    // Agrega más integrantes según tu grupo
  ];

  AcercaDeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de'),
        leading: Container(
          margin: const EdgeInsets.all(8),
          child: const CircleAvatar(
            backgroundImage: AssetImage('assets/avatars/estudiante7.jpg'),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assets/logo_app.jpg'), // Tu logo combinado
            ),
            const SizedBox(height: 20),
            const Text(
              'Ministerio de Medio Ambiente RD',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Versión 1.0.0',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            const Text(
              'Desarrollado por:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...desarrolladores.map((dev) => _buildDesarrolladorCard(dev)),
            const SizedBox(height: 30),
            const Text(
              'ITLA - Instituto Tecnológico de las Américas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Tercer Trimestre 2025',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesarrolladorCard(Map<String, dynamic> dev) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(dev['foto']),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dev['nombre'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(dev['rol']),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.phone, size: 20),
                        onPressed: () async {
                          final url = 'tel:${dev['telefono']}';
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url));
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.telegram, size: 20),
                        onPressed: () async {
                          final url = 'https://t.me/${dev['telegram'].substring(1)}';
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url));
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                const Text(
                  'Matrícula',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  dev['matricula'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}