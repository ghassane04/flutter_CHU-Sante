import 'package:flutter/material.dart';
import 'package:flutter_app/models/index.dart';
import 'package:flutter_app/providers/patient_provider.dart';
import 'package:flutter_app/widgets/responsive_layout.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({super.key});

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  String _searchQuery = '';
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _nssController = TextEditingController();
  final _dateNaissanceController = TextEditingController();
  final _adresseController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _emailController = TextEditingController();
  String _sexe = 'M';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientProvider>().loadPatients();
    });
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _nssController.dispose();
    _dateNaissanceController.dispose();
    _adresseController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  List<Patient> _getFilteredPatients(List<Patient> patients) {
    if (_searchQuery.isEmpty) return patients;
    return patients.where((patient) {
      final query = _searchQuery.toLowerCase();
      return patient.nom.toLowerCase().contains(query) ||
             patient.prenom.toLowerCase().contains(query) ||
             patient.numeroSecuriteSociale.toLowerCase().contains(query) ||
             (patient.telephone?.toLowerCase().contains(query) ?? false) ||
             (patient.email?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PatientProvider>(
      builder: (context, provider, child) {
        final filteredPatients = _getFilteredPatients(provider.patients);
        
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: Column(
            children: [
              ScreenHeader(
                title: 'Gestion des Patients',
                subtitle: '${provider.patients.length} patients enregistrés',
                onAddPressed: () => _showPatientDialog(null),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: SearchBarWidget(
                  hintText: 'Rechercher par nom, NSS, téléphone...',
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredPatients.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person_off, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'Aucun patient enregistré'
                                      : 'Aucun patient trouvé',
                                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: ResponsiveLayout.getGridCrossAxisCount(context),
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.95,
                              ),
                              itemCount: filteredPatients.length,
                              itemBuilder: (context, index) {
                                return _buildPatientCard(filteredPatients[index]);
                              },
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPatientCard(Patient patient) {
    final age = patient.age ?? _calculateAge(patient.dateNaissance);
    final sexeIcon = patient.sexe == 'M' ? Icons.male : Icons.female;
    final sexeColor = patient.sexe == 'M' ? const Color(0xFF0284C7) : const Color(0xFFEC4899);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec avatar et nom
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: sexeColor.withOpacity(0.1),
                  child: Icon(sexeIcon, size: 32, color: sexeColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${patient.prenom} ${patient.nom}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'NSS: ${patient.numeroSecuriteSociale}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Informations
            _buildInfoRow(Icons.cake_outlined, 'Né(e) le ${_formatDate(patient.dateNaissance)} ($age ans)'),
            const SizedBox(height: 6),
            if (patient.telephone != null)
              _buildInfoRow(Icons.phone_outlined, patient.telephone!),
            if (patient.telephone != null) const SizedBox(height: 6),
            if (patient.email != null)
              _buildInfoRow(Icons.email_outlined, patient.email!, maxLines: 1),
            
            const Spacer(),
            const SizedBox(height: 12),
            
            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showPatientDialog(patient),
                    icon: const Icon(Icons.edit, size: 14),
                    label: const Text('Modifier', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF14B8A6),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () => _showDeleteConfirmation(patient),
                    icon: const Icon(Icons.delete_outline, size: 16),
                    color: Colors.white,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {int? maxLines}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 11, color: Colors.grey[700]),
            maxLines: maxLines,
            overflow: maxLines != null ? TextOverflow.ellipsis : null,
          ),
        ),
      ],
    );
  }

  int _calculateAge(String dateNaissance) {
    try {
      final birthDate = DateTime.parse(dateNaissance);
      final today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month || 
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return age;
    } catch (e) {
      return 0;
    }
  }

  String _formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  void _showPatientDialog(Patient? patient) {
    if (patient != null) {
      _nomController.text = patient.nom;
      _prenomController.text = patient.prenom;
      _nssController.text = patient.numeroSecuriteSociale;
      _dateNaissanceController.text = patient.dateNaissance;
      _adresseController.text = patient.adresse ?? '';
      _telephoneController.text = patient.telephone ?? '';
      _emailController.text = patient.email ?? '';
      _sexe = patient.sexe;
    } else {
      _nomController.clear();
      _prenomController.clear();
      _nssController.clear();
      _dateNaissanceController.clear();
      _adresseController.clear();
      _telephoneController.clear();
      _emailController.clear();
      _sexe = 'M';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(patient == null ? 'Nouveau Patient' : 'Modifier Patient'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nomController,
                    decoration: const InputDecoration(
                      labelText: 'Nom *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _prenomController,
                    decoration: const InputDecoration(
                      labelText: 'Prénom *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nssController,
                    decoration: const InputDecoration(
                      labelText: 'Numéro de Sécurité Sociale *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dateNaissanceController,
                    decoration: const InputDecoration(
                      labelText: 'Date de Naissance (YYYY-MM-DD) *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _sexe,
                    decoration: const InputDecoration(
                      labelText: 'Sexe *',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'M', child: Text('Masculin')),
                      DropdownMenuItem(value: 'F', child: Text('Féminin')),
                    ],
                    onChanged: (value) => setState(() => _sexe = value!),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _adresseController,
                    decoration: const InputDecoration(
                      labelText: 'Adresse',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _telephoneController,
                    decoration: const InputDecoration(
                      labelText: 'Téléphone',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => _savePatient(patient),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
            ),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Future<void> _savePatient(Patient? existingPatient) async {
    if (!_formKey.currentState!.validate()) return;

    final patient = Patient(
      id: existingPatient?.id ?? 0,
      nom: _nomController.text,
      prenom: _prenomController.text,
      numeroSecuriteSociale: _nssController.text,
      dateNaissance: _dateNaissanceController.text,
      sexe: _sexe,
      adresse: _adresseController.text.isEmpty ? null : _adresseController.text,
      telephone: _telephoneController.text.isEmpty ? null : _telephoneController.text,
      email: _emailController.text.isEmpty ? null : _emailController.text,
    );

    bool success;
    if (existingPatient == null) {
      success = await context.read<PatientProvider>().createPatient(patient);
    } else {
      success = await context.read<PatientProvider>().updatePatient(existingPatient.id, patient);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? existingPatient == null
                  ? 'Patient créé avec succès'
                  : 'Patient modifié avec succès'
              : 'Erreur lors de l\'enregistrement'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _showDeleteConfirmation(Patient patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le patient'),
        content: Text('Êtes-vous sûr de vouloir supprimer ${patient.prenom} ${patient.nom} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<PatientProvider>().deletePatient(patient.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Patient supprimé avec succès'
                        : 'Erreur lors de la suppression'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
