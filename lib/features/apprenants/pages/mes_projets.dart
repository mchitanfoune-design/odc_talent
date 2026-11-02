import 'package:flutter/material.dart';
import 'package:odc_talent/core/constants/constant.dart';
import 'package:odc_talent/features/apprenants/models/projet_response_model.dart';
import 'package:odc_talent/features/apprenants/services/projet_service.dart';

class MesProjetsPage extends StatefulWidget {
  const MesProjetsPage({Key? key}) : super(key: key);

  @override
  State<MesProjetsPage> createState() => _MesProjetsPageState();
}

class _MesProjetsPageState extends State<MesProjetsPage> {
  final ProjetApiService _projetService = ProjetApiService();

  bool _isLoading = true;
  String? _errorMessage;

  List<ProjetResponseModel> _allProjets = [];
  List<ProjetResponseModel> _filteredProjets = [];

  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Tous';
  final List<String> _categories = ['Tous', 'Mobile', 'Web', 'Backend', 'IA & Data'];

  static const Color primaryOrange = AppColors.primaryOrange;
  static const Color darkNavy = Color(0xFF03152F);

  @override
  void initState() {
    super.initState();
    _loadProjets();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProjets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final projets = await _projetService.getMyProjets();
      if (mounted) {
        setState(() {
          _allProjets = projets;
          _filterProjets();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Impossible de joindre le serveur pour vos projets.";
          // Fallback informatif pour le rendu initial
          if (_allProjets.isEmpty) {
            _allProjets = [
              ProjetResponseModel(
                id: 1,
                titre: "Application Mobile ODCTalent",
                description: "Plateforme mobile d'interconnexion entre apprenants ODC et recruteurs partenaires.",
                technologies: "Flutter, Dart, Spring Boot, MySQL",
                githubUrl: "https://github.com/odc/odctalent-flutter",
                demoUrl: "https://odctalent.orange.com",
                dateCreation: "2026-11-01",
              ),
              ProjetResponseModel(
                id: 2,
                titre: "API Backend Microservices",
                description: "Architecture REST sécurisée par JWT, Spring Security et intégration Docker.",
                technologies: "Java, Spring Boot, Docker, JWT",
                githubUrl: "https://github.com/odc/odctalent-backend",
                dateCreation: "2026-10-25",
              ),
            ];
            _filterProjets();
          }
        });
      }
    }
  }

  void _filterProjets() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredProjets = _allProjets.where((projet) {
        final matchQuery = query.isEmpty ||
            projet.titre.toLowerCase().contains(query) ||
            projet.description.toLowerCase().contains(query) ||
            projet.technologies.toLowerCase().contains(query);

        final matchCategory = _selectedCategory == 'Tous' ||
            projet.technologies.toLowerCase().contains(_selectedCategory.toLowerCase()) ||
            projet.titre.toLowerCase().contains(_selectedCategory.toLowerCase());

        return matchQuery && matchCategory;
      }).toList();
    });
  }

  void _openProjectFormModal({ProjetResponseModel? projectToEdit}) {
    final isEditing = projectToEdit != null;
    final titreController = TextEditingController(text: projectToEdit?.titre ?? '');
    final descController = TextEditingController(text: projectToEdit?.description ?? '');
    final techController = TextEditingController(text: projectToEdit?.technologies ?? '');
    final githubController = TextEditingController(text: projectToEdit?.githubUrl ?? '');
    final demoController = TextEditingController(text: projectToEdit?.demoUrl ?? '');
    final imageController = TextEditingController(text: projectToEdit?.imageUrl ?? '');

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
                    Text(
                      isEditing ? 'Modifier le projet' : 'Ajouter un nouveau projet',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    _buildField('Titre du projet *', titreController, 'ex: Système de gestion ODC'),
                    _buildField('Description *', descController, 'Objectif et réalisations clés...', maxLines: 3),
                    _buildField('Technologies utilisées *', techController, 'Flutter, Spring Boot, MySQL, Docker'),
                    _buildField('Lien GitHub', githubController, 'https://github.com/...'),
                    _buildField('Lien Démo en ligne', demoController, 'https://monprojet.com'),
                    _buildField('URL Image / Aperçu', imageController, 'https://.../preview.png'),

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
                                if (titreController.text.trim().isEmpty ||
                                    descController.text.trim().isEmpty ||
                                    techController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Veuillez remplir les champs obligatoires (*)')),
                                  );
                                  return;
                                }

                                setModalState(() => isSubmitting = true);
                                try {
                                  if (isEditing && projectToEdit.id != null) {
                                    await _projetService.updateProjet(
                                      id: projectToEdit.id!,
                                      titre: titreController.text.trim(),
                                      description: descController.text.trim(),
                                      technologies: techController.text.trim(),
                                      githubUrl: githubController.text.trim(),
                                      demoUrl: demoController.text.trim(),
                                      imageUrl: imageController.text.trim(),
                                    );
                                  } else {
                                    await _projetService.createProjet(
                                      titre: titreController.text.trim(),
                                      description: descController.text.trim(),
                                      technologies: techController.text.trim(),
                                      githubUrl: githubController.text.trim(),
                                      demoUrl: demoController.text.trim(),
                                      imageUrl: imageController.text.trim(),
                                    );
                                  }

                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    _loadProjets();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(isEditing ? 'Projet modifié !' : 'Nouveau projet ajouté !'),
                                        backgroundColor: const Color(0xFF10B981),
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
                            : Text(
                                isEditing ? 'Sauvegarder les modifications' : 'Enregistrer le projet',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
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

  void _confirmDelete(ProjetResponseModel projet) {
    if (projet.id == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer ce projet ?'),
        content: Text('Voulez-vous vraiment supprimer "${projet.titre}" ? Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _projetService.deleteProjet(projet.id!);
                _loadProjets();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Projet supprimé'), backgroundColor: Colors.black87),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            maxLines: maxLines,
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            const Text(
              'Mes Projets',
              style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: primaryOrange.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_filteredProjets.length}',
                style: const TextStyle(color: primaryOrange, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              label: const Text('Nouveau', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => _openProjectFormModal(),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: primaryOrange,
        onRefresh: _loadProjets,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barre de recherche
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => _filterProjets(),
                  decoration: InputDecoration(
                    hintText: 'Rechercher un projet, technologie...',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: primaryOrange, size: 22),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _filterProjets();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Chips de catégories
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = cat;
                          _filterProjets();
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? darkNavy : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: isSelected ? darkNavy : Colors.grey.shade300),
                        ),
                        child: Center(
                          child: Text(
                            cat,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

              const SizedBox(height: 16),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator(color: primaryOrange)),
                )
              else if (_filteredProjets.isEmpty)
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
                      Icon(Icons.folder_open_outlined, size: 52, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text('Aucun projet trouvé', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 6),
                      Text(
                        'Cliquez sur "+ Nouveau" pour publier votre première réalisation sur ODCTalent.',
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
                  itemCount: _filteredProjets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final projet = _filteredProjets[index];
                    return _buildProjetCard(projet);
                  },
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjetCard(ProjetResponseModel projet) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bandeau supérieur avec icône et date
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: primaryOrange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.code_rounded, color: primaryOrange, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      projet.dateCreation ?? 'Projet ODC',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz, color: Colors.grey),
                  onSelected: (val) {
                    if (val == 'edit') {
                      _openProjectFormModal(projectToEdit: projet);
                    } else if (val == 'delete') {
                      _confirmDelete(projet);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18, color: Colors.black87),
                          SizedBox(width: 8),
                          Text('Modifier'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Supprimer', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  projet.titre,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 6),
                Text(
                  projet.description,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.3),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Technologies
                if (projet.technologiesList.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: projet.technologiesList.map((t) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF334155))),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Liens Démo & GitHub
                Row(
                  children: [
                    if (projet.githubUrl != null && projet.githubUrl!.isNotEmpty) ...[
                      OutlinedButton.icon(
                        icon: const Icon(Icons.code_rounded, size: 15, color: Colors.black87),
                        label: const Text('GitHub', style: TextStyle(color: Colors.black87, fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Lien GitHub: ${projet.githubUrl}')),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (projet.demoUrl != null && projet.demoUrl!.isNotEmpty) ...[
                      ElevatedButton.icon(
                        icon: const Icon(Icons.launch_rounded, size: 14, color: Colors.white),
                        label: const Text('Démo', style: TextStyle(color: Colors.white, fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryOrange,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Démo en ligne: ${projet.demoUrl}')),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
