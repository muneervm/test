import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project2/home.dart';
import 'package:project2/signin.dart';

class SignPage extends StatefulWidget {
  const SignPage({Key? key}) : super(key: key);

  @override
  State<SignPage> createState() {
    return SignPageState();
  }
}

class SignPageState extends State<SignPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController userEmailController = TextEditingController();
  TextEditingController userPasswordController = TextEditingController();
  TextEditingController userPhoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 0, 0, 0),
        title: const Text(
          'Create Account',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: const [],
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: usernameController,
                      onChanged: (value) => setState(() {}),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color.fromARGB(255, 255, 255, 255),
                        errorText: usernameValidate(usernameController.text),
                        labelText: "Username",
                        prefixIcon: const Icon(Icons.hdr_auto_sharp),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: userPhoneNumberController,
                      onChanged: (value) => setState(() {}),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        errorText: phoneNumber(userPhoneNumberController.text),
                        labelText: "Phone Number",
                        prefixIcon: const Icon(Icons.phone_android),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: userEmailController,
                      onChanged: (value) => setState(() {}),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        errorText: validateEmail(userEmailController.text),
                        labelText: "Email",
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: userPasswordController,
                      obscureText: true,
                      onChanged: (value) => setState(() {}),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        errorText: validatePassword(userPasswordController.text),
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () async {
                        var username = usernameController.text.trim();
                        var userPhoneNumber = userPhoneNumberController.text.trim();
                        var userEmail = userEmailController.text.trim();
                        var userPassword = userPasswordController.text.trim();

                        try {
                          UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                            email: userEmail,
                            password: userPassword,
                          );

                          await FirebaseFirestore.instance.collection("users").doc(userCredential.user!.uid).set({
                            'username': username,
                            'userPhoneNumber': userPhoneNumber,
                            'userEmail': userEmail,
                            'createdAt': DateTime.now(),
                            'userId': userCredential.user!.uid,
                            'password': userPassword,
                          });

                          print('User created in Firebase and Firestore');

                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => ProductHomePage()),
                          );
                        } catch (e) {
                          print('Error creating user: $e');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                        backgroundColor: Colors.green,
                      ),
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(fontSize: 15, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?", style: TextStyle(color: Colors.black)),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            backgroundColor: const Color.fromARGB(255, 62, 133, 233),
                          ),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => SigninPage()),
                            );
                          },
                          child: const Text(
                            'Sign In',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email address';
    } else if (!value.contains("@")) {
      return 'Invalid Email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.length < 6) {
      return "Password must be at least 6 characters long";
    }
    return null;
  }

  String? usernameValidate(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter a username";
    }
    return null;
  }

  String? phoneNumber(String? value) {
    if (value?.length == 10) {
      return null;
    } else {
      return "Please enter a valid phone number";
    }
  }
}
