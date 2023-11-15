import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:miamiga_app/components/important_button.dart';
import 'package:miamiga_app/model/datos_denunciante.dart';
import 'package:miamiga_app/model/datos_incidente.dart';
import 'package:miamiga_app/pages/incidente.dart';

class InicioScreen extends StatefulWidget {
  final User? user;
  final IncidentData incidentData;
  final DenuncianteData denunciaData;
  const InicioScreen({
    super.key,
    required this.user,
    required this.incidentData,
    required this.denunciaData,
  });

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  Future<String> getUserName(User? user) async {
    
  if (user != null) {
    // Check if the user is signed in with Google
    if (user.providerData.any((userInfo) => userInfo.providerId == 'google.com')) {
      // If signed in with Google, return the user's display name
      return user.displayName ?? 'Usuario desconocido';
    } else {
      // If not signed in with Google, you can implement a different logic
      // to get the user's name based on your authentication method.
      // For example, if using email/password, you can fetch it from Firestore
      // or another database using the user's UID.
      // Here's an example using Firestore:

      try {
        DocumentSnapshot snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (snapshot.exists) {
          final fullName = snapshot.get('fullname');
          return fullName;
        } else {
          return 'Usuario desconocido';
        }
      } catch (e) {
        // ignore: avoid_print
        print('Error getting user name: $e');
        return 'Usuario desconocido';
      }
    }
  } else {
    return 'Usuario desconocido';
  }
}

  void denunciarScreen() async{
      //i want a navigator to go to the edit perfil page
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DenunciaIncidente(
            user: widget.user, 
            incidentData: widget.incidentData, 
            denuncianteData: widget.denunciaData,
          ), 
        ),
      );
    }

    

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 15),
              FutureBuilder<String>(
                future: getUserName(widget.user),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color.fromRGBO(255, 87, 110, 1),
                      )
                    );
                  } else {
                    final userName = snapshot.data ?? 'Usuario desconocido';
                    return Center(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 30.0),
                            child: Text(
                              'Bienvenido, $userName',
                                style: const TextStyle(fontSize: 40),
                                textAlign: TextAlign.start,
                            ),
                          ),    
                          const SizedBox(height: 100),
                          ImportantButton(
                            text: 'DENUNCIAR',
                            onTap: denunciarScreen,
                            icon: Icons.warning_rounded,
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
