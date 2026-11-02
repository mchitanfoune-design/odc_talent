import 'package:flutter/material.dart';
import 'package:odc_talent/core/constants/constant.dart';
import 'package:odc_talent/features/apprenants/models/portfolio_response_model.dart';
import 'package:odc_talent/features/apprenants/models/projet_response_model.dart';
import 'package:odc_talent/features/apprenants/services/dashboardService.dart';
import 'package:odc_talent/features/apprenants/services/portfolio.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({Key? key}) : super(key: key);

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  final PortfolioService _portfolioService = PortfolioService();
  final DashboardService _dashboardService = DashboardService();

  bool _isLoading = true;
  String? _errorMessage;
  String _selectedLanguage = 'Français';

  PortfolioResponseModel? _portfolio;
  List<ProjetResponseModel> _projets = [];

  // Informations de secours si le portfolio n'a pas encore été créé dans Spring Boot
  String _nomFallback = "";
  String _prenomFallback = "";
  String _emailFallback = "";

  static const Color darkNavy = Color(0xFF03152F);
  static const Color primaryOrange = AppColors.primaryOrange;

  @override
  void initState() {
    super.initState();
    _loadPortfolioData();
  }

  Future<void> _loadPortfolioData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Récupération des informations de session locales
      final session = await _dashboardService.getUserSession();
      _prenomFallback = session['prenom'] ?? '';
      _nomFallback = session['nom'] ?? '';
      _emailFallback = session['email'] ?? '';

      // 2. Récupération du portfolio depuis GET /api/v1/portfolios/me
      final portfolio = await _portfolioService.getMyPortfolio();

      if (portfolio != null) {
        _portfolio = portfolio;

        // 3. Récupération des projets si le portfolio existe
        if (portfolio.id != null) {
          final projets = await _portfolioService.getProjetsByPortfolio(portfolio.id!);
          _projets = projets;
        }
      } else {
        // Portfolio pas encore initialisé côté backend : initialisation avec données utilisateur
        _portfolio = PortfolioResponseModel(
          bio: "Bienvenue sur mon portfolio ! Je suis apprenant chez Orange Digital Center.",
          titreProfessionnel: "Développeur Web & Mobile",
          competences: "Flutter, Dart, Spring Boot, MySQL, Git",
          nomApprenant: _nomFallback.isNotEmpty ? _nomFallback : "Apprenant",
          prenomApprenant: _prenomFallback.isNotEmpty ? _prenomFallback : "ODC",
          emailApprenant: _emailFallback,
        );
      }
    } catch (e) {
      _errorMessage = "Impossible de synchroniser avec le serveur.";
      // Données de secours locales
      _portfolio ??= PortfolioResponseModel(
        bio: "Passionné par les technologies modernes, je conçois et développe des applications web et mobiles innovantes.",
        titreProfessionnel: "Développeur Full Stack",
        competences: "Flutter, Java, Spring Boot, Docker, Git",
        nomApprenant: _nomFallback.isNotEmpty ? _nomFallback : "ODC",
        prenomApprenant: _prenomFallback.isNotEmpty ? _prenomFallback : "Talent",
        emailApprenant: _emailFallback.isNotEmpty ? _emailFallback : "apprenant@odc.com",
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showEditPortfolioModal() {
    final titreController = TextEditingController(text: _portfolio?.titreProfessionnel ?? '');
    final bioController = TextEditingController(text: _portfolio?.bio ?? '');
    final competencesController = TextEditingController(text: _portfolio?.competences ?? '');
    final githubController = TextEditingController(text: _portfolio?.githubUrl ?? '');
    final linkedinController = TextEditingController(text: _portfolio?.linkedinUrl ?? '');
    final websiteController = TextEditingController(text: _portfolio?.websiteUrl ?? '');

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Modifier mon portfolio',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildEditField('Titre Professionnel', titreController, 'ex: Développeur Flutter & Spring Boot'),
                    _buildEditField('À propos (Bio)', bioController, 'Présentez-vous en quelques lignes...', maxLines: 3),
                    _buildEditField('Compétences (séparées par virgule)', competencesController, 'Flutter, Spring Boot, Java, MySQL'),
                    _buildEditField('Lien GitHub', githubController, 'https://github.com/votre-compte'),
                    _buildEditField('Lien LinkedIn', linkedinController, 'https://linkedin.com/in/votre-compte'),
                    _buildEditField('Site Web / Portfolio', websiteController, 'https://monportfolio.com'),

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
                                setModalState(() => isSubmitting = true);
                                try {
                                  await _portfolioService.updateMyPortfolio(
                                    titreProfessionnel: titreController.text.trim(),
                                    bio: bioController.text.trim(),
                                    competences: competencesController.text.trim(),
                                    githubUrl: githubController.text.trim(),
                                    linkedinUrl: linkedinController.text.trim(),
                                    websiteUrl: websiteController.text.trim(),
                                  );
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    _loadPortfolioData();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Portfolio mis à jour avec succès !'),
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
                            : const Text('Enregistrer les modifications', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  void _showAddProjectModal() {
    final titreController = TextEditingController();
    final descController = TextEditingController();
    final techController = TextEditingController();
    final demoController = TextEditingController();
    final githubController = TextEditingController();

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
                      'Ajouter un projet au portfolio',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),

                    _buildEditField('Nom du projet', titreController, 'ex: ODCTalent Mobile App'),
                    _buildEditField('Description', descController, 'Objectifs et fonctionnalités du projet...', maxLines: 2),
                    _buildEditField('Technologies utilisées', techController, 'Flutter, Spring Boot, MySQL'),
                    _buildEditField('Lien GitHub', githubController, 'https://github.com/projet'),
                    _buildEditField('Lien Démo / Vidéo', demoController, 'https://youtube.com/...'),

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
                                if (titreController.text.trim().isEmpty) return;
                                setModalState(() => isSubmitting = true);
                                try {
                                  await _portfolioService.addProjet(
                                    titre: titreController.text.trim(),
                                    description: descController.text.trim(),
                                    technologies: techController.text.trim(),
                                    githubUrl: githubController.text.trim(),
                                    demoUrl: demoController.text.trim(),
                                  );
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    _loadPortfolioData();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Projet ajouté avec succès !'),
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
                            : const Text('Ajouter le projet', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  Widget _buildEditField(String label, TextEditingController controller, String hint, {int maxLines = 1}) {
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
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: primaryOrange, width: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials() {
    String p = (_portfolio?.prenomApprenant.isNotEmpty ?? false) ? _portfolio!.prenomApprenant[0].toUpperCase() : 'O';
    String n = (_portfolio?.nomApprenant.isNotEmpty ?? false) ? _portfolio!.nomApprenant[0].toUpperCase() : 'D';
    return '$p$n';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: primaryOrange)),
      );
    }

    final p = _portfolio;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          color: primaryOrange,
          onRefresh: _loadPortfolioData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            child: Column(
              children: [
                // ==========================================
                // 1. HEADER BLEU NUIT (PROFIL & EN-TÊTE)
                // ==========================================
                Container(
                  color: darkNavy,
                  padding: const EdgeInsets.only(
                    top: 52,
                    left: 20,
                    right: 20,
                    bottom: 24,
                  ),
                  child: Column(
                    children: [
                      // Barre supérieure : Retour, Switcher langue & Bouton modifier
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                          _buildLanguageToggle(),
                          IconButton(
                            icon: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 26),
                            tooltip: 'Modifier mon portfolio',
                            onPressed: _showEditPortfolioModal,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Avatar, Nom & Titre
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar dynamique
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [primaryOrange, Color(0xFFFF9248)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(color: Colors.white, width: 2.5),
                            ),
                            child: Center(
                              child: Text(
                                _getInitials(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${p?.prenomApprenant ?? ""} ${p?.nomApprenant ?? ""}'.trim(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  p?.titreProfessionnel ?? 'Apprenant ODC',
                                  style: const TextStyle(
                                    color: Color(0xFF60A5FA),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  p?.bio.isNotEmpty ?? false
                                      ? p!.bio
                                      : 'Apprenant passionné par l\'innovation digitale et le développement d\'applications.',
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 12,
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Métadonnées (Email, Localisation, Statut)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildHeaderMeta(Icons.mail_outline_rounded, p?.emailApprenant.isNotEmpty ?? false ? p!.emailApprenant : 'Email ODC'),
                          _buildHeaderMeta(Icons.location_on_outlined, 'Mali, Bamako'),
                          _buildHeaderMeta(Icons.verified_user_outlined, 'Disponible'),
                        ],
                      ),

                      // Liens sociaux si renseignés
                      if ((p?.githubUrl != null && p!.githubUrl!.isNotEmpty) ||
                          (p?.linkedinUrl != null && p!.linkedinUrl!.isNotEmpty) ||
                          (p?.websiteUrl != null && p!.websiteUrl!.isNotEmpty)) ...[
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            if (p?.githubUrl != null && p!.githubUrl!.isNotEmpty)
                              _buildSocialChip('GitHub', Icons.code_rounded),
                            if (p?.linkedinUrl != null && p!.linkedinUrl!.isNotEmpty)
                              _buildSocialChip('LinkedIn', Icons.work_rounded),
                            if (p?.websiteUrl != null && p!.websiteUrl!.isNotEmpty)
                              _buildSocialChip('Site Web', Icons.link_rounded),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // ==========================================
                // 2. CORPS DU PORTFOLIO (SECTIONS)
                // ==========================================
                Padding(
                  padding: const EdgeInsets.all(20.0),
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

                      // Section À propos
                      _buildAboutCard(p?.bio ?? ''),
                      const SizedBox(height: 24),

                      // Section Compétences
                      _buildSectionHeader(Icons.star_outline_rounded, 'Compétences'),
                      const SizedBox(height: 12),
                      _buildSkillsWrap(p?.competencesList ?? []),
                      const SizedBox(height: 24),

                      // Section Projets
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionHeader(Icons.folder_open_rounded, 'Projets Réalisés'),
                          TextButton.icon(
                            icon: const Icon(Icons.add, size: 18, color: primaryOrange),
                            label: const Text('Ajouter', style: TextStyle(color: primaryOrange, fontWeight: FontWeight.bold, fontSize: 13)),
                            onPressed: _showAddProjectModal,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildProjectsSection(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageToggle() {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildLangButton('Français'),
          _buildLangButton('Anglais'),
        ],
      ),
    );
  }

  Widget _buildLangButton(String lang) {
    bool isSelected = _selectedLanguage == lang;
    return GestureDetector(
      onTap: () => setState(() => _selectedLanguage = lang),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          lang,
          style: TextStyle(
            color: isSelected ? Colors.white : primaryOrange,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderMeta(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF94A3B8), size: 15),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildSocialChip(String label, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildAboutCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryOrange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_outline_rounded, color: primaryOrange, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'À propos',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text.isNotEmpty ? text : 'Aucune description rédigée pour le moment.',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: primaryOrange, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildSkillsWrap(List<String> skills) {
    if (skills.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: const Text('Aucune compétence listée. Cliquez sur l\'icône de modification en haut.', style: TextStyle(color: Colors.grey, fontSize: 13)),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: skills.map((skill) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryOrange.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.01),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: primaryOrange,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                skill,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProjectsSection() {
    if (_projets.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Icon(Icons.folder_special_outlined, size: 38, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            const Text('Aucun projet ajouté', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 4),
            Text('Ajoutez vos réalisations pour valoriser vos compétences.', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _projets.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final projet = _projets[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      projet.titre,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                  if (projet.id != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () async {
                        await _portfolioService.deleteProjet(projet.id!);
                        _loadPortfolioData();
                      },
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                projet.description,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.3),
              ),
              if (projet.technologiesList.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  children: projet.technologiesList.map((t) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(t, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF475569))),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
