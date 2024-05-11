import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:water/home_screen.dart';

import 'login.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final rePasswordController = TextEditingController();
  bool visiblePassword = true;
  bool visiblePassword1 = true;
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 50),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextField(
                            controller: firstNameController,
                            decoration: InputDecoration(
                              labelText: 'First Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextField(
                            controller: lastNameController,
                            decoration: InputDecoration(
                              labelText: 'Last Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextField(
                            controller: phoneController,
                            decoration: InputDecoration(
                              labelText: 'Phone',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextField(
                            controller: emailController,
                            decoration: InputDecoration(
                              labelText: 'Enter email',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextField(
                            controller: passwordController,
                            decoration: InputDecoration(
                              labelText: 'Enter Password',
                              border: OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  visiblePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    visiblePassword = !visiblePassword;
                                  });
                                },
                              ),
                            ),
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: visiblePassword,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: TextField(
                            controller: rePasswordController,
                            decoration: InputDecoration(
                              labelText: 'Re-enter Password',
                              border: OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  visiblePassword1 ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    visiblePassword1 = !visiblePassword1;
                                  });
                                },
                              ),
                            ),
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: visiblePassword1,
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () async {
                            if (passwordController.text != rePasswordController.text) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Passwords do not match."),
                                ),
                              );
                              return;
                            }

                            try {
                              final userCredential = await _auth.createUserWithEmailAndPassword(
                                email: emailController.text,
                                password: passwordController.text,
                              );
                              // Check if user account creation is successful
                              if (userCredential.user != null) {
                                // Store additional user data in Firebase
                                await _storeUserData(userCredential.user!);

                                // Navigate to the user profile page if account creation is successful
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) =>
                                      MyHomePage(userCredential.user!)),
                                );
                              }
                            } on FirebaseAuthException catch (e) {
                              // Show an error message if account creation fails due to Firebase exceptions
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Failed to create account. Error: ${e.message}"),
                                ),
                              );
                            }
                          },
                          child: Text("Sign Up"),
                        ),
                        SizedBox(height: 20),
                      ],
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

  Future<void> _storeUserData(User user) async {
    try {
      await FirebaseDatabase.instance.reference().child('users/${user.uid}').set({
        'email': user.email,
        'firstName': firstNameController.text,
        'lastName': lastNameController.text,
        'phone': phoneController.text,
      });
    } catch (error) {
      print('Error storing user data: $error');
    }
  }
}
