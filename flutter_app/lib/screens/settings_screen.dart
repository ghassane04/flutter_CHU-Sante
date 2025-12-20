import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/providers/settings_provider.dart';
import 'package:flutter_app/providers/user_provider.dart';
import 'package:flutter_app/models/index.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() {
      context.read<SettingsProvider>().fetchSettings();
      context.read<UserProvider>().fetchUsers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _buildHeader(),
          _buildTabs(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUsersTab(),
                _buildSystemTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.settings, size: 32, color: Colors.blue[700]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Paramètres',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                Text(
                  'Configuration et administration du système',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.blue[700],
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: Colors.blue[700],
        tabs: const [
          Tab(
            icon: Icon(Icons.people),
            text: 'Utilisateurs',
          ),
          Tab(
            icon: Icon(Icons.tune),
            text: 'Système',
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    return Consumer<UserProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null) {
          return Center(
            child: Text(
              'Erreur: ${provider.errorMessage}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gestion des utilisateurs du système',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddUserDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter un utilisateur'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Nom',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              'Email',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'Statut',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Actions',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: provider.users.length,
                        itemBuilder: (context, index) {
                          return _buildUserRow(provider.users[index], provider);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildUserRow(User user, UserProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              user.username,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(user.email),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: user.enabled ? Colors.green[50] : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user.enabled ? 'Actif' : 'Inactif',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: user.enabled ? Colors.green[700] : Colors.grey[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => _showEditUserDialog(context, user),
                  child: Text('Modifier', style: TextStyle(color: Colors.blue[700])),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _confirmDeleteUser(context, user.id, provider),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red[50],
                  ),
                  child: Text('Supprimer', style: TextStyle(color: Colors.red[700])),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemTab() {
    return Consumer<SettingsProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.errorMessage != null) {
          return Center(
            child: Text(
              'Erreur: ${provider.errorMessage}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        // Group settings by category
        final settingsByCategory = <String, List<Setting>>{};
        for (final setting in provider.settings) {
          if (!settingsByCategory.containsKey(setting.categorie)) {
            settingsByCategory[setting.categorie] = [];
          }
          settingsByCategory[setting.categorie]!.add(setting);
        }

        // Initialize controllers
        for (final setting in provider.settings) {
          if (!_controllers.containsKey(setting.cle)) {
            _controllers[setting.cle] = TextEditingController(text: setting.valeur);
          }
        }

        // Initialize appearance controllers if not from database
        if (!_controllers.containsKey('app_title')) {
          _controllers['app_title'] = TextEditingController(
            text: settingsByCategory.values
                .expand((list) => list)
                .firstWhere(
                  (s) => s.cle == 'app_title',
                  orElse: () => Setting(
                    cle: 'app_title',
                    categorie: 'Apparence',
                    libelle: 'Titre de l\'application',
                    valeur: 'CHU Santé',
                    typeValeur: 'STRING',
                  ),
                )
                .valeur,
          );
        }
        if (!_controllers.containsKey('app_subtitle')) {
          _controllers['app_subtitle'] = TextEditingController(
            text: settingsByCategory.values
                .expand((list) => list)
                .firstWhere(
                  (s) => s.cle == 'app_subtitle',
                  orElse: () => Setting(
                    cle: 'app_subtitle',
                    categorie: 'Apparence',
                    libelle: 'Sous-titre de l\'application',
                    valeur: 'Finance Dashboard',
                    typeValeur: 'STRING',
                  ),
                )
                .valeur,
          );
        }
        if (!_controllers.containsKey('app_logo_url')) {
          _controllers['app_logo_url'] = TextEditingController(
            text: settingsByCategory.values
                .expand((list) => list)
                .firstWhere(
                  (s) => s.cle == 'app_logo_url',
                  orElse: () => Setting(
                    cle: 'app_logo_url',
                    categorie: 'Apparence',
                    libelle: 'URL du logo',
                    valeur: '',
                    typeValeur: 'STRING',
                  ),
                )
                .valeur,
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppearanceSection(),
              const SizedBox(height: 24),
              ...settingsByCategory.entries.map((entry) {
                return _buildSystemCategorySection(entry.key, entry.value);
              }).toList(),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => _saveSystemSettings(provider),
                  icon: const Icon(Icons.save),
                  label: const Text('Enregistrer les modifications'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppearanceSection() {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.palette, color: Colors.blue[700]),
                const SizedBox(width: 12),
                const Text(
                  'Apparence de l\'application',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Personnalisez le titre et le logo de votre application',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            
            // App Title
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Titre de l\'application',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ce titre apparaîtra dans le menu latéral',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _controllers['app_title'],
                  decoration: InputDecoration(
                    hintText: 'CHU Santé',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F7FA),
                    prefixIcon: const Icon(Icons.title),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // App Subtitle
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sous-titre de l\'application',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Description courte sous le titre',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _controllers['app_subtitle'],
                  decoration: InputDecoration(
                    hintText: 'Finance Dashboard',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F7FA),
                    prefixIcon: const Icon(Icons.subtitles),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // App Logo URL
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Logo de l\'application',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'URL de l\'image du logo (PNG, JPG, SVG). Laissez vide pour utiliser l\'icône par défaut',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _controllers['app_logo_url'],
                  decoration: InputDecoration(
                    hintText: 'https://example.com/logo.png',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F7FA),
                    prefixIcon: const Icon(Icons.image),
                  ),
                ),
                const SizedBox(height: 12),
                // Preview
                if (_controllers['app_logo_url']?.text.isNotEmpty ?? false)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              _controllers['app_logo_url']!.text,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.broken_image, color: Colors.grey[400], size: 40);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Aperçu du logo',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Le logo apparaîtra dans le menu latéral',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemCategorySection(String category, List<Setting> settings) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ...settings.map((setting) => _buildSystemSettingField(setting)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemSettingField(Setting setting) {
    final controller = _controllers[setting.cle]!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            setting.libelle,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          if (setting.description != null) ...[
            const SizedBox(height: 4),
            Text(
              setting.description!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
          const SizedBox(height: 8),
          if (setting.typeValeur == 'BOOLEAN')
            SwitchListTile(
              value: controller.text.toLowerCase() == 'true',
              onChanged: (value) {
                setState(() {
                  controller.text = value.toString();
                });
              },
              contentPadding: EdgeInsets.zero,
              title: Text(controller.text.toLowerCase() == 'true' ? 'Activé' : 'Désactivé'),
            )
          else if (setting.typeValeur == 'SELECT' && setting.valeurParDefaut != null)
            DropdownButtonFormField<String>(
              value: controller.text,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
              ),
              items: setting.valeurParDefaut!.split(',').map((option) {
                return DropdownMenuItem(value: option.trim(), child: Text(option.trim()));
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    controller.text = value;
                  });
                }
              },
            )
          else
            TextFormField(
              controller: controller,
              keyboardType: setting.typeValeur == 'INTEGER' || setting.typeValeur == 'DECIMAL'
                  ? TextInputType.number
                  : TextInputType.text,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
              ),
            ),
        ],
      ),
    );
  }

  void _saveSystemSettings(SettingsProvider provider) async {
    bool allSuccess = true;
    
    // Save appearance settings first
    final appearanceSettings = ['app_title', 'app_subtitle', 'app_logo_url'];
    for (final key in appearanceSettings) {
      final controller = _controllers[key];
      if (controller != null) {
        // Check if setting exists in database
        final existingSetting = provider.settings.firstWhere(
          (s) => s.cle == key,
          orElse: () => Setting(
            cle: key,
            categorie: 'Apparence',
            libelle: key == 'app_title' 
                ? 'Titre de l\'application'
                : key == 'app_subtitle'
                    ? 'Sous-titre de l\'application'
                    : 'URL du logo',
            valeur: '',
            typeValeur: 'STRING',
          ),
        );
        
        if (existingSetting.id != null) {
          // Update existing
          if (controller.text != existingSetting.valeur) {
            final updatedSetting = Setting(
              id: existingSetting.id,
              cle: existingSetting.cle,
              categorie: existingSetting.categorie,
              libelle: existingSetting.libelle,
              valeur: controller.text,
              typeValeur: existingSetting.typeValeur,
              description: existingSetting.description,
              valeurParDefaut: existingSetting.valeurParDefaut,
            );
            final success = await provider.updateSetting(existingSetting.id!, updatedSetting);
            if (!success) allSuccess = false;
          }
        } else {
          // Create new
          final newSetting = Setting(
            cle: key,
            categorie: 'Apparence',
            libelle: key == 'app_title' 
                ? 'Titre de l\'application'
                : key == 'app_subtitle'
                    ? 'Sous-titre de l\'application'
                    : 'URL du logo',
            valeur: controller.text,
            typeValeur: 'STRING',
            description: key == 'app_title'
                ? 'Titre principal affiché dans le menu latéral'
                : key == 'app_subtitle'
                    ? 'Sous-titre affiché sous le titre principal'
                    : 'URL de l\'image du logo de l\'application',
          );
          final success = await provider.createSetting(newSetting);
          if (!success) allSuccess = false;
        }
      }
    }
    
    // Save other settings
    for (final setting in provider.settings) {
      if (appearanceSettings.contains(setting.cle)) continue; // Skip already saved
      
      final controller = _controllers[setting.cle];
      if (controller != null && controller.text != setting.valeur) {
        final updatedSetting = Setting(
          id: setting.id,
          cle: setting.cle,
          categorie: setting.categorie,
          libelle: setting.libelle,
          valeur: controller.text,
          typeValeur: setting.typeValeur,
          description: setting.description,
          valeurParDefaut: setting.valeurParDefaut,
        );
        
        final success = await provider.updateSetting(setting.id!, updatedSetting);
        if (!success) allSuccess = false;
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(allSuccess
              ? 'Paramètres enregistrés avec succès. Rechargez l\'application pour voir les changements.'
              : 'Erreur lors de l\'enregistrement de certains paramètres'),
          backgroundColor: allSuccess ? Colors.green : Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      
      if (allSuccess) {
        // Reload settings to update UI
        await provider.fetchSettings();
      }
    }
  }

  void _showAddUserDialog(BuildContext context) {
    final usernameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final nomController = TextEditingController();
    final prenomController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ajouter un utilisateur'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Nom d\'utilisateur',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nomController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: prenomController,
                decoration: const InputDecoration(
                  labelText: 'Prénom',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final userData = {
                'username': usernameController.text,
                'email': emailController.text,
                'password': passwordController.text,
                'nom': nomController.text,
                'prenom': prenomController.text,
                'enabled': true,
              };

              final success = await context.read<UserProvider>().createUser(userData);
              if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Utilisateur créé avec succès'
                        : 'Erreur lors de la création'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  void _showEditUserDialog(BuildContext context, User user) {
    final usernameController = TextEditingController(text: user.username);
    final emailController = TextEditingController(text: user.email);
    final nomController = TextEditingController(text: user.nom ?? '');
    final prenomController = TextEditingController(text: user.prenom ?? '');
    bool enabled = user.enabled;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Modifier l\'utilisateur'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom d\'utilisateur',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nomController,
                  decoration: const InputDecoration(
                    labelText: 'Nom',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: prenomController,
                  decoration: const InputDecoration(
                    labelText: 'Prénom',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Compte actif'),
                  value: enabled,
                  onChanged: (value) => setState(() => enabled = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final userData = {
                  'username': usernameController.text,
                  'email': emailController.text,
                  'nom': nomController.text,
                  'prenom': prenomController.text,
                  'enabled': enabled,
                };

                final success = await context.read<UserProvider>().updateUser(user.id, userData);
                if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success
                          ? 'Utilisateur modifié avec succès'
                          : 'Erreur lors de la modification'),
                      backgroundColor: success ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteUser(BuildContext context, int userId, UserProvider provider) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cet utilisateur ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final success = await provider.deleteUser(userId);
              if (dialogContext.mounted) Navigator.of(dialogContext).pop();
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Utilisateur supprimé avec succès'
                        : 'Erreur lors de la suppression'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
