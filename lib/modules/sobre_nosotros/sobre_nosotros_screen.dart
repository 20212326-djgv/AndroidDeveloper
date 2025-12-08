import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

class SobreNosotrosScreen extends StatefulWidget {
  const SobreNosotrosScreen({super.key});

  @override
  State<SobreNosotrosScreen> createState() => _SobreNosotrosScreenState();
}

class _SobreNosotrosScreenState extends State<SobreNosotrosScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/ministerio.mp4')
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sobre Nosotros'),
        leading: Container(
          margin: const EdgeInsets.all(8),
          child: const CircleAvatar(
            backgroundImage: AssetImage('assets/avatars/estudiante2.jpg'),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Video
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    VideoPlayer(_controller),
                    Positioned(
                      child: IconButton(
                        icon: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          size: 50,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          setState(() {
                            if (_controller.value.isPlaying) {
                              _controller.pause();
                            } else {
                              _controller.play();
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Historia
              const Text(
                'Nuestra Historia',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'El Ministerio de Medio Ambiente y Recursos Naturales fue creado en el año 2000 '
                'con el objetivo de proteger y conservar los recursos naturales de la República Dominicana. '
                'Desde entonces, hemos trabajado incansablemente para implementar políticas ambientales '
                'que promuevan el desarrollo sostenible y la conservación de nuestra biodiversidad.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 30),

              // Misión y Visión
              Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const Icon(Icons.flag, size: 50, color: Colors.green),
                            const SizedBox(height: 10),
                            const Text(
                              'Misión',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Proteger, conservar y restaurar los recursos naturales '
                              'para garantizar el desarrollo sostenible.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const Icon(Icons.visibility, size: 50, color: Colors.green),
                            const SizedBox(height: 10),
                            const Text(
                              'Visión',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Ser líder en la gestión ambiental del Caribe, '
                              'promoviendo una cultura de conservación.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Valores
              const Text(
                'Nuestros Valores',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildValueChip('Sostenibilidad', Icons.eco),
                  _buildValueChip('Transparencia', Icons.visibility),
                  _buildValueChip('Compromiso', Icons.handshake),
                  _buildValueChip('Innovación', Icons.lightbulb),
                  _buildValueChip('Equidad', Icons.balance),
                  _buildValueChip('Excelencia', Icons.star),
                ],
              ),
              const SizedBox(height: 30),

              // Contacto
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Contáctanos',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      ListTile(
                        leading: const Icon(Icons.location_on, color: Colors.green),
                        title: const Text('Dirección'),
                        subtitle: const Text('Av. Cayetano Germosén, Santo Domingo'),
                        onTap: () async {
                          const url = 'https://maps.app.goo.gl/...';
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url));
                          }
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.phone, color: Colors.green),
                        title: const Text('Teléfono'),
                        subtitle: const Text('(809) 567-4300'),
                        onTap: () async {
                          const url = 'tel:8095674300';
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url));
                          }
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.email, color: Colors.green),
                        title: const Text('Email'),
                        subtitle: const Text('info@medioambiente.gob.do'),
                        onTap: () async {
                          const url = 'mailto:info@medioambiente.gob.do';
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url));
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValueChip(String text, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 20),
      label: Text(text),
      backgroundColor: Colors.green.shade50,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}