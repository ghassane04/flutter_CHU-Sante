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
    // Create local controllers to avoid state issues
    final nomController = TextEditingController(text: patient?.nom ?? '');
    final prenomController = TextEditingController(text: patient?.prenom ?? '');
    final nssController = TextEditingController(text: patient?.numeroSecuriteSociale ?? '');
    final adresseController = TextEditingController(text: patient?.adresse ?? '');
    final telephoneController = TextEditingController(text: patient?.telephone ?? '');
    final emailController = TextEditingController(text: patient?.email ?? '');
    DateTime? selectedDate = patient != null ? DateTime.tryParse(patient.dateNaissance) : null;
    String sexe = patient?.sexe ?? 'Homme';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 450,
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 16, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        patient == null ? 'Nouveau Patient' : 'Modifier Patient',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                // Form content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nom / Prénom row
                          Row(
                            children: [
                              Expanded(child: _buildDialogField('Nom', nomController, '')),
                              const SizedBox(width: 16),
                              Expanded(child: _buildDialogField('Prénom', prenomController, '')),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // N° Sécurité Sociale
                          _buildDialogField('N° Sécurité Sociale', nssController, 'Ex: 1 85 03 75 120 123 45'),
                          const SizedBox(height: 16),
                          // Date de Naissance / Sexe row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Date de Naissance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
                                    const SizedBox(height: 6),
                                    InkWell(
                                      onTap: () async {
                                        final date = await showDatePicker(
                                          context: context,
                                          initialDate: selectedDate ?? DateTime(1990),
                                          firstDate: DateTime(1900),
                                          lastDate: DateTime.now(),
                                        );
                                        if (date != null) {
                                          setDialogState(() => selectedDate = date);
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey[300]!),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              selectedDate != null
                                                  ? DateFormat('dd/MM/yyyy').format(selectedDate!)
                                                  : 'jj/mm/aaaa',
                                              style: TextStyle(color: selectedDate != null ? Colors.black : Colors.grey[400]),
                                            ),
                                            Icon(Icons.calendar_today, size: 18, color: Colors.grey[500]),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Sexe', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<String>(
                                      value: sexe,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      ),
                                      items: const [
                                        DropdownMenuItem(value: 'Homme', child: Text('Homme')),
                                        DropdownMenuItem(value: 'Femme', child: Text('Femme')),
                                      ],
                                      onChanged: (v) => setDialogState(() => sexe = v ?? 'Homme'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Adresse
                          _buildDialogField('Adresse', adresseController, ''),
                          const SizedBox(height: 16),
                          // Téléphone / Email row
                          Row(
                            children: [
                              Expanded(child: _buildDialogField('Téléphone', telephoneController, '')),
                              const SizedBox(width: 16),
                              Expanded(child: _buildDialogField('Email', emailController, '')),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
                // Actions
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF14B8A6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Annuler'),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          if (selectedDate == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Veuillez sélectionner une date de naissance'), backgroundColor: Colors.red),
                            );
                            return;
                          }
                          final newPatient = Patient(
                            id: patient?.id ?? 0,
                            nom: nomController.text,
                            prenom: prenomController.text,
                            numeroSecuriteSociale: nssController.text,
                            dateNaissance: DateFormat('yyyy-MM-dd').format(selectedDate!),
                            sexe: sexe == 'Homme' ? 'M' : 'F',
                            adresse: adresseController.text.isEmpty ? null : adresseController.text,
                            telephone: telephoneController.text.isEmpty ? null : telephoneController.text,
                            email: emailController.text.isEmpty ? null : emailController.text,
                          );
                          bool success;
                          if (patient == null) {
                            success = await context.read<PatientProvider>().createPatient(newPatient);
                          } else {
                            success = await context.read<PatientProvider>().updatePatient(patient.id, newPatient);
                          }
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success ? (patient == null ? 'Patient créé' : 'Patient modifié') : 'Erreur'),
                                backgroundColor: success ? Colors.green : Colors.red,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0284C7),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Créer'),
                      ),
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

  Widget _buildDialogField(String label, TextEditingController controller, String placeholder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF0284C7))),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
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
