// ignore_for_file: avoid_print, sort_child_properties_last, non_constant_identifier_names

import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:miamiga_app/components/headers.dart';
import 'package:miamiga_app/components/my_important_btn.dart';
import 'package:miamiga_app/components/my_textfield.dart';// ignore: unused_import
import 'package:miamiga_app/pages/edit_perfil.dart';
import 'package:miamiga_app/pages/inicio_o_registrar.dart';
import 'package:miamiga_app/resources/image_data.dart';
import 'package:miamiga_app/utils/utils.dart';

class PerfilScreen extends StatefulWidget {
  final User? user;

  const PerfilScreen({super.key, required this.user});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {

  final fullnameController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  void signUserOut(BuildContext context) async{
    await FirebaseAuth.instance.signOut();
    await _googleSignIn.signOut();
    // ignore: use_build_context_synchronously
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => const LoginOrRegister(),
      ),
    );
  }

  void editPersonalData() async{
    //i want a navigator to go to the edit perfil page
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditPerfil(user: widget.user), 
      ),
    );
  }



  final CollectionReference _registration = 
        FirebaseFirestore.instance.collection('users');

  Future<void> _fetchData() async {
  try {
    if (widget.user != null) {
      final DocumentSnapshot documentSnapshot = await _registration.doc(widget.user!.uid).get();

      if (documentSnapshot.exists) {
        // Fetch user data including latitude and longitude
        fullnameController.text = documentSnapshot['fullname'];
        phoneController.text = documentSnapshot['phone'].toString();
        double latitude = documentSnapshot['lat'] as double;
        double longitude = documentSnapshot['long'] as double;

        lat = latitude;
        long = longitude;

        // Fetch and format location data
        final location = await getUserLocation();
        locationController.text = location;
      } else {
        // Handle the case where the document doesn't exist
        print("No existe el documento.");
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

  double lat = 0.0;
  double long = 0.0;

  Future<String> getUserLocation() async {
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        lat, 
        long,
      );

      if (placemarks.isNotEmpty) {
        final Placemark placemark = placemarks[0];
        final String street = placemark.thoroughfare ?? '';
        final String locality = placemark.locality ?? '';
        final String country = placemark.country ?? '';

        final formattedAddress = '$street, $locality, $country';
        return formattedAddress;
      } else {
        return 'No se pudo obtener la ubicación';
      }
    } catch (e) {
      print('Error en obteniendo ubicacion del usuario: $e');
      return 'No se pudo obtener la ubicación';
    }
  }

  Future<void> updateLocation() async {
    try {
      final String location = await getUserLocation();
      locationController.text = location;
    } catch (e) {
      print('Error actualizando ubicacion: $e');
    }
  }

  Uint8List? _image;

  void selectedImageProfile() async {
    Uint8List img = await pickImage(ImageSource.gallery);
    setState(() {
      _image = img;
    });
  }

  void saveProfileImage() async {
  try {
    await StoreData().saveData(
      file: _image!,
    );
    // Handle success, e.g., show a success message or navigate to another screen.
  } catch (e) {
    // Handle the error, e.g., show an error message or log the error.
    print("Error guardando la imagen: $e");
  }
}


  void showSaveDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Guardar Imagen"),
        content: const Text("Quieres guardar la imagen?"),
        actions: <Widget>[
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text("Guardar"),
            onPressed: () {
              saveProfileImage();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

  @override
  void dispose() {
    fullnameController.dispose();
    phoneController.dispose();
    locationController.dispose();
    super.dispose();
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
                        header: 'Mi Perfil',
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.logout),
                        onPressed: () {
                          _showSignOutConfirmationDialog(context);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  Stack(
                    children: [
                      _image != null ? CircleAvatar(
                        radius: 40,
                        backgroundImage: MemoryImage(_image!),
                      ) :
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          color: Colors.black,
                        ),
                      ),
                      Positioned(
                        child: IconButton(
                          onPressed: () {
                            selectedImageProfile();
                            showSaveDialog(context);
                          }, 
                          icon: const Icon(
                            Icons.add_a_photo,
                            color: Colors.black,
                          ),
                        ),
                        bottom: -10,
                        left: 45,
                      ),
                    ],
                  ),


                  FutureBuilder(
                      future: _fetchData(), 
                      builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (snapshot.hasError) {
                        return Text ('Error: ${snapshot.error}');
                      } else {
                        return Column(
                          children: [
                            const SizedBox(height: 25),
                            MyTextField(
                              controller: fullnameController,
                              text: 'Nombre Completo',
                              hintText: 'Nombre Completo',
                              obscureText: false,
                              isEnabled: false,
                              isVisible: true,
                            ),
                            const SizedBox(height: 15),
                            MyTextField(
                              controller: locationController,
                              text: 'Ubicación',
                              hintText: 'Ubicación',
                              obscureText: false,
                              isEnabled: false,
                              isVisible: true,
                            ),
                            const SizedBox(height: 15),
                            MyTextField(
                              controller: phoneController,
                              text: 'Telefono',
                              hintText: 'Telefono',
                              obscureText: false,
                              isEnabled: false,
                              isVisible: true,
                            ),
                            const SizedBox(height: 25),
                            MyImportantBtn(
                              onTap: editPersonalData, 
                              text: 'Editar Perfil'
                            ),
                          ],
                        );
                      }
                    }
                  ),

                  const SizedBox(height: 70),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Text(
                      widget.user != null ? 'Iniciado como: ${widget.user?.email}' : 'Usuario desconocido',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }




  // Function to show the sign-out confirmation dialog
void _showSignOutConfirmationDialog(BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Cierre de Sesión'),
          content: const Text('¿Estás seguro de que deseas cerrar la sesión?'),
          actions: [
            TextButton(
              onPressed: () {
                // Close the dialog
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
              onPressed: () {
                // Perform sign-out action here
                signUserOut(context); // Call your sign-out method
                // Close the dialog
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cerrar Sesión',
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
}
