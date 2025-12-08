import 'package:flutter/material.dart';
import 'package:medioambiente_rd/modules/acerca_de/acerca_de_screen.dart';
import 'package:medioambiente_rd/modules/areas_protegidas/areas_screen.dart';
import 'package:medioambiente_rd/modules/auth/login_screen.dart';
import 'package:medioambiente_rd/modules/equipo/equipo_screen.dart';
import 'package:medioambiente_rd/modules/inicio/inicio_screen.dart';
import 'package:medioambiente_rd/modules/mapa_areas/mapa_areas_screen.dart';
import 'package:medioambiente_rd/modules/medidas/medidas_screen.dart';
import 'package:medioambiente_rd/modules/noticias/noticias_screen.dart';
import 'package:medioambiente_rd/modules/reportes/mis_reportes_screen.dart';
import 'package:medioambiente_rd/modules/reportes/reportar_screen.dart';
import 'package:medioambiente_rd/modules/servicios/servicios_screen.dart';
import 'package:medioambiente_rd/modules/sobre_nosotros/sobre_nosotros_screen.dart';
import 'package:medioambiente_rd/modules/videos/videos_screen.dart';
import 'package:medioambiente_rd/modules/voluntariado/voluntariado_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/': (context) => const InicioScreen(),
  '/login': (context) => const LoginScreen(),
  '/inicio': (context) => const InicioScreen(),
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
};