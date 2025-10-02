import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'colors.dart';
import 'home.dart';
import 'login.dart';
import 'supplemental/cut_corners_border.dart';

// REVERTIR: ShrineApp vuelve a ser StatelessWidget y apunta directamente a HomePage
class ShrineApp extends StatelessWidget {
  const ShrineApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shrine',
      initialRoute: '/login',
      routes: {
        '/login': (BuildContext context) => const LoginPage(),
        // REVERTIR: La ruta principal ahora va directamente a HomePage
        '/': (BuildContext context) => const HomePage(), 
      },
      debugShowCheckedModeBanner: false, 
      theme: _kShrineTheme,
    );
  }
}

// Configuración del tema (corregida para usar los colores originales de Shrine)
final ThemeData _kShrineTheme = _buildShrineTheme();

ThemeData _buildShrineTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: kShrinePink100, // Color primario (rosa claro)
      onPrimary: kShrineBrown900,
      secondary: kShrineBrown900, // Color secundario (marrón oscuro)
      onSecondary: kShrineBackgroundWhite, // Color sobre secundario (blanco)
      error: kShrineErrorRed,
      surface: kShrineSurfaceWhite,
      background: kShrineBackgroundWhite,
    ),
    textTheme: _buildShrineTextTheme(base.textTheme),
    textSelectionTheme: const TextSelectionThemeData(
      selectionColor: kShrinePink100,
    ),
    appBarTheme: const AppBarTheme(
      foregroundColor: kShrineBrown900,
      backgroundColor: kShrinePink100,
      elevation: 0.0,
      systemOverlayStyle: SystemUiOverlayStyle.dark, 
    ),
    iconTheme: _buildShrineIconTheme(base.iconTheme),
    // Estilo de botón elevado para el botón NEXT (marrón)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 8.0,
        backgroundColor: kShrineBrown900,
        foregroundColor: kShrineBackgroundWhite,
        shape: const BeveledRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(7.0)),
        ),
      ),
    ),
    // Estilo para los campos de texto
    inputDecorationTheme: const InputDecorationTheme(
      border: CutCornersBorder(),
      focusedBorder: CutCornersBorder(
        borderSide: BorderSide(
          width: 2.0,
          color: kShrineBrown900,
        ),
      ),
      floatingLabelStyle: TextStyle(
        color: kShrineBrown900,
      ),
    ),
  );
}

TextTheme _buildShrineTextTheme(TextTheme base) {
  return base.copyWith(
    headlineLarge: base.headlineLarge?.copyWith(
      fontWeight: FontWeight.w500,
      letterSpacing: 1.0,
    ),
    headlineMedium: base.headlineMedium?.copyWith(
      fontSize: 18.0,
      letterSpacing: 1.0,
    ),
    bodySmall: base.bodySmall?.copyWith(
      fontWeight: FontWeight.w400,
      fontSize: 14.0,
      letterSpacing: 0.5,
    ),
    bodyLarge: base.bodyLarge?.copyWith(
      fontWeight: FontWeight.w500,
      fontSize: 16.0,
      letterSpacing: 0.5,
    ),
    labelLarge: base.labelLarge?.copyWith(
      fontWeight: FontWeight.w500,
      letterSpacing: 1.0,
    ),
  ).apply(
    fontFamily: 'Rubik',
    displayColor: kShrineBrown900,
    bodyColor: kShrineBrown900,
  );
}

IconThemeData _buildShrineIconTheme(IconThemeData base) {
  return base.copyWith(
    color: kShrineBrown900,
  );
}