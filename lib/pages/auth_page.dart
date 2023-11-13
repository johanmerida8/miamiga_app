import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
                  if (roleSnapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (roleSnapshot.hasError) {
                    return Text('Error: ${roleSnapshot.error}');
                  } else {
                    final role = roleSnapshot.data;
                    if (role == 'Supervisor') {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.pushReplacementNamed(
                            context, '/screens_supervisor');
                      });
                    } else {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.pushReplacementNamed(
                            context, '/screens_usuario');
                      });
                    }
                    return Container();
                  }
                },
              );
            } else {
              // Navigate to login/register page if user is not logged in
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacementNamed(context, '/inicio_o_registrar');
              });
              return Container();
            }
          } else {
            // Show loading spinner while waiting for auth state to change
            return const CircularProgressIndicator();
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
    return 'Usuario Normal'; //snapshot.get('role') as String?;
  }
  return null;
}
