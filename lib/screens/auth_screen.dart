import 'dart:developer';
import 'dart:io';

import 'package:chat_app/widget/image_input.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final _firebaseAuth = FirebaseAuth.instance;
final _firebaseStorage = FirebaseStorage.instance;
final _firestore = FirebaseFirestore.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _isAuthenticating = false;
  String _inputedUsername = '';
  String _inputedEmail = '';
  String _inputedPassword = '';
  File? _selectedImage;
  final _formKey = GlobalKey<FormState>();

  //function to signup
  void _signup() async {
    final inputsAreValid = _formKey.currentState!.validate();

    if (!inputsAreValid) {
      return;
    }

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      const snackBar = SnackBar(content: Text('Select Profile picture'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _isAuthenticating = true;
    });

    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: _inputedEmail,
        password: _inputedPassword,
      );

      final storageRef = _firebaseStorage
          .ref()
          .child('user_images')
          .child('${userCredential.user!.uid}.jpg');

      await storageRef.putFile(_selectedImage!);
      final imageUrl = await storageRef.getDownloadURL();

      _firestore.collection('users').doc(userCredential.user!.uid).set({
        'user_id': userCredential.user!.uid,
        'user_name': _inputedUsername,
        'email': _inputedEmail,
        'image_url': imageUrl,
      });
      _isAuthenticating = false;
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      final snackBar =
          SnackBar(content: Text(error.message ?? 'Authentication failed'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      setState(() {
        _isAuthenticating = false;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      const snackBar = SnackBar(content: Text('Authentication failed'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  //function to Login
  void _login() async {
    final inputsAreValid = _formKey.currentState!.validate();

    if (!inputsAreValid) {
      return;
    }

    _formKey.currentState!.save();

    setState(() {
      _isAuthenticating = true;
    });

    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: _inputedEmail,
        password: _inputedPassword,
      );
      _isAuthenticating = false;
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      final snackBar =
          SnackBar(content: Text(error.message ?? 'Authentication failed'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    setState(() {
      _isAuthenticating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: Image.asset(
                    'assets/images/chat.png',
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          if (!_isLogin)
                            ImageInput(
                              selectedImage: (selectedImage) {
                                _selectedImage = selectedImage;
                              },
                            ),
                          if (!_isLogin)
                            TextFormField(
                              decoration: const InputDecoration(
                                label: Text('Username'),
                              ),
                              autocorrect: false,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    value.trim().length < 5) {
                                  return 'Username must be 4 charater +';
                                } else {
                                  return null;
                                }
                              },
                              onSaved: (value) {
                                _inputedUsername = value!;
                              },
                            ),
                          TextFormField(
                            decoration: const InputDecoration(
                              label: Text('Email Adress'),
                            ),
                            autocorrect: false,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().length <= 3 ||
                                  !value.contains('@')) {
                                return 'Enter a valid email';
                              } else {
                                return null;
                              }
                            },
                            onSaved: (value) {
                              _inputedEmail = value!;
                            },
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              label: Text('Password'),
                            ),
                            autocorrect: false,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.length < 5) {
                                return 'Password must be 4 charater +';
                              } else {
                                return null;
                              }
                            },
                            onSaved: (value) {
                              _inputedPassword = value!;
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          if (!_isAuthenticating)
                            ElevatedButton(
                              onPressed: () {
                                _isLogin ? _login() : _signup();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                              child: Text(_isLogin ? 'Sign in' : 'Sign up'),
                            ),
                          if (!_isAuthenticating)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(_isLogin
                                  ? 'Don\'t have an account? Sign up'
                                  : 'Have an account? Sign in'),
                            ),
                          if (_isAuthenticating)
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 25),
                              child: const CircularProgressIndicator(),
                            )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
