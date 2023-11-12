import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageModal extends StatefulWidget {
  final List<XFile> pickedImages;
  final Future<List<XFile>> Function() onImagesSelected;

  ImageModal({required this.pickedImages, required this.onImagesSelected});

  @override
  _ImageModalState createState() => _ImageModalState();
}

class _ImageModalState extends State<ImageModal> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: 300,
        height: 300,
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
                itemCount: widget.pickedImages.length,
                itemBuilder: (context, index) {
                  final image = widget.pickedImages[index];
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
            if (widget.pickedImages.isEmpty)
              SizedBox(
                width: 100,
                height: 100,
                child: ElevatedButton.icon(
                  onPressed: () {
                    widget.onImagesSelected().then((List<XFile> newImages) {
                      setState(() {
                        widget.pickedImages.addAll(newImages);
                      });
                    });
                  },
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
            if (widget.pickedImages.isNotEmpty)
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                      const Color.fromRGBO(248, 181, 149, 1)),
                ),
                onPressed: () {
                  widget.onImagesSelected().then((List<XFile> newImages) {
                    setState(() {
                      widget.pickedImages.addAll(newImages);
                    });
                  });
                },
                child: const Text('Agregar otra imagen'),
              )
          ],
        ),
      ),
    );
  }
}
