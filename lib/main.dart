import 'package:flutter/material.dart';
import 'package:medioambiente_rd/config/routes.dart';
import 'package:medioambiente_rd/config/theme.dart';
import 'package:medioambiente_rd/shared/services/auth_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'Ministerio de Medio Ambiente RD',
        theme: appTheme,
        initialRoute: '/',
        routes: appRoutes,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}