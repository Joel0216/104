// Copyright 2018-present the Flutter authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';

import 'colors.dart';
import 'home.dart';
import 'login.dart';
import 'supplemental/cut_corners_border.dart';

// TODO: Convert ShrineApp to stateful widget (104)
class ShrineApp extends StatelessWidget {
  const ShrineApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shrine',
      initialRoute: '/login',
      routes: {
        '/login': (BuildContext context) => const LoginPage(),
        // TODO: Change to a Backdrop with a HomePage frontLayer (104)
        '/': (BuildContext context) => const HomePage(),
        // TODO: Make currentCategory field take _currentCategory (104)
        // TODO: Pass _currentCategory for frontLayer (104)
        // TODO: Change backLayer field value to CategoryMenuPage (104)
      },
      // TODO: Add a theme (103)
      theme: _kShrineTheme,
    );
  }
}

// TODO: Build a Shrine Theme (103)
final ThemeData _kShrineTheme = _buildShrineTheme();

ThemeData _buildShrineTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: const Color.fromARGB(255, 116, 187, 41),
      onPrimary: kShrineBrown900,
      secondary: kShrineBrown900,
      error: kShrineErrorRed,
    ),
    // TODO: Add the text themes (103)
    textTheme: _buildShrineTextTheme(base.textTheme),
    textSelectionTheme: const TextSelectionThemeData(
      selectionColor: Color.fromARGB(255, 107, 168, 23),
    ),
    // AÑADIDO: Tema de la AppBar para el color de fondo y texto/iconos negros
    appBarTheme: const AppBarTheme(
      foregroundColor: kShrineBrown900, // Color de íconos/texto (negro)
      backgroundColor: Color.fromARGB(255, 74, 200, 24),
      elevation: 0.0,
    ),
    // AÑADIDO: Tema de los íconos (para asegurar el color negro en la AppBar)
    iconTheme: _buildShrineIconTheme(base.iconTheme),
    // TODO: Decorate the inputs (103)
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

// TODO: Build a Shrine Text Theme (103)
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

// AÑADIDO: Función para el tema de íconos (color negro)
IconThemeData _buildShrineIconTheme(IconThemeData base) {
  return base.copyWith(
    color: kShrineBrown900,
  );
}