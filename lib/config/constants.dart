class AppConstants {
  // API Endpoints
  static const String apiBaseUrl = 'https://adamix.net/medioambiente/';
  
  // Rutas de API
  static const String apiNoticias = 'noticias';
  static const String apiVideos = 'videos';
  static const String apiAreas = 'areas-protegidas';
  static const String apiServicios = 'servicios';
  static const String apiNormativas = 'normativas';
  static const String apiEquipo = 'equipo';
  static const String apiVoluntariado = 'voluntariado';
  static const String apiReportar = 'reportar';
  static const String apiLogin = 'login';
  static const String apiCambiarClave = 'cambiar-clave';
  
  // Base de datos
  static const String dbName = 'medioambiente.db';
  static const int dbVersion = 1;
  
  // Shared Preferences keys
  static const String prefToken = 'token';
  static const String prefUserEmail = 'user_email';
  static const String prefIsLoggedIn = 'is_logged_in';
  
  // Otros
  static const String appName = 'Medio Ambiente RD';
  static const String appVersion = '1.0.0';
}