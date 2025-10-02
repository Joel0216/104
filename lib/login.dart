import 'package:flutter/material.dart';

import 'colors.dart'; // Importar colors.dart para usar kShrineBrown900 y kShrineBackgroundWhite

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          children: <Widget>[
            const SizedBox(height: 80.0),
            Column(
              children: <Widget>[
                Image.asset('assets/diamond.png'),
                const SizedBox(height: 16.0),
                Text(
                  'SHRINE',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 120.0),
            // [CÓDIGO DE ENTRADA] Nombre de usuario
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                filled: true,
                labelText: 'Username',
              ),
            ),
            const SizedBox(height: 12.0),
            // [CÓDIGO DE ENTRADA] Contraseña
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                filled: true,
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            // [CÓDIGO DE BOTONES] Barra de botones
            const SizedBox(height: 12.0),
            OverflowBar(
              alignment: MainAxisAlignment.end,
              children: <Widget>[
                // Botón CANCEL
                TextButton(
                  child: const Text('CANCEL'),
                  onPressed: () {
                    // Limpiar campos de texto al presionar CANCELAR
                    _usernameController.clear();
                    _passwordController.clear();
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                    shape: const BeveledRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(7.0)),
                    ),
                  ),
                ),
                // Botón NEXT (Estilo Elevado Biselado de Shrine)
                ElevatedButton(
                  child: const Text('NEXT'),
                  onPressed: () {
                    // Cierra la pantalla de inicio de sesión y regresa a la anterior (HomePage)
                    Navigator.pop(context);
                  },
                  // El estilo se define aquí para asegurar el color y la forma biselada
                  style: ElevatedButton.styleFrom(
                    elevation: 8.0,
                    // Colores de Shrine: Marrón de fondo, Blanco en el texto
                    backgroundColor: kShrineBrown900,
                    foregroundColor: kShrineBackgroundWhite,
                    shape: const BeveledRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(7.0)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}