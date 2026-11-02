import 'package:flutter/material.dart';
import 'package:odc_talent/core/constants/constant.dart';
import 'package:odc_talent/features/apprenants/models/evolution_pro_model.dart';
import 'package:odc_talent/features/apprenants/services/suivi_service.dart';

class EvolutionProPage extends StatefulWidget {
  const EvolutionProPage({Key? key}) : super(key: key);

  @override
  State<EvolutionProPage> createState() => _EvolutionProPageState();
}

class _EvolutionProPageState extends State<EvolutionProPage> {
  final SuiviApiService _suiviService = SuiviApiService();

  bool _isLoading = true;
  String? _errorMessage;

  List<EvolutionProModel> _historique = [];

  static const Color primaryOrange = AppColors.primaryOrange;
  static const Color darkNavy = Color(0xFF03152F);

  @override
  void initState() {
    super.initState();
    _loadEvolutionData();
  }

  Future<void> _loadEvolutionData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final historique = await _suiviService.getMonHistorique();
      if (mounted) {
        setState(() {
          _historique = historique;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Impossible de joindre le serveur pour votre historique.";
          // Données d'exemple informatives si la base est vide ou hors-ligne
          if (_historique.isEmpty) {
            _historique = [
              EvolutionProModel(
                id: 1,
                poste: "Développeur Mobile Flutter",
                entreprise: "Orange Digital Center",
                statutEmploi: "STAGE",
                localisation: "Bamako, Mali",
                dateDebut: "2026-06-01",
                dateFin: null, // Poste actuel
              ),
              EvolutionProModel(
                id: 2,
                poste: "Apprenant en Développement Web & Mobile",
                entreprise: "ODC Club / Académie",
                statutEmploi: "FORMATION",
                localisation: "Bamako, Mali",
                dateDebut: "2026-01-15",
                dateFin: "2026-05-30",
              ),
            ];
          }
        });
      }
    }
  }

  void _openAddEvolutionModal() {
    final posteController = TextEditingController();
    final entrepriseController = TextEditingController();
    final localisationController = TextEditingController(text: "Bamako, Mali");
    final dateDebutController = TextEditingController(text: DateTime.now().toString().substring(0, 10));
    final dateFinController = TextEditingController();

    String selectedStatut = 'CDI';
    bool isCurrentJob = true;

    final List<String> statuts = ['CDI', 'CDD', 'STAGE', 'FREELANCE', 'FORMATION', 'EN_RECHERCHE'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        bool isSubmitting = false;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Mettre à jour ma situation',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Permet à l\'équipe ODC de suivre votre insertion professionnelle.',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 18),

                    _buildField('Intitulé du poste *', posteController, 'ex: Développeur Flutter'),
                    _buildField('Entreprise ou Organisation *', entrepriseController, 'ex: Orange Digital Center / Entreprise'),

                    // Type de contrat
                    const Text('Type de statut / contrat *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedStatut,
                          isExpanded: true,
                          items: statuts.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (val) {
                            if (val != null) setModalState(() => selectedStatut = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    _buildField('Localisation *', localisationController, 'ex: Bamako, Mali / Télétravail'),
                    _buildField('Date de début (AAAA-MM-JJ) *', dateDebutController, '2026-01-01'),

                    // Checkbox poste actuel
                    Row(
                      children: [
                        Checkbox(
                          value: isCurrentJob,
                          activeColor: primaryOrange,
                          onChanged: (val) {
                            setModalState(() {
                              isCurrentJob = val ?? true;
                              if (isCurrentJob) dateFinController.clear();
                            });
                          },
                        ),
                        const Text('C\'est mon poste actuel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      ],
                    ),

                    if (!isCurrentJob) ...[
                      _buildField('Date de fin (AAAA-MM-JJ)', dateFinController, '2026-12-31'),
                    ],

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryOrange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (posteController.text.trim().isEmpty || entrepriseController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Veuillez renseigner le poste et l\'entreprise')),
                                  );
                                  return;
                                }

                                setModalState(() => isSubmitting = true);
                                try {
                                  await _suiviService.ajouterMonEvolution(
                                    poste: posteController.text.trim(),
                                    entreprise: entrepriseController.text.trim(),
                                    statutEmploi: selectedStatut,
                                    localisation: localisationController.text.trim(),
                                    dateDebut: dateDebutController.text.trim(),
                                    dateFin: isCurrentJob ? null : dateFinController.text.trim(),
                                  );

                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    _loadEvolutionData();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Situation mise à jour avec succès !'),
                                        backgroundColor: Color(0xFF10B981),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  setModalState(() => isSubmitting = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                                  );
                                }
                              },
                        child: isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Enregistrer mon évolution', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: primaryOrange, width: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentJob = _historique.isNotEmpty && _historique.first.isCurrentJob ? _historique.first : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Mon Évolution Pro',
          style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 16, color: Colors.white),
              label: const Text('Mettre à jour', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _openAddEvolutionModal,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: primaryOrange,
        onRefresh: _loadEvolutionData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // 1. CARTE SITUATION ACTUELLE
              // ==========================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [darkNavy, Color(0xFF0F2B56)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: darkNavy.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
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
                            color: primaryOrange.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: primaryOrange.withOpacity(0.5)),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.stars_rounded, color: primaryOrange, size: 14),
                              SizedBox(width: 4),
                              Text('Poste Actuel', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        if (currentJob != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              currentJob.statutEmploi,
                              style: const TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Text(
                      currentJob != null ? currentJob.poste : 'Apprenant ODC en recherche',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currentJob != null ? currentJob.entreprise : 'Orange Digital Center',
                      style: TextStyle(color: Colors.blue.shade200, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          currentJob != null ? currentJob.localisation : 'Bamako, Mali',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(width: 14),
                        const Icon(Icons.calendar_today_outlined, color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          currentJob?.dateDebut != null ? 'Depuis ${currentJob!.dateDebut}' : 'En cours',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

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

              // ==========================================
              // 2. HISTORIQUE / TIMELINE DU PARCOURS
              // ==========================================
              const Text(
                'Parcours & Insertion ODC',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                'Historique de vos étapes professionnelles depuis votre formation.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 16),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator(color: primaryOrange)),
                )
              else if (_historique.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.timeline_rounded, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text('Aucune étape enregistrée', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('Renseignez votre premier emploi ou stage après ODC.', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _historique.length,
                  itemBuilder: (context, index) {
                    final item = _historique[index];
                    final isLast = index == _historique.length - 1;
                    return _buildTimelineItem(item, isLast);
                  },
                ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem(EvolutionProModel item, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ligne & point vertical de la timeline
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: item.isCurrentJob ? primaryOrange : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: primaryOrange, width: 3),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Colors.grey.shade300,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),

          // Contenu de l'étape
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.poste,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: primaryOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.statutEmploi,
                            style: const TextStyle(color: primaryOrange, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    Text(
                      item.entreprise,
                      style: TextStyle(fontSize: 13, color: Colors.blue.shade700, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),

                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 12, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(item.localisation, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                        const SizedBox(width: 12),
                        Icon(Icons.date_range_outlined, size: 12, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          '${item.dateDebut ?? "?"} → ${item.dateFin ?? "Actuel"}',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
