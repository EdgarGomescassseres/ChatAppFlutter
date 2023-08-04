import 'package:chat_app/pantallas/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessage extends StatelessWidget {
  const ChatMessage({super.key});
  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("chat")
            .orderBy("hora", descending: true)
            .snapshots(),
        builder: (ctx, chatSnapshot) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No se han cargado mensajes"),
            );
          }

          if (chatSnapshot.hasError) {
            return const Center(
              child: Text("Algo salio mal :c"),
            );
          }

          final cargandoMensajes = chatSnapshot.data!.docs;

          return ListView.builder(
              padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
              reverse: true,
              itemCount: cargandoMensajes.length,
              itemBuilder: (ctx, index) {
                final chatMessage = cargandoMensajes[index].data();
                final nextChatMessage = index + 1 < cargandoMensajes.length
                    ? cargandoMensajes[index + 1].data()
                    : null;
                
                final currentMessageUserId = chatMessage["userId"];
                final nextMessageUserId = nextChatMessage != null ? nextChatMessage["userId"] : null;
                final nextUserIsSame = nextMessageUserId == currentMessageUserId;
                if(nextUserIsSame){
                  return MessageBubble.next(message: chatMessage["text"], isMe: authenticatedUser.uid == currentMessageUserId);
                }else {
                  return MessageBubble.first(userImage: chatMessage["userImage"], username: chatMessage["userName"], message: chatMessage["text"], isMe: authenticatedUser.uid == currentMessageUserId);
                }
              }); 
        });
  }
}
