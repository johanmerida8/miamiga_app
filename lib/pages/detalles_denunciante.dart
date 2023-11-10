// ignore_for_file: avoid_print


import 'package:audioplayers/audioplayers.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:miamiga_app/components/headers.dart';
import 'package:miamiga_app/components/my_textfield.dart';
import 'package:miamiga_app/model/datos_denunciante.dart';
import 'package:miamiga_app/model/datos_incidente.dart';

class DetalleDenuncia extends StatefulWidget {
  final User? user;
  final IncidentData incidentData;
  final DenuncianteData denuncianteData;
  

  const DetalleDenuncia({
      super.key,
      required this.user,
      required this.incidentData,
      required this.denuncianteData,
    });

  @override
  State<DetalleDenuncia> createState() => _DetalleDenunciaState();
}

class _DetalleDenunciaState extends State<DetalleDenuncia> {

  final descripcionController = TextEditingController();
  final fechaController = TextEditingController();
  final locationController = TextEditingController();


  double lat = 0.0;
  double long = 0.0;

  final CollectionReference _details = 
        FirebaseFirestore.instance.collection('cases');

  Future<void> _fetchData() async {
  try {
    // Check if widget.user is not null before proceeding
    if (widget.user != null) {
      final supervisorSnapshot = await FirebaseFirestore.instance.collection('users').doc(widget.user!.uid).get();

      if (supervisorSnapshot.exists) {
        final supervisorData = supervisorSnapshot.data() as Map<String, dynamic>;
        final userRole = supervisorData['role'];
        
        // Check if the user has the role of "Supervisor"
        if (userRole == "Supervisor") {
          final supervisorFullName = supervisorData['fullname'];
          print("Nombre completo del supervisor: $supervisorFullName");

          // Query cases assigned to the supervisor
          final querySnapshot = await _details.where('supervisor', isEqualTo: supervisorFullName).get();
          print("Supervisor full name: $supervisorFullName");
          print("Query snapshot: ${querySnapshot.docs}");


          if (querySnapshot.docs.isNotEmpty) {
            // There are cases assigned to the supervisor
            final firstDocument = querySnapshot.docs.first;
            final incidenteData = firstDocument['incidente'];

            if (incidenteData != null) {
              final Map<String, dynamic> incidente = incidenteData as Map<String, dynamic>;
              final descripcionIncidente = incidente['descripcionIncidente'] ?? '';
              final fechaIncidente = incidente['fechaIncidente'] ?? '';
              final latitude = incidente['lat'] ?? 0.0;
              final longitude = incidente['long'] ?? 0.0;
              final imageUrl = incidente['imageUrl'] ?? '';
              final audioUrl = incidente['audioUrl'] ?? '';
              final documentUrl = incidente['document'] ?? '';

              setState(() {
                descripcionController.text = descripcionIncidente;
                fechaController.text = fechaIncidente;
                locationController.text = latitude.toString();
                locationController.text = latitude.toString();
                imageUrl;
                audioUrl;
                documentUrl;
              });

              lat = latitude;
              long = longitude;

              final List<Placemark> placemarks = await placemarkFromCoordinates(
                latitude, 
                longitude
              );

              if (placemarks.isNotEmpty) {
                final Placemark placemark = placemarks[0];
                final String street = placemark.thoroughfare ?? '';
                final String locality = placemark.locality ?? '';
                final String country = placemark.country ?? '';

                final locationString = '$street, $locality, $country';
                locationController.text = locationString; 

              } else {
                locationController.text = 'No se pudo obtener la ubicación';
              }
            }
          } else {
            // Handle the case where no cases are assigned to the supervisor
            print("No hay casos asignados al supervisor.");
          }
        } else {
          print("El usuario no tiene el rol de Supervisor.");
        }
      } else {
        print("No existe el documento del supervisor.");
      }
    } else {
      print("El usuario es nulo.");
    }
  } catch (e) {
    print("Error en obtener datos: $e");
  }
}


@override
void initState() {
  super.initState();
  _fetchData();
}

  

  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack( // Wrap the content with a Stack
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  const SizedBox(height: 15),
                  

                  Row(
                    children: [
                      const Header(
                        header: 'Detalle del Denuncia',
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // FutureBuilder(
                  //   future: _fetchData(), 
                  //   builder: (context, snapshot) {
                  //     if (snapshot.connectionState == ConnectionState.waiting) {
                  //       return const Center(
                  //         child: CircularProgressIndicator(),
                  //       );
                  //     } else if (snapshot.hasError) {
                  //       return Text('Error: ${snapshot.error}');  
                  //     } else {
                  //       if (mounted) {
                  //         return Column(
                  //           children: [
                  //             CarouselSlider(
                  //               options: CarouselOptions(height: 400.0),
                  //               items: imageUrls.map((i) {
                  //                 return Builder(
                  //                   builder: (BuildContext context) {
                  //                     return Container(
                  //                       width: MediaQuery.of(context).size.width,
                  //                       margin: EdgeInsets.symmetric(horizontal: 5.0),
                  //                       decoration: BoxDecoration(color: Colors.amber),
                  //                       child: Image.network(i, fit: BoxFit.cover),
                  //                     );
                  //                   },
                  //                 );
                  //               }).toList(),
                  //             ),
                  //             IconButton(
                  //               onPressed: () {
                  //                 // Code to play and pause the audio
                  //                 AudioPlayer audioPlayer = AudioPlayer();
                  //                 audioPlayer.play(audioUrl);
                  //               }, 
                  //               icon: const Icon(Icons.play_arrow_rounded),
                  //             ),
                  //             IconButton(
                  //               onPressed: () {
                  //                 // Code to open the document
                  //               }, 
                  //               icon: const Icon(Icons.picture_as_pdf_rounded),
                  //             ),
                  //             const SizedBox(height: 25),
                  //             MyTextField(
                  //               controller: descripcionController, 
                  //               hintText: 'Descripción del Incidente', 
                  //               text: 'Descripción del Incidente', 
                  //               obscureText: false, 
                  //               isEnabled: false, 
                  //               isVisible: true,
                  //             ),
                  //             const SizedBox(height: 25),
                  //             MyTextField(
                  //               controller: fechaController, 
                  //               hintText: 'Fecha del Incidente', 
                  //               text: 'Fecha del Incidente', 
                  //               obscureText: false, 
                  //               isEnabled: false, 
                  //               isVisible: true,
                  //             ),
                  //             const SizedBox(height: 25),
                  //             MyTextField(
                  //               controller: locationController, 
                  //               hintText: 'Ubicación del Incidente', 
                  //               text: 'Ubicación del Incidente', 
                  //               obscureText: false, 
                  //               isEnabled: false, 
                  //               isVisible: true,
                  //             ),
                  //           ],
                  //         );
                  //       } else {
                  //         return Container();
                  //       }
                  //     }
                  //   }
                  // )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}