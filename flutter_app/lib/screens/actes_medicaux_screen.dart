import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/providers/acte_medical_provider.dart';
import 'package:flutter_app/providers/sejour_provider.dart';
import 'package:flutter_app/models/acte_medical.dart';
import 'package:intl/intl.dart';

class ActesMedicauxScreen extends StatefulWidget {
  const ActesMedicauxScreen({Key? key}) : super(key: key);

  @override
  State<ActesMedicauxScreen> createState() => _ActesMedicauxScreenState();
}

class _ActesMedicauxScreenState extends State<ActesMedicauxScreen> {
  String _searchQuery = '';
  String _selectedType = 'Tous les types';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ActeMedicalProvider>().loadActesMedicaux();
      context.read<SejourProvider>().loadSejours();
    });
  }

  List<ActeMedical> _getFilteredActes(List<ActeMedical> actes) {
    return actes.where((acte) {
      final matchesSearch = _searchQuery.isEmpty ||
          acte.code.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          acte.libelle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (acte.medecin?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      final matchesType = _selectedType == 'Tous les types' || acte.type == _selectedType;
      return matchesSearch && matchesType;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Consumer<ActeMedicalProvider>(
        builder: (context, acteProvider, _) {
          if (acteProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF0284C7)));
          }

          if (acteProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('Erreur: ${acteProvider.error}', style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => acteProvider.loadActesMedicaux(),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }

          final filteredActes = _getFilteredActes(acteProvider.actes);
          final types = ['Tous les types', ...acteProvider.actes.map((a) => a.type).toSet().toList()];

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 24),
              
              // Search and filter
              _buildSearchAndFilter(types),
              const SizedBox(height: 16),
              
              // Count
              Text(
                '${filteredActes.length} acte(s) trouvé(s)',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              
              // Actes list
              ...filteredActes.map((acte) => _buildActeCard(acte, acteProvider)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Actes Médicaux',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
              ),
              const SizedBox(height: 4),
              Text('Gestion des actes médicaux et interventions', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showActeDialog(null),
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Nouvel Acte'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0284C7),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter(List<String> types) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          // Search field
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Rechercher par code, libellé, médecin...',
              prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey[300]!)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 16),
          
          // Type filter
          DropdownButtonFormField<String>(
            value: _selectedType,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            items: types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedType = value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActeCard(ActeMedical acte, ActeMedicalProvider provider) {
    // Type badge color
    Color typeColor;
    switch (acte.type.toUpperCase()) {
      case 'CONSULTATION':
        typeColor = const Color(0xFF8B5CF6); // Purple
        break;
      case 'EXAMEN':
        typeColor = const Color(0xFF10B981); // Green
        break;
      case 'INTERVENTION':
        typeColor = const Color(0xFFEF4444); // Red
        break;
      case 'ANALYSE':
        typeColor = const Color(0xFF3B82F6); // Blue
        break;
      default:
        typeColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                child: Icon(Icons.description_outlined, color: Colors.grey[600], size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(acte.libelle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Text(acte.type.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: typeColor)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Info rows
          _buildInfoRow(Icons.tag, 'Code: ${acte.code}'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.calendar_today, acte.dateRealisation),
          const SizedBox(height: 8),
          if (acte.medecin != null && acte.medecin!.isNotEmpty)
            _buildInfoRow(Icons.person_outline, acte.medecin!),
          if (acte.medecin != null && acte.medecin!.isNotEmpty)
            const SizedBox(height: 8),
          
          // Price
          Row(
            children: [
              Icon(Icons.attach_money, size: 18, color: Colors.grey[500]),
              const SizedBox(width: 8),
              Text(
                '${acte.tarif.toStringAsFixed(2)} €',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
              ),
            ],
          ),
          
          // Notes
          if (acte.notes != null && acte.notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(acte.notes!, style: TextStyle(fontSize: 13, color: Colors.grey[500], fontStyle: FontStyle.italic)),
          ],
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showActeDialog(acte),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Modifier'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF14B8A6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showDeleteConfirmation(acte, provider),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Supprimer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF14B8A6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[500]),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
      ],
    );
  }

  void _showActeDialog(ActeMedical? acte) {
    final formKey = GlobalKey<FormState>();
    final codeController = TextEditingController(text: acte?.code ?? '');
    final libelleController = TextEditingController(text: acte?.libelle ?? '');
    final tarifController = TextEditingController(text: acte?.tarif.toString() ?? '0.00');
    final medecinController = TextEditingController(text: acte?.medecin ?? '');
    final notesController = TextEditingController(text: acte?.notes ?? '');
    String selectedType = acte?.type ?? 'CONSULTATION';
    int? selectedSejourId = acte?.sejourId;
    DateTime selectedDate = acte != null ? DateTime.tryParse(acte.dateRealisation) ?? DateTime.now() : DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 450,
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            acte == null ? 'Nouvel Acte Médical' : 'Modifier Acte Médical',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
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
                          // Séjour dropdown
                          const Text('Séjour *', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          Consumer<SejourProvider>(
                            builder: (context, sejourProvider, _) {
                              return DropdownButtonFormField<int>(
                                value: selectedSejourId,
                                decoration: InputDecoration(
                                  hintText: 'Sélectionner un séjour',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                ),
                                items: sejourProvider.sejours.map((s) {
                                  return DropdownMenuItem(value: s.id, child: Text('Séjour #${s.id} - ${s.motif}'));
                                }).toList(),
                                onChanged: (v) => setState(() => selectedSejourId = v),
                                validator: (v) => v == null ? 'Veuillez sélectionner un séjour' : null,
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Code and Type row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Code *', style: TextStyle(fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: codeController,
                                      decoration: InputDecoration(
                                        hintText: 'Ex: CONS001',
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                      ),
                                      validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Type *', style: TextStyle(fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 8),
                                    DropdownButtonFormField<String>(
                                      value: selectedType,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                      ),
                                      items: ['CONSULTATION', 'EXAMEN', 'INTERVENTION', 'ANALYSE'].map((t) {
                                        return DropdownMenuItem(value: t, child: Text(t));
                                      }).toList(),
                                      onChanged: (v) { if (v != null) setState(() => selectedType = v); },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Libellé
                          const Text('Libellé *', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: libelleController,
                            decoration: InputDecoration(
                              hintText: 'Description de l\'acte',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            ),
                            validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                          ),
                          const SizedBox(height: 16),
                          
                          // Date and Tarif row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Date de réalisation *', style: TextStyle(fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 8),
                                    InkWell(
                                      onTap: () async {
                                        final picked = await showDatePicker(
                                          context: context,
                                          initialDate: selectedDate,
                                          firstDate: DateTime(2020),
                                          lastDate: DateTime(2030),
                                        );
                                        if (picked != null) setState(() => selectedDate = picked);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.grey[400]!),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(child: Text(DateFormat('dd/MM/yyyy').format(selectedDate))),
                                            Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
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
                                    const Text('Tarif (€) *', style: TextStyle(fontWeight: FontWeight.w500)),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: tarifController,
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(
                                        hintText: '0.00',
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                      ),
                                      validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Médecin
                          const Text('Médecin', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: medecinController,
                            decoration: InputDecoration(
                              hintText: 'Dr. Martin',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Notes
                          const Text('Notes', style: TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: notesController,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Observations, commentaires...',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  
                  // Action buttons
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF14B8A6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Annuler', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate() && selectedSejourId != null) {
                              final newActe = ActeMedical(
                                id: acte?.id ?? 0,
                                sejourId: selectedSejourId!,
                                code: codeController.text.trim(),
                                libelle: libelleController.text.trim(),
                                type: selectedType,
                                dateRealisation: DateFormat('yyyy-MM-dd').format(selectedDate),
                                tarif: double.tryParse(tarifController.text) ?? 0.0,
                                medecin: medecinController.text.trim().isEmpty ? null : medecinController.text.trim(),
                                notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                              );

                              final provider = context.read<ActeMedicalProvider>();
                              Navigator.pop(context);
                              
                              bool success;
                              if (acte == null) {
                                success = await provider.createActeMedical(newActe);
                              } else {
                                success = await provider.updateActeMedical(acte.id, newActe);
                              }
                              
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(success ? 'Acte ${acte == null ? "créé" : "modifié"} avec succès' : 'Erreur'),
                                    backgroundColor: success ? Colors.green : Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0284C7),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Créer', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(ActeMedical acte, ActeMedicalProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'acte'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${acte.libelle}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.deleteActeMedical(acte.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Acte supprimé avec succès'), backgroundColor: Colors.green),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
