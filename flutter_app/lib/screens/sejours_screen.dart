import 'package:flutter/material.dart';
import 'package:flutter_app/models/index.dart';
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
    if (sejour != null) {
      _patientIdController.text = sejour.patientId.toString();
      _serviceIdController.text = sejour.serviceId.toString();
      _dateEntreeController.text = sejour.dateEntree;
      _dateSortieController.text = sejour.dateSortie ?? '';
      _motifController.text = sejour.motif;
      _diagnosticController.text = sejour.diagnostic ?? '';
      _typeAdmissionController.text = sejour.typeAdmission ?? '';
      _coutTotalController.text = sejour.coutTotal?.toString() ?? '';
      _statut = sejour.statut;
    } else {
      _patientIdController.clear();
      _serviceIdController.clear();
      _dateEntreeController.clear();
      _dateSortieController.clear();
      _motifController.clear();
      _diagnosticController.clear();
      _typeAdmissionController.clear();
      _coutTotalController.clear();
      _statut = 'EN_COURS';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(sejour == null ? 'Nouveau Séjour' : 'Modifier Séjour'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _patientIdController,
                    decoration: const InputDecoration(
                      labelText: 'ID Patient *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _serviceIdController,
                    decoration: const InputDecoration(
                      labelText: 'ID Service *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dateEntreeController,
                    decoration: const InputDecoration(
                      labelText: 'Date d\'entrée (YYYY-MM-DD) *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dateSortieController,
                    decoration: const InputDecoration(
                      labelText: 'Date de sortie (YYYY-MM-DD)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _motifController,
                    decoration: const InputDecoration(
                      labelText: 'Motif *',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _diagnosticController,
                    decoration: const InputDecoration(
                      labelText: 'Diagnostic',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _statut,
                    decoration: const InputDecoration(
                      labelText: 'Statut *',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'EN_COURS', child: Text('En cours')),
                      DropdownMenuItem(value: 'TERMINE', child: Text('Terminé')),
                      DropdownMenuItem(value: 'ANNULE', child: Text('Annulé')),
                    ],
                    onChanged: (value) => setState(() => _statut = value!),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _typeAdmissionController,
                    decoration: const InputDecoration(
                      labelText: 'Type d\'admission',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _coutTotalController,
                    decoration: const InputDecoration(
                      labelText: 'Coût total',
                      border: OutlineInputBorder(),
                      suffixText: '€',
                    ),
                    keyboardType: TextInputType.number,
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
            onPressed: () => _saveSejour(sejour),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
            ),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSejour(Sejour? existingSejour) async {
    if (!_formKey.currentState!.validate()) return;

    final sejour = Sejour(
      id: existingSejour?.id ?? 0,
      patientId: int.parse(_patientIdController.text),
      serviceId: int.parse(_serviceIdController.text),
      dateEntree: _dateEntreeController.text,
      dateSortie: _dateSortieController.text.isEmpty ? null : _dateSortieController.text,
      motif: _motifController.text,
      diagnostic: _diagnosticController.text.isEmpty ? null : _diagnosticController.text,
      statut: _statut,
      typeAdmission: _typeAdmissionController.text.isEmpty ? null : _typeAdmissionController.text,
      coutTotal: _coutTotalController.text.isEmpty ? null : double.tryParse(_coutTotalController.text),
    );

    bool success;
    if (existingSejour == null) {
      success = await context.read<SejourProvider>().createSejour(sejour);
    } else {
      success = await context.read<SejourProvider>().updateSejour(existingSejour.id, sejour);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? existingSejour == null
                  ? 'Séjour créé avec succès'
                  : 'Séjour modifié avec succès'
              : 'Erreur lors de l\'enregistrement'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
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
