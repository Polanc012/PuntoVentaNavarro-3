import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import '../widgets/icon_text_field.dart';
import '../models/user.dart';

class VistaPrincipal extends StatelessWidget {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  VistaPrincipal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: Colors.grey[300],
            height: double.infinity,
            width: double.infinity,
          ),
          SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 60.0, horizontal: 10.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Minisuper Polanco',
                      style: GoogleFonts.outfit(
                        fontSize: 55,
                        fontWeight: FontWeight.normal,
                        color: Colors.blueAccent,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Usuario:',
                      style: GoogleFonts.comfortaa(
                        fontSize: 30,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 10),
                    IconTextField(
                      icon: FontAwesomeIcons.user,
                      hintText: 'Ingrese su usuario',
                      controller: _usernameController,
                    ),
                    const SizedBox(height: 25),
                    Text(
                      'Contraseña:',
                      style: GoogleFonts.comfortaa(
                        fontSize: 30,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 10),
                    IconTextField(
                      icon: FontAwesomeIcons.lock,
                      hintText: 'Ingrese su contraseña',
                      controller: _passwordController,
                      obscureText: true,
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      onPressed: () async {
                        // Lógica para iniciar sesión
                        String username = _usernameController.text;
                        String password = _passwordController.text;

                        var userBox = Hive.box<User>('users');
                        User? user;
                        try {
                          user = userBox.values.firstWhere(
                            (user) =>
                                user.name == username &&
                                user.password == password,
                          );
                        } catch (e) {
                          user = null;
                        }

                        if (user != null) {
                          // Navegar a la pantalla de inicio con argumentos
                          Navigator.pushNamed(
                            context,
                            '/inicio',
                            arguments: {
                              'username': user.name ?? '',
                              'userType': user.role ?? ''
                            },
                          );
                        } else {
                          // Mostrar un mensaje de error si las credenciales son incorrectas
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Usuario o contraseña incorrectos')),
                          );
                        }
                      },
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // Centra el contenido
                        children: [
                          const Icon(
                            FontAwesomeIcons.user,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Iniciar Sesión',
                            style: GoogleFonts.cabin(fontSize: 22),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
