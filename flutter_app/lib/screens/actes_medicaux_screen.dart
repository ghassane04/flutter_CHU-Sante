import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/providers/acte_medical_provider.dart';
import 'package:flutter_app/providers/sejour_provider.dart';
import 'package:flutter_app/models/acte_medical.dart';

class ActesMedicauxScreen extends StatefulWidget {
  const ActesMedicauxScreen({Key? key}) : super(key: key);

  @override
  State<ActesMedicauxScreen> createState() => _ActesMedicauxScreenState();
}

class _ActesMedicauxScreenState extends State<ActesMedicauxScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ActeMedicalProvider>().loadActesMedicaux();
      context.read<SejourProvider>().loadSejours();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ActeMedicalProvider>(
      builder: (context, acteProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Medical Acts'),
          ),
          body: acteProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : acteProvider.error != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: ${acteProvider.error}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () =>
                                acteProvider.loadActesMedicaux(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  : acteProvider.actes.isEmpty
                      ? const Center(
                          child: Text('No actes found'),
                        )
                      : ListView.builder(
                          itemCount: acteProvider.actes.length,
                          itemBuilder: (context, index) {
                            final acte = acteProvider.actes[index];
                            return ActeMedicalListTile(
                              acte: acte,
                              onEdit: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ActeMedicalFormScreen(acte: acte),
                                  ),
                                );
                              },
                              onDelete: () {
                                _showDeleteConfirmation(
                                    context, acteProvider, acte.id);
                              },
                            );
                          },
                        ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ActeMedicalFormScreen(),
                ),
              );
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, ActeMedicalProvider provider, int acteId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Acte'),
        content:
            const Text('Are you sure you want to delete this medical act?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.deleteActeMedical(acteId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class ActeMedicalListTile extends StatelessWidget {
  final ActeMedical acte;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ActeMedicalListTile({
    Key? key,
    required this.acte,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text('${acte.code} - ${acte.libelle}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${acte.type}'),
            Text('Tarif: ${acte.tarif}€'),
            Text('Date: ${acte.dateRealisation}'),
            if (acte.medecin != null) Text('Medecin: ${acte.medecin}'),
          ],
        ),
        trailing: SizedBox(
          width: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: onEdit,
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActeMedicalFormScreen extends StatefulWidget {
  final ActeMedical? acte;

  const ActeMedicalFormScreen({Key? key, this.acte}) : super(key: key);

  @override
  State<ActeMedicalFormScreen> createState() => _ActeMedicalFormScreenState();
}

class _ActeMedicalFormScreenState extends State<ActeMedicalFormScreen> {
  late TextEditingController _sejourIdController;
  late TextEditingController _codeController;
  late TextEditingController _libelleController;
  late TextEditingController _typeController;
  late TextEditingController _dateRealisationController;
  late TextEditingController _tarifController;
  late TextEditingController _medecinController;
  late TextEditingController _notesController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _sejourIdController =
        TextEditingController(text: widget.acte?.sejourId.toString() ?? '');
    _codeController =
        TextEditingController(text: widget.acte?.code ?? '');
    _libelleController =
        TextEditingController(text: widget.acte?.libelle ?? '');
    _typeController =
        TextEditingController(text: widget.acte?.type ?? '');
    _dateRealisationController =
        TextEditingController(text: widget.acte?.dateRealisation ?? '');
    _tarifController =
        TextEditingController(text: widget.acte?.tarif.toString() ?? '');
    _medecinController =
        TextEditingController(text: widget.acte?.medecin ?? '');
    _notesController =
        TextEditingController(text: widget.acte?.notes ?? '');
  }

  @override
  void dispose() {
    _sejourIdController.dispose();
    _codeController.dispose();
    _libelleController.dispose();
    _typeController.dispose();
    _dateRealisationController.dispose();
    _tarifController.dispose();
    _medecinController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitForm(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final acteProvider = context.read<ActeMedicalProvider>();
    final acte = ActeMedical(
      id: widget.acte?.id ?? 0,
      sejourId: int.parse(_sejourIdController.text),
      code: _codeController.text,
      libelle: _libelleController.text,
      type: _typeController.text,
      dateRealisation: _dateRealisationController.text,
      tarif: double.parse(_tarifController.text),
      medecin: _medecinController.text,
      notes: _notesController.text,
    );

    bool success;
    if (widget.acte == null) {
      success = await acteProvider.createActeMedical(acte);
    } else {
      success = await acteProvider.updateActeMedical(widget.acte!.id, acte);
    }

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Acte saved successfully')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(acteProvider.error ?? 'Error saving acte')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.acte == null ? 'Add Acte' : 'Edit Acte'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _sejourIdController,
                decoration: const InputDecoration(
                  labelText: 'Sejour ID',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter sejour ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Code',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _libelleController,
                decoration: const InputDecoration(
                  labelText: 'Libelle',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter libelle';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateRealisationController,
                decoration: const InputDecoration(
                  labelText: 'Date Realisation (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tarifController,
                decoration: const InputDecoration(
                  labelText: 'Tarif',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter tarif';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _medecinController,
                decoration: const InputDecoration(
                  labelText: 'Medecin',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => _submitForm(context),
                  child: Text(
                    widget.acte == null
                        ? 'Create Acte'
                        : 'Update Acte',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
