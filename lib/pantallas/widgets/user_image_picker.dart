import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// ignore: must_be_immutable
class UserImagePicker extends StatefulWidget {
   UserImagePicker({super.key, required this.onPickedImage});

  void Function(File fotoCapturada) onPickedImage;

  @override
  State<UserImagePicker> createState() {
    return _UserImagePickerState();
  }
}

class _UserImagePickerState extends State<UserImagePicker> {
File? _fotoGuardadaFile;

void _tomarFoto() async {
 final fotoTomada = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 50, maxWidth: 150);

 if(fotoTomada == null){
  return;
 }

setState(() {
  _fotoGuardadaFile = File(fotoTomada.path);
});
 widget.onPickedImage(_fotoGuardadaFile!);
}

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage: _fotoGuardadaFile != null ? FileImage(_fotoGuardadaFile!) : null,
        ),
        TextButton.icon(
            onPressed: _tomarFoto,
            icon: const Icon(Icons.image),
            label: Text("Subir Imagen",
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ))
      ],
    );
  }
}
