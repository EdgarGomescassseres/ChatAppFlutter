import 'dart:io';

import 'package:chat_app/pantallas/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _fireBase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  var _nombreIngresado = "";
  var _isLogin = true;
  var _emailIngresado = "";
  var _passwordIngresada = "";
  File? _imagenIngresada;
  var _autenticando = false;

  void _submit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid || _isLogin && _imagenIngresada == null) {
      return;
    }

    _form.currentState!.save();

    try {
      setState(() {
        _autenticando = true;
      });
      if (_isLogin) {
        final credencialUsuario = await _fireBase.signInWithEmailAndPassword(
            email: _emailIngresado, password: _passwordIngresada);
      } else {
        final credencialUsuario =
            await _fireBase.createUserWithEmailAndPassword(
                email: _emailIngresado, password: _passwordIngresada);

        final storageRef = FirebaseStorage.instance
            .ref()
            .child("user_images")
            .child("${credencialUsuario.user!.uid}.jpg");

        await storageRef.putFile(_imagenIngresada!);
        final imageUrl = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection("users")
            .doc(credencialUsuario.user!.uid)
            .set({
          "nombreDeUsuario": _nombreIngresado,
          "correo": _emailIngresado,
          "imageUrl": imageUrl
        });
      }
    } on FirebaseAuthException catch (error) {
      if (error.code == "email-already-in-use") {
        setState(() {
          _autenticando = false;
        });
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message ?? "Autenticaion fallida"),
          ),
        );
      }
      if (error.code == "invalid-email") {
        setState(() {
          _autenticando = false;
        });
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message ?? "Autenticaion fallida"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.onBackground,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("ChapsApp",
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      fontSize: 23)),
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset("assets/images/chat.png"),
              ),
              Card(
                color: Theme.of(context).colorScheme.onPrimary,
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _form,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!_isLogin)
                            UserImagePicker(
                              onPickedImage: (fotoCapturada) =>
                                  _imagenIngresada = fotoCapturada,
                            ),
                            if(!_isLogin)
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: "Nombre de Usuario"),
                            enableSuggestions: false,
                            validator: (value) {
                              if (value == null ||
                                  value.isEmpty ||
                                  value.trim().length < 4) {
                                    return "El nombre debe tener 4 o mas caracteres.";
                                  }
                            },
                            onSaved: (value) => _nombreIngresado = value!,
                          ),
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: "Correo"),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return "Por favor ingrese una direccion de correo valida";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _emailIngresado = value!;
                            },
                          ),
                          TextFormField(
                            decoration:
                                const InputDecoration(labelText: "Contraseña"),
                            keyboardType: TextInputType.text,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.trim().length < 6) {
                                return "La contraseña debe tener al menos 6 caracteres";
                              }
                              return null;
                            },
                            onSaved: (value) {
                              _passwordIngresada = value!;
                            },
                          ),
                          const SizedBox(height: 12),
                          if (_autenticando) const CircularProgressIndicator(),
                          if (!_autenticando)
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer),
                                onPressed: _submit,
                                child: Text(_isLogin
                                    ? "Iniciar Sesion"
                                    : "Registrarse")),
                          if (_autenticando) const CircularProgressIndicator(),
                          if (!_autenticando)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(
                                  _isLogin
                                      ? "Crear Una Cuenta"
                                      : "Ya tienes una cuenta?. Ingresa.",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary)),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
