import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medioambiente_rd/shared/services/auth_service.dart';
import 'package:medioambiente_rd/modules/auth/login_screen.dart';
import 'package:medioambiente_rd/modules/inicio/inicio_screen.dart';
import 'package:medioambiente_rd/modules/sobre_nosotros/sobre_nosotros_screen.dart';
import 'package:medioambiente_rd/modules/acerca_de/acerca_de_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: MaterialApp(
        title: 'Ministerio de Medio Ambiente RD',
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            centerTitle: true,
          ),
        ),
        home: Consumer<AuthService>(
          builder: (context, authService, child) {
            return authService.isLoggedIn 
                ? const InicioScreen()
                : const LoginScreen();
          },
        ),
        // Rutas básicas
        routes: {
          '/login': (context) => const LoginScreen(),
          '/inicio': (context) => const InicioScreen(),
          '/sobre-nosotros': (context) => const SobreNosotrosScreen(),
          '/acerca-de': (context) => const AcercaDeScreen(),
          // Agrega más rutas aquí
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}