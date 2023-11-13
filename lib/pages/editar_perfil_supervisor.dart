// ignore_for_file: avoid_print, use_build_context_synchronously, duplicate_ignore

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:location/location.dart';
import 'package:miamiga_app/components/headers.dart';
import 'package:miamiga_app/components/my_important_btn.dart';
import 'package:miamiga_app/components/my_textfield.dart';
import 'package:miamiga_app/components/phoneKeyboard.dart';
import 'package:miamiga_app/pages/map.dart';

class EditPerfilSupervisor extends StatefulWidget {
  final User? user;

  const EditPerfilSupervisor({
    super.key,
    required this.user,
  });

  @override
  State<EditPerfilSupervisor> createState() => _EditPerfilSupervisorState();
}

class _EditPerfilSupervisorState extends State<EditPerfilSupervisor> {
  late LocationData modifiedLocation;

  final fullnameController = TextEditingController();
  final phoneController = TextEditingController();
  final latController = TextEditingController();
  final longController = TextEditingController();
  bool controlVentana = false;

  final CollectionReference _registration =
      FirebaseFirestore.instance.collection('users');

  //update operation
  Future<void> _updateData(String userId, String fullName, int phone,
      double lat, double long) async {
    try {
      // Get a reference to the Firestore collection
      final DocumentReference userDocument = _registration.doc(userId);

      //ver si los datos han sido modificados
      final DocumentSnapshot currentData = await userDocument.get();
      print('get UserDocument_________$currentData');
      final Map<String, dynamic> currentValues =
          currentData.data() as Map<String, dynamic>;
      print('data currentValues_________$currentValues');

      if (currentValues['fullname'] == fullName &&
          currentValues['phone'] == phone &&
          currentValues['lat'] == lat &&
          currentValues['long'] == long) {
        //no se han realizado cambios
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se han realizado cambios.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      } else {
        // changesMade = true;
        // Update the document with the specified userId
        await userDocument.update({
          'fullname': fullName,
          'phone': phone,
          'lat': lat,
          'long': long,
        });
        controlVentana = false;
        _fetchData();
        /* final locationData = await getUserModifiedLocation();
      final String calle = locationData['street'] ?? '';
      final String localidad = locationData['locality'] ?? '';
      final String pais = locationData['country'] ?? '';
      locationController.text = '$calle, $localidad, $pais'; */
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Datos actualizados exitosamente!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      print('Actualizado exitoso de datos!');
    } catch (e) {
      print('Error actualizando datos: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error actualizando datos: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  double lat = 0.0;
  double long = 0.0;
  //i want to fetch data from firebase and show it in the textfields

  Future<void> _fetchData() async {
    try {
      // Check if widget.user is not null before proceeding
      if (widget.user != null && controlVentana != true) {
        final DocumentSnapshot documentSnapshot =
            await _registration.doc(widget.user!.uid).get();

        // Check if the document exists
        if (documentSnapshot.exists) {
          fullnameController.text = documentSnapshot['fullname'];
          phoneController.text = documentSnapshot['phone'].toString();
          double latitude = documentSnapshot['lat'] as double;
          double longitude = documentSnapshot['long'] as double;

          print('fullname___________$fullnameController');
          print('phone___________$phoneController');
          print('latitude____________$latitude');
          print('longitude_____________$longitude');

          lat = latitude;
          long = longitude;
/*
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
            locationController.text = 'No se pudo obtener la ubicación.';
          } */
        } else {
          // Handle the case where the document doesn't exist
          print("No existe el documento.");
        }
      } else {
        // Handle the case where widget.user is null
        print("El usuario es nulo.");
      }
    } catch (e) {
      // Handle any other errors that may occur during data retrieval
      print("Error en obtener datos: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<Map<String, String>> getUserModifiedLocation() async {
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        lat,
        long,
      );

      if (placemarks.isNotEmpty) {
        final Placemark placemark = placemarks[0];
        final String calle = placemark.thoroughfare ?? '';
        final String avenida = placemark.subLocality ?? '';
        final String localidad = placemark.locality ?? '';
        final String pais = placemark.country ?? '';

        final String fullStreet =
            avenida.isNotEmpty ? '$calle, $avenida' : calle;

        return {
          'street': fullStreet,
          'locality': localidad,
          'country': pais,
        };
      } else {
        return {
          'street': 'No se pudo obtener la ubicacion',
          'locality': 'No se pudo obtener la ubicacion',
          'country': 'No se pudo obtener la ubicacion',
        };
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error al obtener la ubicacion modificada: $e');
      return {
        'street': 'No se pudo obtener la ubicacion',
        'locality': 'No se pudo obtener la ubicacion',
        'country': 'No se pudo obtener la ubicacion',
      };
    }
  }

  @override
  void dispose() {
    fullnameController.dispose();
    phoneController.dispose();
    latController.dispose();
    longController.dispose();
    super.dispose();
  }

  // bool changesMade = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //safearea avoids the notch area
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 15),
              Row(
                children: [
                  const Header(
                    header: 'Editar Perfil',
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
              FutureBuilder(
                  future: _fetchData(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return Column(
                        children: [
                          const SizedBox(height: 25),
                          MyTextField(
                            controller: fullnameController,
                            text: 'Nombre Completo',
                            hintText: 'Nombre Completo',
                            obscureText: false,
                            isEnabled: true,
                            isVisible: true,
                          ),
                          /* const SizedBox(height: 15),
                        MyTextField(
                          controller: locationController,
                          hintText: 'Ubicación',
                          obscureText: false,
                          isEnabled: false,
                          isVisible: true,
                        ), */
                          FutureBuilder<Map<String, String>>(
                              future: getUserModifiedLocation(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  final locationData = snapshot.data!;
                                  final calle = locationData['street'];
                                  final localidad = locationData['locality'];
                                  final pais = locationData['country'];
                                  return Column(
                                    children: [
                                      /*hidden lat and long*/
                                      const SizedBox(height: 10),
                                      MyTextField(
                                        controller: latController,
                                        text: 'Latitud',
                                        hintText: 'Latitud',
                                        obscureText: false,
                                        isEnabled: false,
                                        isVisible: false,
                                      ),
                                      const SizedBox(height: 10),
                                      MyTextField(
                                        controller: longController,
                                        text: 'Longitud',
                                        hintText: 'Longitud',
                                        obscureText: false,
                                        isEnabled: false,
                                        isVisible: false,
                                      ),
                                      /*hidden lat and long*/
                                      const SizedBox(height: 10),
                                      Text('Calle: $calle'),
                                      Text('Localidad: $localidad'),
                                      Text('Pais: $pais'),
                                    ],
                                  );
                                }
                              }),
                          const SizedBox(height: 10),
                          //seleccionar ubicacion

                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  const Color.fromRGBO(248, 181, 149, 1)),
                            ),
                            onPressed: () async {
                              controlVentana = true;
                              final selectedLocation =
                                  await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const CurrentLocationScreen();
                                  },
                                ),
                              );
                              if (selectedLocation != null &&
                                  selectedLocation is Map<String, double>) {
                                setState(() {
                                  lat = selectedLocation['latitude']!;
                                  long = selectedLocation['longitude']!;
                                });
                                final locationData =
                                    await getUserModifiedLocation();
                                final calle = locationData['street'];
                                final localidad = locationData['locality'];
                                final pais = locationData['country'];
                                latController.text = lat.toString();
                                longController.text = long.toString();
                                print('Lat?????????: ${latController.text}');
                                print('Long????????: ${longController.text}');

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Column(children: [
                                      Text('Calle: $calle'),
                                      Text('Localidad: $localidad'),
                                      Text('Pais: $pais'),
                                    ]),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                // changesMade = true;
                              }
                            },
                            child: const Text('Seleccionar Ubicacion'),
                          ),
                          const SizedBox(height: 15),
                          MyPhoneKeyboard(
                            controller: phoneController,
                            text: 'Telefono',
                            hintText: 'Telefono',
                            obscureText: false,
                            isEnabled: true,
                            isVisible: true,
                          ),

                          const SizedBox(height: 25),

                          MyImportantBtn(
                              onTap: () async {
                                // if (changesMade) {
                                showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (BuildContext context) {
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    });
                                // }

                                // if (changesMade) {
                                await _updateData(
                                  widget.user!.uid,
                                  fullnameController.text,
                                  int.parse(phoneController.text),
                                  double.parse(lat.toString()),
                                  double.parse(long.toString()),
                                );
                                //si se realizaron cambios cerramos el dialogo
                                Navigator.of(context).pop();
                                // }
                              },
                              text: 'Actualizar'),
                        ],
                      );
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
