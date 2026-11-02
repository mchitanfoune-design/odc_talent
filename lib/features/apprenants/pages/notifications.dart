// lib/features/apprenants/pages/notifications.dart
import 'package:flutter/material.dart';
import 'package:odc_talent/core/constants/constant.dart';
import 'package:odc_talent/features/apprenants/models/notification_model.dart';
import 'package:odc_talent/features/apprenants/services/notification_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationApiService _notificationService = NotificationApiService();

  bool _isLoading = true;
  String? _errorMessage;

  List<NotificationModel> _allNotifications = [];
  List<NotificationModel> _filteredNotifications = [];

  bool _showOnlyUnread = false;

  static const Color primaryOrange = AppColors.primaryOrange;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final notifications = await _notificationService.getMyNotifications();
      if (mounted) {
        setState(() {
          _allNotifications = notifications;
          _applyFilter();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Impossible de joindre le serveur pour vos notifications.";
          
          // Fallback informatif local si échec de connexion
          if (_allNotifications.isEmpty) {
            _allNotifications = [
              NotificationModel(
                id: 1,
                titre: "Bienvenue sur ODCTalent",
                message: "Félicitations pour votre intégration ! Pensez à compléter votre portfolio et vos compétences.",
                type: "SYSTEM",
                lue: false,
                dateCreation: "2026-11-01T10:30:00",
              ),
              NotificationModel(
                id: 2,
                titre: "Consultation de profil",
                message: "Votre profil a été consulté par une entreprise partenaire.",
                type: "RECRUTEUR",
                lue: true,
                dateCreation: "2026-10-31T16:45:00",
              ),
            ];
            _applyFilter();
          }
        });
      }
    }
  }

  void _applyFilter() {
    setState(() {
      if (_showOnlyUnread) {
        _filteredNotifications = _allNotifications.where((n) => !n.lue).toList();
      } else {
        _filteredNotifications = _allNotifications;
      }
    });
  }

  Future<void> _markAsReadAndOpen(NotificationModel notification) async {
    // Si la notification n'est pas encore lue, on appelle l'API pour la marquer comme lue
    if (!notification.lue) {
      try {
        await _notificationService.marquerCommeLue(notification.id);
        setState(() {
          // Mettre à jour localement l'état de la notification
          final index = _allNotifications.indexWhere((n) => n.id == notification.id);
          if (index != -1) {
            _allNotifications[index] = NotificationModel(
              id: notification.id,
              titre: notification.titre,
              message: notification.message,
              type: notification.type,
              referenceId: notification.referenceId,
              lue: true,
              dateCreation: notification.dateCreation,
            );
            _applyFilter();
          }
        });
      } catch (_) {
        // Ignorer l'erreur réseau silencieusement sur le patch si besoin
      }
    }

    // Afficher la boîte de dialogue avec les détails
    if (!mounted) return;
    _openNotificationDetailsDialog(notification);
  }

  void _openNotificationDetailsDialog(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(22),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: primaryOrange.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_active_rounded, color: primaryOrange, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.titre,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    if (notification.dateCreation != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        notification.dateCreation!.replaceFirst('T', ' '),
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text(
                  notification.message,
                  style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _allNotifications.where((n) => !n.lue).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            const Text(
              'Notifications',
              style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: primaryOrange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ChoiceChip(
              label: Text(
                _showOnlyUnread ? 'Non lues' : 'Toutes',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _showOnlyUnread ? Colors.white : Colors.black87,
                ),
              ),
              selected: _showOnlyUnread,
              selectedColor: primaryOrange,
              backgroundColor: Colors.grey.shade100,
              onSelected: (val) {
                setState(() {
                  _showOnlyUnread = val;
                  _applyFilter();
                });
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: primaryOrange,
        onRefresh: _loadNotifications,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 18, color: Colors.orange.shade800),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_errorMessage!, style: TextStyle(fontSize: 12, color: Colors.orange.shade900)),
                      ),
                    ],
                  ),
                ),
              ],

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 50),
                  child: Center(child: CircularProgressIndicator(color: primaryOrange)),
                )
              else if (_filteredNotifications.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(36),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.notifications_none_rounded, size: 50, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text('Aucune notification pour le moment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(
                        'Vous recevrez ici les alertes et messages importants de l\'équipe ODC.',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredNotifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _filteredNotifications[index];
                    return _buildNotificationCard(item);
                  },
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return InkWell(
      onTap: () => _markAsReadAndOpen(notification),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.lue ? Colors.white : const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notification.lue ? Colors.grey.shade200 : primaryOrange.withValues(alpha: 0.3),
            width: notification.lue ? 1 : 1.5,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: notification.lue ? const Color(0xFFF1F5F9) : primaryOrange.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                notification.lue ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
                color: notification.lue ? Colors.grey.shade600 : primaryOrange,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.titre,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: notification.lue ? FontWeight.w600 : FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!notification.lue)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: primaryOrange,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: notification.lue ? Colors.grey.shade600 : Colors.black87,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (notification.dateCreation != null)
                        Text(
                          notification.dateCreation!.replaceFirst('T', ' '),
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                      const Text(
                        'Lire la suite >',
                        style: TextStyle(fontSize: 11, color: primaryOrange, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}