import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/clan_provider.dart';
import '../utils/validators.dart';

class ClanCreationScreen extends StatefulWidget {
  const ClanCreationScreen({super.key});

  @override
  State<ClanCreationScreen> createState() => _ClanCreationScreenState();
}

class _ClanCreationScreenState extends State<ClanCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ClanProvider>();
    final success = await provider.createClan(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      createdByUserId: 'demo-user-id',
      location: _locationController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Clan created successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Unable to create clan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Clan'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Build your clan network',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create a shared space for members, contributions, and updates.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Clan name',
                    prefixIcon: Icon(Icons.group),
                  ),
                  validator: (value) => Validators.validateRequired(value, 'Clan name'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                    prefixIcon: Icon(Icons.description),
                  ),
                  validator: (value) => Validators.validateRequired(value, 'Description'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location (optional)',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 24),
                Consumer<ClanProvider>(
                  builder: (context, provider, _) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: provider.isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: provider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Create Clan'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
