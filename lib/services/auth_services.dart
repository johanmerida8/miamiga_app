import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:miamiga_app/pages/ventanas_usuario.dart';

class AuthService {

  final BuildContext context;

  AuthService({required this.context});

  //iniciar con google
  Future<void> signInWithGoogle() async {

      try {
        //comenzar con el proceso de iniciar
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      //obtener detalles de auth de requests
      final GoogleSignInAuthentication gAuth = await gUser!.authentication;

      //crear un nueva credential para usuario
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      //finalmente, debemos iniciar sesion
      await FirebaseAuth.instance.signInWithCredential(credential);

      //ir a la pantalla de inicio
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const Screens(),
        ),
      );
    } catch (e) {
      // ignore: avoid_print
      print("Error de iniciar con google: $e");
    }
  }     
}