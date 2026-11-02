import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:odc_talent/core/constants/constant.dart';
import 'package:odc_talent/features/apprenants/models/message_model.dart';
import 'package:odc_talent/features/apprenants/services/messaging_service.dart';

class MessagesRecusPage extends StatefulWidget {
  const MessagesRecusPage({super.key});

  @override
  State<MessagesRecusPage> createState() => _MessagesRecusPageState();
}

class _MessagesRecusPageState extends State<MessagesRecusPage> {
  final MessagingService _messagingService = MessagingService();
  late Future<List<MessageModel>> _messagesFuture;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    _messagesFuture = _messagingService.getMessagesRecus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Boîte de réception', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<List<MessageModel>>(
        future: _messagesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mail_outline, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text('Aucun message reçu pour le moment.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          final messages = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _loadMessages();
              });
            },
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final nomExp = '${msg.prenomExpediteur ?? ''} ${msg.nomExpediteur ?? 'Inconnu'}';

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primaryOrange.withValues(alpha: 0.2),
                    child: Text(
                      nomExp.isNotEmpty ? nomExp[0].toUpperCase() : '?',
                      style: const TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(nomExp, style: TextStyle(fontWeight: msg.lu ? FontWeight.normal : FontWeight.bold)),
                  subtitle: Text(
                    msg.contenu,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    msg.dateEnvoi != null ? msg.dateEnvoi!.substring(0, 10) : '',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  onTap: () {
                    // Naviguer vers la vue de chat détaillée en passant l'ID de l'expéditeur
                    if (msg.expediteurId != null) {
                      context.push('/chat', extra: {
                        'userId': msg.expediteurId,
                        'userName': nomExp,
                      });
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}