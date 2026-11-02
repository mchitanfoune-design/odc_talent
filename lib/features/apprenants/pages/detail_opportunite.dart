import 'package:flutter/material.dart';
import 'package:odc_talent/core/constants/constant.dart';
import 'package:odc_talent/features/apprenants/models/mission_model.dart';
import 'package:odc_talent/features/apprenants/pages/postuler_page.dart';
import 'package:odc_talent/features/apprenants/services/notification_service.dart';
import 'package:odc_talent/features/apprenants/services/opportunite_service.dart';

class DetailOpportunitePage extends StatefulWidget {
  final MissionModel mission;

  const DetailOpportunitePage({super.key, required this.mission});

  @override
  State<DetailOpportunitePage> createState() => _DetailOpportunitePageState();
}

class _DetailOpportunitePageState extends State<DetailOpportunitePage> {
  final OpportuniteService _opportuniteService = OpportuniteService();
  final NotificationApiService _notificationService = NotificationApiService();

  late MissionModel _mission;

  static const Color primaryOrange = AppColors.primaryOrange;

  @override
  void initState() {
    super.initState();
    _mission = widget.mission;
    _refreshMissionDetails();
  }

  Future<void> _refreshMissionDetails() async {
    if (_mission.id == null) return;
    try {
      final updated = await _opportuniteService.getMissionById(_mission.id!);
      if (updated != null && mounted) {
        setState(() => _mission = updated);
      }
    } catch (_) {
      // Conservation des données déjà chargées
    }
  }

  void _openPostulerModal() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PostulerPage(mission: _mission)),
    );
  }

  void _openContactRecruteurModal() {
    if (_mission.recruteurId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact direct non disponible pour cette offre')),
      );
      return;
    }

    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        bool isSending = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('Contacter ${_mission.nomRecruteur ?? "le recruteur"}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Posez une question concernant la mission : "${_mission.titre}"',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: messageController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Écrivez votre message...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: primaryOrange, width: 1.5)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: primaryOrange),
                  onPressed: isSending
                      ? null
                      : () async {
                          if (messageController.text.trim().isEmpty) return;
                          final dialogContext = context;
                          setDialogState(() => isSending = true);
                          try {
                            await _notificationService.envoyerMessage(
                              destinataireId: _mission.recruteurId!,
                              contenu: 'Concernant la mission "${_mission.titre}" : ${messageController.text.trim()}',
                            );
                            if (!dialogContext.mounted) return;
                            if (Navigator.of(dialogContext).canPop()) {
                              Navigator.pop(dialogContext);
                            }
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text('Message envoyé au recruteur !'),
                                backgroundColor: Color(0xFF10B981),
                              ),
                            );
                          } catch (e) {
                            setDialogState(() => isSending = false);
                            if (!dialogContext.mounted) return;
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                            );
                          }
                        },
                  child: isSending
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Envoyer', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Détail de l\'Opportunité',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 1. CARTE PRINCIPALE
            // ==========================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: primaryOrange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _mission.statut ?? 'OUVERTE',
                          style: const TextStyle(color: primaryOrange, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      if (_mission.datePublication != null)
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 13, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              _mission.datePublication!,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Text(
                    _mission.titre,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),

                  // Entreprise / Recruteur
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: primaryOrange.withValues(alpha: 0.15),
                          radius: 20,
                          child: const Icon(Icons.business_rounded, color: primaryOrange, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _mission.nomRecruteur?.isNotEmpty ?? false
                                    ? _mission.nomRecruteur!
                                    : 'Orange Digital Center Partenaire',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              if (_mission.emailRecruteur != null && _mission.emailRecruteur!.isNotEmpty)
                                Text(
                                  _mission.emailRecruteur!,
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Rémunération / Budget
                  Row(
                    children: [
                      const Icon(Icons.payments_outlined, color: primaryOrange, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _mission.budget != null
                            ? 'Rémunération proposée : ${_mission.budget!.toStringAsFixed(0)} FCFA'
                            : 'Rémunération : À négocier',
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==========================================
            // 2. DESCRIPTION DU POSTE
            // ==========================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Description de la mission', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                    _mission.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==========================================
            // 3. COMPÉTENCES REQUISES
            // ==========================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Compétences techniques requises', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (_mission.competencesList.isEmpty)
                    Text('Aucune compétence spécifique spécifiée.', style: TextStyle(color: Colors.grey.shade600, fontSize: 13))
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _mission.competencesList.map((skill) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: primaryOrange.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            skill,
                            style: const TextStyle(color: primaryOrange, fontWeight: FontWeight.w600, fontSize: 12),
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // ==========================================
            // 4. ACTIONS : CONTACTER & POSTULER
            // ==========================================
            Row(
              children: [
                if (_mission.recruteurId != null) ...[
                  OutlinedButton.icon(
                    icon: const Icon(Icons.chat_bubble_outline_rounded, color: primaryOrange, size: 18),
                    label: const Text('Contacter', style: TextStyle(color: primaryOrange, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: primaryOrange),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _openContactRecruteurModal,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: _openPostulerModal,
                      child: const Text(
                        'Postuler maintenant',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
