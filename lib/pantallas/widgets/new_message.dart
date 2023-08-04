import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});
  @override
  State<NewMessage> createState() {
    return _NewMessageState();
  }
}

class _NewMessageState extends State<NewMessage> {
  var _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
  
  void _enviarMensaje() async {
  final mensajeIngresado = _messageController.text;

  if(mensajeIngresado.trim().isEmpty){
    return;
  }
   _messageController.clear();
  final user = FirebaseAuth.instance.currentUser!;

  final userData = await FirebaseFirestore.instance.collection("users").doc(user.uid).get();

  FirebaseFirestore.instance.collection("chat").add({
    "text": mensajeIngresado,
    "hora": Timestamp.now(),
    "userId": user.uid,
    "userName": userData.data()!["nombreDeUsuario"],
    "userImage": userData.data()!["imageUrl"]
  });

  
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
        child: Row(
          children: [
             Expanded(
              child: TextField(
                controller: _messageController,
                textCapitalization: TextCapitalization.sentences,
                autocorrect: true,
                enableSuggestions: true,
                decoration: const InputDecoration(labelText: "Enviar Mensaje"),
              ),
            ),
            IconButton(
              color: Theme.of(context).colorScheme.primary,
              onPressed: _enviarMensaje,
              icon: const Icon(Icons.send),
            ),
          ],
        ));
  }
}
