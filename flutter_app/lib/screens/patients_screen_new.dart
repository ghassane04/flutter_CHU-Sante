import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/providers/patient_provider.dart';
import 'package:flutter_app/models/patient.dart';
import 'package:flutter_app/widgets/responsive_layout.dart';
import 'package:intl/intl.dart';

class PatientsScreen extends StatefulWidget {
  const PatientsScreen({Key? key}) : super(key: key);

  @override
  State<PatientsScreen> createState() => _PatientsScreenState();
}

class _PatientsScreenState extends State<PatientsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<PatientProvider>().loadPatients());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Patient> _filterPatients(List<Patient> patients) {
    if (_searchQuery.isEmpty) return patients;
    return patients.where((patient) {
      final searchLower = _searchQuery.toLowerCase();
      return patient.nom.toLowerCase().contains(searchLower) ||
          patient.prenom.toLowerCase().contains(searchLower) ||
          patient.numeroSecuriteSociale.contains(searchLower);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Consumer<PatientProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0284C7)),
                  );
                }

                if (provider.error != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('Erreur: ${provider.error}', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  );
                }

                final filteredPatients = _filterPatients(provider.patients);

                if (filteredPatients.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off_outlined, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty 
                            ? 'Aucun patient trouvé'
                            : 'Aucun patient ne correspond à votre recherche',
                          style: TextStyle(color: Colors.grey[600], fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(24),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: ResponsiveLayout.getGridCrossAxisCount(context),
                    childAspectRatio: ResponsiveLayout.isMobile(context) ? 0.85 : 0.95,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredPatients.length,
                  itemBuilder: (context, index) {
                    return _buildPatientCard(filteredPatients[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(ResponsiveLayout.isMobile(context) ? 16 : 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Patients',
                      style: TextStyle(
                        fontSize: ResponsiveLayout.isMobile(context) ? 24 : 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gestion des dossiers patients',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SearchBarWidget(
            hintText: 'Rechercher par nom, prénom ou N° Sécurité Sociale...',
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => _showPatientDialog(null),
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Nouveau Patient'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
          const SizedBox(height: 8),
          Consumer<PatientProvider>(
            builder: (context, provider, _) {
              final count = _filterPatients(provider.patients).length;
              return Text(
                '$count patient(s) trouvé(s)',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(Patient patient) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header avec avatar et genre
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: patient.sexe == 'M' 
                      ? const Color(0xFF0284C7).withOpacity(0.1)
                      : const Color(0xFFEC4899).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    patient.sexe == 'M' ? Icons.male : Icons.female,
                    color: patient.sexe == 'M' ? const Color(0xFF0284C7) : const Color(0xFFEC4899),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${patient.prenom} ${patient.nom}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        patient.sexe == 'M' ? 'Homme' : 'Femme',
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Informations du patient
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildInfoRow(Icons.credit_card, 'NSS: ${patient.numeroSecuriteSociale}'),
                const SizedBox(height: 6),
                _buildInfoRow(Icons.cake_outlined, '${_formatDate(patient.dateNaissance)} (${patient.age ?? 0} ans)'),
                const SizedBox(height: 6),
                _buildInfoRow(Icons.phone_outlined, patient.telephone ?? 'Non renseigné'),
                const SizedBox(height: 6),
                _buildInfoRow(Icons.email_outlined, patient.email ?? 'Non renseigné'),
              ],
            ),
            const SizedBox(height: 12),
            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showPatientDialog(patient),
                    icon: const Icon(Icons.edit, size: 14),
                    label: const Text('Modifier', style: TextStyle(fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF14B8A6),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                    icon: const Icon(Icons.delete_outline, size: 18),
                    color: Colors.white,
                    padding: const EdgeInsets.all(10),
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[400]),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatDate(String date) {
    try {
      final dt = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(dt);
    } catch (e) {
      return date;
    }
  }

  void _showPatientDialog(Patient? patient) {
    final formKey = GlobalKey<FormState>();
    final nomController = TextEditingController(text: patient?.nom);
    final prenomController = TextEditingController(text: patient?.prenom);
    final nssController = TextEditingController(text: patient?.numeroSecuriteSociale);
    final dateController = TextEditingController(text: patient?.dateNaissance);
    final telController = TextEditingController(text: patient?.telephone);
    final emailController = TextEditingController(text: patient?.email);
    final adresseController = TextEditingController(text: patient?.adresse);
    String sexe = patient?.sexe ?? 'M';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(patient == null ? 'Nouveau Patient' : 'Modifier Patient'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nomController,
                  decoration: const InputDecoration(
                    labelText: 'Nom *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: prenomController,
                  decoration: const InputDecoration(
                    labelText: 'Prénom *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nssController,
                  decoration: const InputDecoration(
                    labelText: 'N° Sécurité Sociale *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: 'Date de naissance (YYYY-MM-DD) *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
                ),
                const SizedBox(height: 12),
                StatefulBuilder(
                  builder: (context, setState) => DropdownButtonFormField<String>(
                    value: sexe,
                    decoration: const InputDecoration(
                      labelText: 'Sexe *',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'M', child: Text('Homme')),
                      DropdownMenuItem(value: 'F', child: Text('Femme')),
                    ],
                    onChanged: (v) => setState(() => sexe = v!),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: telController,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: adresseController,
                  decoration: const InputDecoration(
                    labelText: 'Adresse',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                final patientData = Patient(
                  id: patient?.id ?? 0,
                  nom: nomController.text,
                  prenom: prenomController.text,
                  numeroSecuriteSociale: nssController.text,
                  dateNaissance: dateController.text,
                  sexe: sexe,
                  telephone: telController.text.isEmpty ? null : telController.text,
                  email: emailController.text.isEmpty ? null : emailController.text,
                  adresse: adresseController.text.isEmpty ? null : adresseController.text,
                );

                try {
                  if (patient == null) {
                    await context.read<PatientProvider>().createPatient(patientData);
                  } else {
                    await context.read<PatientProvider>().updatePatient(patient.id, patientData);
                  }
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(patient == null ? 'Patient créé avec succès' : 'Patient mis à jour'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
            child: Text(patient == null ? 'Créer' : 'Modifier'),
          ),
        ],
      ),
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
              try {
                await context.read<PatientProvider>().deletePatient(patient.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Patient supprimé avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}
