import 'package:flutter/material.dart';
import 'package:flutter_app/models/index.dart';
import 'package:flutter_app/providers/patient_provider.dart';
import 'package:flutter_app/providers/service_provider.dart';
import 'package:flutter_app/providers/sejour_provider.dart';
import 'package:flutter_app/widgets/responsive_layout.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SejoursScreen extends StatefulWidget {
  const SejoursScreen({super.key});

  @override
  State<SejoursScreen> createState() => _SejoursScreenState();
}

class _SejoursScreenState extends State<SejoursScreen> {
  String _searchQuery = '';
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _patientIdController = TextEditingController();
  final _serviceIdController = TextEditingController();
  final _dateEntreeController = TextEditingController();
  final _dateSortieController = TextEditingController();
  final _motifController = TextEditingController();
  final _diagnosticController = TextEditingController();
  final _typeAdmissionController = TextEditingController();
  final _coutTotalController = TextEditingController();
  String _statut = 'EN_COURS';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SejourProvider>().loadSejours();
    });
  }

  @override
  void dispose() {
    _patientIdController.dispose();
    _serviceIdController.dispose();
    _dateEntreeController.dispose();
    _dateSortieController.dispose();
    _motifController.dispose();
    _diagnosticController.dispose();
    _typeAdmissionController.dispose();
    _coutTotalController.dispose();
    super.dispose();
  }

  List<Sejour> _getFilteredSejours(List<Sejour> sejours) {
    if (_searchQuery.isEmpty) return sejours;
    return sejours.where((sejour) {
      final query = _searchQuery.toLowerCase();
      return (sejour.patientNom?.toLowerCase().contains(query) ?? false) ||
             (sejour.patientPrenom?.toLowerCase().contains(query) ?? false) ||
             (sejour.serviceNom?.toLowerCase().contains(query) ?? false) ||
             sejour.motif.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SejourProvider>(
      builder: (context, provider, child) {
        final filteredSejours = _getFilteredSejours(provider.sejours);
        
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          body: Column(
            children: [
              ScreenHeader(
                title: 'Gestion des Séjours',
                subtitle: '${provider.sejours.length} séjours enregistrés',
                onAddPressed: () => _showSejourDialog(null),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: SearchBarWidget(
                  hintText: 'Rechercher par patient, service, motif...',
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredSejours.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.hotel_outlined, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  _searchQuery.isEmpty
                                      ? 'Aucun séjour enregistré'
                                      : 'Aucun séjour trouvé',
                                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: ListView.builder(
                              itemCount: filteredSejours.length,
                              itemBuilder: (context, index) {
                                return _buildSejourCard(filteredSejours[index]);
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

  Widget _buildSejourCard(Sejour sejour) {
    Color statutColor;
    String statutLabel;
    switch (sejour.statut) {
      case 'EN_COURS':
        statutColor = const Color(0xFF10B981);
        statutLabel = 'EN COURS';
        break;
      case 'TERMINE':
        statutColor = const Color(0xFF8B5CF6);
        statutLabel = 'TERMINÉ';
        break;
      case 'ANNULE':
        statutColor = const Color(0xFFEF4444);
        statutLabel = 'ANNULÉ';
        break;
      default:
        statutColor = Colors.grey;
        statutLabel = sejour.statut;
    }

    final duree = _calculateDuree(sejour.dateEntree, sejour.dateSortie);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, size: 18, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${sejour.patientPrenom ?? ''} ${sejour.patientNom ?? 'Patient #${sejour.patientId}'}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.local_hospital, size: 16, color: Colors.grey[500]),
                          const SizedBox(width: 8),
                          Text(
                            sejour.serviceNom ?? 'Service #${sejour.serviceId}',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statutColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statutLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statutColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoItem(
                          'Date d\'entrée',
                          _formatDate(sejour.dateEntree),
                          Icons.login,
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          'Date de sortie',
                          sejour.dateSortie != null ? _formatDate(sejour.dateSortie!) : 'En cours',
                          Icons.logout,
                        ),
                      ),
                      Expanded(
                        child: _buildInfoItem(
                          'Durée',
                          duree,
                          Icons.timer_outlined,
                        ),
                      ),
                      if (sejour.coutTotal != null)
                        Expanded(
                          child: _buildInfoItem(
                            'Coût',
                            NumberFormat.currency(locale: 'fr', symbol: '€').format(sejour.coutTotal),
                            Icons.attach_money,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Motif', style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text(sejour.motif, style: const TextStyle(fontSize: 13, color: Color(0xFF1F2937))),
                          ],
                        ),
                      ),
                      if (sejour.diagnostic != null) const SizedBox(width: 16),
                      if (sejour.diagnostic != null)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Diagnostic', style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              Text(sejour.diagnostic!, style: const TextStyle(fontSize: 13, color: Color(0xFF1F2937))),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showSejourDialog(sejour),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Modifier'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF14B8A6),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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
                    onPressed: () => _showDeleteConfirmation(sejour),
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

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1F2937)),
        ),
      ],
    );
  }

  String _calculateDuree(String dateEntree, String? dateSortie) {
    try {
      final entree = DateTime.parse(dateEntree);
      final sortie = dateSortie != null ? DateTime.parse(dateSortie) : DateTime.now();
      final difference = sortie.difference(entree).inDays;
      return '$difference jour${difference > 1 ? 's' : ''}';
    } catch (e) {
      return 'N/A';
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

  void _showSejourDialog(Sejour? sejour) {
    // Import patient and service providers
    final patientProvider = context.read<PatientProvider>();
    final serviceProvider = context.read<ServiceProvider>();
    
    // Load data if not already loaded
    if (patientProvider.patients.isEmpty) patientProvider.loadPatients();
    if (serviceProvider.services.isEmpty) serviceProvider.loadServices();

    // Local state for the dialog
    int? selectedPatientId = sejour?.patientId;
    int? selectedServiceId = sejour?.serviceId;
    DateTime? dateEntree = sejour != null ? DateTime.tryParse(sejour.dateEntree) : null;
    DateTime? dateSortie = sejour?.dateSortie != null ? DateTime.tryParse(sejour!.dateSortie!) : null;
    final motifController = TextEditingController(text: sejour?.motif ?? '');
    final diagnosticController = TextEditingController(text: sejour?.diagnostic ?? '');
    String statut = sejour?.statut ?? 'EN_COURS';
    String typeAdmission = sejour?.typeAdmission ?? 'Programmé';
    final coutController = TextEditingController(text: sejour?.coutTotal?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 480,
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
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
                        sejour == null ? 'Nouveau Séjour' : 'Modifier Séjour',
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Patient dropdown
                        _buildDropdownLabel('Patient *'),
                        Consumer<PatientProvider>(
                          builder: (context, pProvider, _) => DropdownButtonFormField<int>(
                            value: selectedPatientId,
                            hint: const Text('Sélectionner un patient'),
                            decoration: _dropdownDecoration(),
                            items: pProvider.patients.map((p) => DropdownMenuItem(
                              value: p.id,
                              child: Text('${p.prenom} ${p.nom}'),
                            )).toList(),
                            onChanged: (v) => setDialogState(() => selectedPatientId = v),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Service dropdown
                        _buildDropdownLabel('Service *'),
                        Consumer<ServiceProvider>(
                          builder: (context, sProvider, _) => DropdownButtonFormField<int>(
                            value: selectedServiceId,
                            hint: const Text('Sélectionner un service'),
                            decoration: _dropdownDecoration(),
                            items: sProvider.services.map((s) => DropdownMenuItem(
                              value: s.id,
                              child: Text(s.nom),
                            )).toList(),
                            onChanged: (v) => setDialogState(() => selectedServiceId = v),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Dates row
                        Row(
                          children: [
                            Expanded(child: _buildDatePicker(
                              context, 
                              "Date d'entrée", 
                              dateEntree, 
                              (d) => setDialogState(() => dateEntree = d),
                            )),
                            const SizedBox(width: 16),
                            Expanded(child: _buildDatePicker(
                              context, 
                              'Date de sortie', 
                              dateSortie, 
                              (d) => setDialogState(() => dateSortie = d),
                            )),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Motif
                        _buildDropdownLabel('Motif *'),
                        TextFormField(
                          controller: motifController,
                          maxLines: 2,
                          decoration: _textFieldDecoration(''),
                        ),
                        const SizedBox(height: 16),
                        
                        // Diagnostic
                        _buildDropdownLabel('Diagnostic'),
                        TextFormField(
                          controller: diagnosticController,
                          maxLines: 2,
                          decoration: _textFieldDecoration(''),
                        ),
                        const SizedBox(height: 16),
                        
                        // Statut / Type d'admission row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDropdownLabel('Statut *'),
                                  DropdownButtonFormField<String>(
                                    value: statut,
                                    decoration: _dropdownDecoration(),
                                    items: const [
                                      DropdownMenuItem(value: 'EN_COURS', child: Text('En cours')),
                                      DropdownMenuItem(value: 'TERMINE', child: Text('Terminé')),
                                      DropdownMenuItem(value: 'ANNULE', child: Text('Annulé')),
                                    ],
                                    onChanged: (v) => setDialogState(() => statut = v ?? 'EN_COURS'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDropdownLabel("Type d'admission"),
                                  DropdownButtonFormField<String>(
                                    value: typeAdmission,
                                    decoration: _dropdownDecoration(),
                                    items: const [
                                      DropdownMenuItem(value: 'Programmé', child: Text('Programmé')),
                                      DropdownMenuItem(value: 'Urgence', child: Text('Urgence')),
                                      DropdownMenuItem(value: 'Transfert', child: Text('Transfert')),
                                    ],
                                    onChanged: (v) => setDialogState(() => typeAdmission = v ?? 'Programmé'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Coût total
                        _buildDropdownLabel('Coût total (€)'),
                        TextFormField(
                          controller: coutController,
                          keyboardType: TextInputType.number,
                          decoration: _textFieldDecoration(''),
                        ),
                        const SizedBox(height: 24),
                      ],
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
                          if (selectedPatientId == null || selectedServiceId == null || dateEntree == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Veuillez remplir tous les champs obligatoires'), backgroundColor: Colors.red),
                            );
                            return;
                          }
                          final newSejour = Sejour(
                            id: sejour?.id ?? 0,
                            patientId: selectedPatientId!,
                            serviceId: selectedServiceId!,
                            dateEntree: DateFormat('yyyy-MM-dd').format(dateEntree!),
                            dateSortie: dateSortie != null ? DateFormat('yyyy-MM-dd').format(dateSortie!) : null,
                            motif: motifController.text,
                            diagnostic: diagnosticController.text.isEmpty ? null : diagnosticController.text,
                            statut: statut,
                            typeAdmission: typeAdmission,
                            coutTotal: coutController.text.isEmpty ? null : double.tryParse(coutController.text),
                          );
                          bool success;
                          if (sejour == null) {
                            success = await context.read<SejourProvider>().createSejour(newSejour);
                          } else {
                            success = await context.read<SejourProvider>().updateSejour(sejour.id, newSejour);
                          }
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(success ? (sejour == null ? 'Séjour créé' : 'Séjour modifié') : 'Erreur'),
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

  Widget _buildDropdownLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF374151))),
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  InputDecoration _textFieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF0284C7))),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _buildDatePicker(BuildContext context, String label, DateTime? date, Function(DateTime) onDateSelected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDropdownLabel(label),
        InkWell(
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (selectedDate != null) onDateSelected(selectedDate);
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
                  date != null ? DateFormat('dd/MM/yyyy').format(date) : 'jj/mm/aaaa',
                  style: TextStyle(color: date != null ? Colors.black : Colors.grey[400]),
                ),
                Icon(Icons.calendar_today, size: 18, color: Colors.grey[500]),
              ],
            ),
          ),
        ),
      ],
    );
  }



  void _showDeleteConfirmation(Sejour sejour) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le séjour'),
        content: Text('Êtes-vous sûr de vouloir supprimer ce séjour ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await context.read<SejourProvider>().deleteSejour(sejour.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success
                        ? 'Séjour supprimé avec succès'
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
