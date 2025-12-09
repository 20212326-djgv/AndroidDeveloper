import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import 'package:medioambiente_rd/shared/services/auth_service.dart';
import 'package:medioambiente_rd/modules/auth/login_screen.dart';
import 'package:medioambiente_rd/modules/auth/cambiar_clave_screen.dart';
import 'package:medioambiente_rd/modules/inicio/inicio_screen.dart';
import 'package:medioambiente_rd/modules/sobre_nosotros/sobre_nosotros_screen.dart';
import 'package:medioambiente_rd/modules/servicios/servicios_screen.dart';
import 'package:medioambiente_rd/modules/noticias/noticias_screen.dart';
import 'package:medioambiente_rd/modules/videos/videos_screen.dart';
import 'package:medioambiente_rd/modules/areas_protegidas/areas_screen.dart';
import 'package:medioambiente_rd/modules/mapa_areas/mapa_areas_screen.dart';
import 'package:medioambiente_rd/modules/medidas/medidas_screen.dart';
import 'package:medioambiente_rd/modules/equipo/equipo_screen.dart';
import 'package:medioambiente_rd/modules/voluntariado/voluntariado_screen.dart';
import 'package:medioambiente_rd/modules/acerca_de/acerca_de_screen.dart';
import 'package:medioambiente_rd/modules/reportes/reportar_screen.dart';
import 'package:medioambiente_rd/modules/reportes/mis_reportes_screen.dart';
import 'package:medioambiente_rd/modules/map_reportes/mapa_reportes_screen.dart';
import 'package:medioambiente_rd/modules/normativas/normativas_screen.dart';

// Screen placeholder para módulos no implementados
class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: Container(
          margin: const EdgeInsets.all(8),
          child: const CircleAvatar(
            backgroundImage: AssetImage('assets/avatars/estudiante1.jpg'),
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Módulo en desarrollo',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// Definición de rutas
final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) {
    // OPCIÓN 1: Usar Consumer en lugar de context.read para seguridad
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        return authService.isLoggedIn 
            ? const InicioScreen()
            : const LoginScreen();
      },
    );
    
    // OPCIÓN 2: Si prefieres context.read, usar después de WidgetsBinding
    /*
    final authService = Provider.of<AuthService>(context, listen: false);
    return authService.isLoggedIn 
        ? const InicioScreen()
        : const LoginScreen();
    */
  },
  
  '/login': (context) => const LoginScreen(),
  '/inicio': (context) => const InicioScreen(),
  '/cambiar-clave': (context) => const CambiarClaveScreen(),
  '/sobre-nosotros': (context) => const SobreNosotrosScreen(),
  '/servicios': (context) => const ServiciosScreen(),
  '/noticias': (context) => const NoticiasScreen(),
  '/videos': (context) => const VideosScreen(),
  '/areas-protegidas': (context) => const AreasProtegidasScreen(),
  '/mapa-areas': (context) => const MapaAreasScreen(),
  '/medidas': (context) => const MedidasScreen(),
  '/equipo': (context) => const EquipoScreen(),
  '/voluntariado': (context) => const VoluntariadoScreen(),
  '/acerca-de': (context) => const AcercaDeScreen(),
  '/reportar': (context) => const ReportarScreen(),
  '/mis-reportes': (context) => const MisReportesScreen(),
  '/mapa-reportes': (context) => const MapaReportesScreen(),
  '/normativas': (context) => const NormativasScreen(),
};