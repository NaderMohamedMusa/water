import 'dart:developer';

import 'package:connectivity_widget/connectivity_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bluetooth_serial_ble/flutter_bluetooth_serial_ble.dart';
import 'package:water/signup.dart';
import 'package:water/home_screen.dart';

import 'bluetooth/ChatPage.dart';
import 'bluetooth/SelectBondedDevicePage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool visiblePassword = true;
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConnectivityWidget(
        builder: (context, isOnline) => isOnline
            ? Center(
            child: Center(
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
                        SizedBox(height: 10),

                        ElevatedButton(
                          onPressed: () async {
                            try {
                              final userCredential = await _auth.signInWithEmailAndPassword(
                                email: emailController.text,
                                password: passwordController.text,
                              );
                              // Check if user authentication is successful
                              if (userCredential.user != null) {
                                // Navigate to the new page if login is successful
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) =>
                                      MyHomePage(userCredential.user!)),
                                );
                              } else {
                                // Show an error message if authentication fails
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Failed to sign in. Please check your email and password."),
                                  ),
                                );
                              }
                            } on FirebaseAuthException catch (e) {
                              // Show an error message if authentication fails due to Firebase exceptions
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Failed to sign in. Error: ${e.message}"),
                                ),
                              );
                            }
                          },
                          child: const Text("Sign In"),
                        ),

                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Not a member?"),
                            TextButton(
                              onPressed: () {
                                // Navigate to the sign up page here
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => SignUpScreen()),
                                );
                              },
                              child: const Text("Sign Up"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ))
            : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                  "No Internet ?",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 30),
              const Text("Connect with bluetooth"),
              const SizedBox(height: 10),
              InkWell(
                  onTap: () async {
                    final BluetoothDevice? selectedDevice =
                    await Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) {
                        return const SelectBondedDevicePage(
                            checkAvailability: false);
                      },
                    ),);

                    if (selectedDevice != null) {
                      log('Connect -> selected ${selectedDevice.address}');
                      startChat(selectedDevice);
                    }
                    else {
                      log('Connect -> no device selected');
                    }
                  },
                  child: Container(
                    width: 150,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.lightBlue,
                      borderRadius: BorderRadius.circular(5)
                    ),
                    child: const Icon(
                        Icons.bluetooth,
                      color: Colors.white,
                    ),
                  )
              ),
            ],
          ),
        ),
    ));
  }

  void startChat(BluetoothDevice server) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ChatPage(server: server);
        },
      ),
    );
  }
}