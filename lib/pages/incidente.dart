// ignore_for_file: use_build_context_synchronously, unnecessary_this, unnecessary_null_comparison, avoid_print, duplicate_ignore, dead_code, unused_local_variable

import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:image_picker/image_picker.dart';

import 'package:miamiga_app/components/headers.dart';
import 'package:miamiga_app/components/limit_characters.dart';
import 'package:miamiga_app/components/my_important_btn.dart';
import 'package:miamiga_app/components/my_textfield.dart';
import 'package:miamiga_app/components/row_button.dart';
import 'package:miamiga_app/model/datos_denunciante.dart';
import 'package:miamiga_app/model/datos_incidente.dart';
import 'package:miamiga_app/pages/denunciante.dart';
import 'package:miamiga_app/pages/map.dart';

class DenunciaIncidente extends StatefulWidget {
  final User? user;
  final IncidentData incidentData;
  final DenuncianteData denuncianteData;

  const DenunciaIncidente({
    super.key,
    required this.user,
    required this.incidentData,
    required this.denuncianteData,
  });

  @override
  State<DenunciaIncidente> createState() => _DenunciaIncidenteState();
}

class _DenunciaIncidenteState extends State<DenunciaIncidente> {
  List<XFile> pickedImages = [];
  String? selectedAudioPath;
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  double sliderValue = 0.0;

  String audioTitle = '';

  bool isImageReceived = false;
  bool isMediaReceived = false;

  DateTime date = DateTime.now();

  final desController = TextEditingController();
  /* final locationController = TextEditingController(); */

  final latController = TextEditingController();
  final longController = TextEditingController();

  @override
  void dispose() {
    desController.dispose();
    latController.dispose();
    longController.dispose();
    audioPlayer.dispose();
    placemarkFromCoordinates(lat, long);
    super.dispose();
  }

  void saveIncidenteData() {
    widget.incidentData.description = desController.text;
    widget.incidentData.date = date;
    try {
      widget.incidentData.lat = double.parse(latController.text);
    } catch (e) {
      print("Error parsing latitude");

      widget.incidentData.lat = 0.0;
    }
    try {
      widget.incidentData.long = double.parse(longController.text);
    } catch (e) {
      print("Error parsing longitude");

      widget.incidentData.long = 0.0;
    }
    if (isImageReceived && pickedImages.isNotEmpty) {
      widget.incidentData.imageUrls = pickedImages.map((e) => e.path).toList();
    } else {
      widget.incidentData.imageUrls = [];
    }
    if (isMediaReceived && selectedAudioPath != null) {
      widget.incidentData.audioUrl = selectedAudioPath!;
    } else {
      widget.incidentData.audioUrl = '';
    }
  }

  void siguiente() async {
    saveIncidenteData();

    print('Descripción: ${widget.incidentData.description}');
    print('Fecha: ${widget.incidentData.date}');
    print('Latitud: ${widget.incidentData.lat}');
    print('Longitud: ${widget.incidentData.long}');
    print('URL de imagen: ${widget.incidentData.imageUrls}');
    print('URL de audio: ${widget.incidentData.audioUrl}');

    try {
      if (this.widget.incidentData.description.isEmpty ||
          this.widget.incidentData.date == null ||
          this.widget.incidentData.lat == 0.0 ||
          this.widget.incidentData.long == 0.0 ||
          !isImageReceived ||
          !isMediaReceived) {
        showErrorMsg(
            context, 'Por favor, ingrese todos los datos del incidente');
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DatosDenunciante(
              user: widget.user,
              incidentData: widget.incidentData,
              denuncianteData: widget.denuncianteData,
            ),
          ),
        );
      }
    } catch (e) {
      // Handle any exceptions that occur during navigation.
      showErrorMsg(context, 'Un error a occurido: $e');
    }
  }

  void showErrorMsg(BuildContext context, String errorMsg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMsg),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future selectImageFile() async {
    print('selectFile: pickedImage: $pickedImages');
    final result = await ImagePicker().pickMultiImage(
      maxWidth: double.infinity,
      maxHeight: double.infinity,
      imageQuality: 80,
    );
    if (result != null) {
      for (var image in result) {
        pickedImages.add(image);
      }
      setState(() {
        isImageReceived = true;
      });
    }
  }

  void cargarImagen() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: 300, // Adjust the width as needed
            height: 300, // Adjust the height as needed
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'Seleccionar Imagen',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    itemCount: pickedImages.length,
                    itemBuilder: (context, index) {
                      final image = pickedImages[index];
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                content: SizedBox(
                                  child: Image.file(
                                    File(image.path),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Image.file(
                          File(image.path),
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),
                if (pickedImages.isEmpty)
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: ElevatedButton.icon(
                      onPressed: selectImageFile,
                      icon: const Icon(
                        Icons.add_a_photo,
                        size: 50,
                      ),
                      label: const SizedBox.shrink(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(0),
                        backgroundColor: const Color.fromRGBO(248, 181, 149, 1),
                      ),
                    ),
                  ),
                if (pickedImages.isNotEmpty)
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          const Color.fromRGBO(248, 181, 149, 1)),
                    ),
                    onPressed: () {
                      selectImageFile();
                    },
                    child: const Text('Agregar otra imagen'),
                  )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> pickAudio() async {
    print('pickAudio: selectedAudioPath: $selectedAudioPath');
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      selectedAudioPath = file.path;

      audioTitle = file.name;

      await audioPlayer.setSourceUrl(selectedAudioPath!);

      duration = (await audioPlayer.getDuration())!;

      setState(() {
        isMediaReceived = true;
      });
    } else {
      // User canceled the picker
      selectedAudioPath = null;
    }
  }

  void cargarAudio() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            width: 300, // Adjust the width as needed
            height: 300, // Adjust the height as needed
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'Seleccionar Audio',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (selectedAudioPath != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Titulo del Audio: $audioTitle',
                        style: const TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  if (selectedAudioPath != null)
                    Column(
                      children: [
                        Slider(
                          value: sliderValue,
                          min: 0.0,
                          max: duration.inSeconds.toDouble(),
                          onChanged: (value) {
                            setState(() {
                              sliderValue = value;
                              audioPlayer
                                  .seek(Duration(seconds: value.toInt()));
                            });
                          },
                        ),
                      ],
                    ),
                  if (selectedAudioPath != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        IconButton(
                          icon:
                              Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                          iconSize: 50.0,
                          onPressed: () {
                            if (isPlaying) {
                              audioPlayer.pause();
                            } else {
                              audioPlayer.resume();
                            }
                            setState(() {
                              isPlaying = !isPlaying;
                            });
                          },
                        ),
                        IconButton(
                          onPressed: () {
                            audioPlayer.stop();
                            setState(() {
                              isPlaying = false;
                              sliderValue = 0.0;
                            });
                          },
                          icon: const Icon(Icons.stop),
                        ),
                      ],
                    ),
                  SizedBox(
                      width: 100,
                      height: 100,
                      child: ElevatedButton.icon(
                        onPressed: pickAudio,
                        icon: const Icon(
                          Icons.music_note,
                          size: 50,
                        ),
                        label: const SizedBox.shrink(),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(0),
                          backgroundColor:
                              const Color.fromRGBO(248, 181, 149, 1),
                        ),
                      )),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  double lat = 0.0;
  double long = 0.0;
  bool controlgetUserMofiedLocation = false;

  Future<Map<String, String>> getUserModifiedLocation() async {
    if (controlgetUserMofiedLocation != false) {
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
      } on PlatformException catch (e) {
        if (e.code == 'NOT_FOUND') {
          // Handle the exception
          print('No address found for the provided coordinates.');
        } else {
          // Re-throw the exception if it's not the one we're handling
          rethrow;
        }
        return {
          'street': 'No se pudo obtener la ubicacion',
          'locality': 'No se pudo obtener la ubicacion',
          'country': 'No se pudo obtener la ubicacion',
        };
      } catch (e) {
        print('Error al obtener la ubicacion modificada: $e');
        return {
          'street': 'No se pudo obtener la ubicacion',
          'locality': 'No se pudo obtener la ubicacion',
          'country': 'No se pudo obtener la ubicacion',
        };
      }
    } else {
      return {
        'street': 'sin ubicación',
        'locality': 'sin ubicación',
        'country': 'sin ubicación',
      };
    }
  }

  bool changesMade = false;

  TimeOfDay timeOfDay = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            // Wrap the content with a Stack
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 15),

                  Row(
                    children: [
                      const Header(
                        header: 'Datos del Incidente',
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

                  // dos botones para subir imagen y audio del incidente en una

                  const SizedBox(height: 25),

                  Row(
                    children: [
                      Expanded(
                        child: RowButton(
                          onTap: cargarImagen,
                          text: 'Imagen',
                          icon: Icons.image,
                        ),
                      ),
                      Expanded(
                        child: RowButton(
                          onTap: cargarAudio,
                          text: 'Audio',
                          icon: Icons.audio_file,
                        ),
                      ),
                    ],
                  ),

                  //campo de descripcion del incidente

                  const SizedBox(height: 25),

                  LimitCharacter(
                    controller: desController,
                    text:
                        'Descripción del Incidente', // 'Descripción del Incidente
                    hintText: 'Descripción del Incidente',
                    obscureText: false,
                    isEnabled: true,
                    isVisible: true,
                  ),

                  //campo de fecha del incidente

                  const SizedBox(height: 15),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Seleccionar Fecha del Incidente',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '${date.year}/${date.month}/${date.day}',
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                const Color.fromRGBO(248, 181, 149, 1)),
                          ),
                          child: const Text('Seleccionar Fecha'),
                          onPressed: () async {
                            DateTime? selectedDate = await showDatePicker(
                              context: context,
                              initialDate: date,
                              firstDate: DateTime(1900),
                              lastDate: DateTime(2100),
                              builder: (BuildContext context, Widget? child) {
                                return Theme(
                                  data: ThemeData.dark().copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: Color.fromRGBO(248, 181, 149, 1),
                                      onPrimary: Colors.black,
                                      surface: Color.fromRGBO(248, 181, 149, 1),
                                      onSurface: Colors.white,
                                    ),
                                    dialogBackgroundColor: Colors.black,
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (selectedDate == null) return;

                            // Create a new DateTime object with the selected date and the fixed time
                            DateTime selectedDateTime = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day,
                              timeOfDay.hour,
                              timeOfDay.minute,
                            );

                            setState(() {
                              date = selectedDateTime;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  //campo de lugar de incidente

                  const SizedBox(height: 15),

                  FutureBuilder<Map<String, String>>(
                      future: getUserModifiedLocation(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator(
                            color: Color.fromRGBO(255, 87, 110, 1),
                          ));
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

                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          const Color.fromRGBO(248, 181, 149, 1)),
                    ),
                    onPressed: () async {
                      controlgetUserMofiedLocation = true;
                      final selectedLocation = await Navigator.of(context).push(
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
                        final locationData = await getUserModifiedLocation();
                        final calle = locationData['street'];
                        final localidad = locationData['locality'];
                        final pais = locationData['country'];
                        latController.text = lat.toString();
                        longController.text = long.toString();
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
                        changesMade = true;
                      }
                    },
                    child: const Text('Seleccionar Ubicacion'),
                  ),

                  //boton de siguiente

                  const SizedBox(height: 25),

                  MyImportantBtn(
                    onTap: siguiente,
                    text: 'Siguiente',
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
