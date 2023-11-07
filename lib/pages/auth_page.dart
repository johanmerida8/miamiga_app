import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:miamiga_app/pages/inicio_o_registrar.dart';
import 'package:miamiga_app/pages/ventanas_usuario.dart';
import 'package:miamiga_app/pages/ventanas_supervisor.dart';
import 'package:miamiga_app/pages/splash_screen.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.hasData) {
              return FutureBuilder<String?>(
                future: fetchUserRole(snapshot.data!.uid), 
                builder: (context, roleSnapshot) {
                  final role = roleSnapshot.data;
                  if (role == 'Supervisor') {
                    return const ScreenSupervisor();
                  } else {
                    return const Screens();
                  } 
                } 
              );
            }
            return const LoginOrRegister();
          } else {
            return const SplashScreen();
          }
        },
      ),
    );
  }
}


Future<String?> fetchUserRole(String userId) async {
    final snapshot = 
      await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (snapshot.exists) {
      return snapshot.data()?['role'];
    }
    return null;
  }