import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:miamiga_app/components/important_button.dart';
import 'package:miamiga_app/components/my_button.dart';
import 'package:miamiga_app/components/my_important_btn.dart';
import 'package:miamiga_app/model/datos_denunciante.dart';
import 'package:miamiga_app/model/datos_incidente.dart';
import 'package:miamiga_app/pages/alerta_oficial.dart';
import 'package:miamiga_app/pages/incidente.dart';
import 'package:miamiga_app/pages/ventanas_usuario.dart';

class AlertaScreen extends StatefulWidget {
  final User? user;
  final DenuncianteData denuncianteData;
  final IncidentData incidentData;
  const AlertaScreen({
    super.key,
    required this.user,
    required this.denuncianteData,
    required this.incidentData,
  });

  @override
  State<AlertaScreen> createState() => _AlertaScreenState();
}

class _AlertaScreenState extends State<AlertaScreen> {

  List<XFile> pickedImages = [];
  List<XFile> pickedVideoFile = [];

  void editarDenuncia() async{
    //i want a navigator to go to the edit perfil page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DenunciaIncidente(user: widget.user, incidentData: widget.incidentData, denuncianteData: widget.denuncianteData), 
      ),
    );
  }

  
  void alert() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('¿Estás seguro?'),
          content: const Text('¿Deseas denunciar este incidente?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();

                //crear la denuncia
                createCase(widget.user, widget.denuncianteData, widget.incidentData);

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AlertaOficialScreen(), 
                  ),
                );
              },
              child: const Text(
                'Aceptar',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void homeScreen() async {
    //i want a navigator to go to the home screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const Screens(), 
      ),
    );
  }

  void createCase(User? user, DenuncianteData denuncianteData, IncidentData incidentData) async {
    //i want to create the document of my case

    final CollectionReference _case = 
        FirebaseFirestore.instance.collection('cases');

    await _case.add({

      'denunciante': {
        'fullname': denuncianteData.fullName,
        'ci': denuncianteData.ci,
        'phone': denuncianteData.phone,
        'lat': denuncianteData.lat,
        'long': denuncianteData.long,
      },

      'incidente': {
        'descripcionIncidente': incidentData.description,
        'fechaIncidente': incidentData.date,
        'lat': incidentData.lat,
        'long': incidentData.long,
        'imageUrl': incidentData.imageUrl,
        'audioUrl': incidentData.audioUrl,
      },

      'estado': 'pendiente',
      'fecha': DateTime.now(),
      'supervisor': '',
      'oficial': '',
      'user': user?.uid,
    });
    
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
                Center(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.0),
                        child: Text(
                          '¿Estás seguro de proceder hacer un alerta?',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold
                            ),
                            textAlign: TextAlign.start,
                        ),
                      ),    
                      const SizedBox(height: 50),
                      MyImportantBtn(
                        text: 'Editar',
                        onTap: editarDenuncia,
                      ),

                      const SizedBox(height: 50),
                      ImportantButton(
                        text: 'ALERTA',
                        onTap: alert,
                        icon: Icons.warning_rounded,
                    ),

                    const SizedBox(height: 50),
                      MyButton(
                        text: 'Ir al Inicio',
                        onTap: homeScreen,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}