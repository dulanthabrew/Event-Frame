import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../app/theme/app_theme.dart';
import '../../../app/providers/auth_provider.dart';
import '../data/event_repository.dart';
import '../domain/event.dart';

class EventCreatePage extends ConsumerStatefulWidget {
  const EventCreatePage({super.key});

  @override
  ConsumerState<EventCreatePage> createState() => _EventCreatePageState();
}

class _EventCreatePageState extends ConsumerState<EventCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _dateController = TextEditingController();
  bool _watermarkEnabled = true;
  bool _isSaving = false;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _dateController.text =
        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _generateRandomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = List.generate(6, (index) {
      final idx =
          (DateTime.now().microsecondsSinceEpoch + index) % chars.length;
      return chars[idx];
    }).join();
    setState(() => _codeController.text = random);
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      final event = Event(
        id: '', // Supabase will auto-assign UUID
        name: _nameController.text.trim(),
        code: _codeController.text.trim().toUpperCase(),
        date: _selectedDate,
        photographerUid: user.id,
        watermarkEnabled: _watermarkEnabled,
        createdAt: DateTime.now(),
      );

      await ref.read(eventRepositoryProvider).createEvent(event);
      // Refresh the event list
      ref.invalidate(photographerEventsProvider);
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event created successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Event'),
        actions: [
          _isSaving
              ? const Center(
                  child: Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                ))
              : TextButton(
                  onPressed: _saveEvent,
                  child: const Text('SAVE'),
                ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Event Details',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                enabled: !_isSaving,
                decoration: const InputDecoration(
                  labelText: 'Event Name',
                  hintText: 'e.g., Smith Wedding 2026',
                  prefixIcon: Icon(Icons.drive_file_rename_outline_rounded),
                ),
                validator: (v) => v!.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _codeController,
                      enabled: !_isSaving,
                      decoration: const InputDecoration(
                        labelText: 'Access Code',
                        hintText: 'SMITH26',
                        prefixIcon: Icon(Icons.lock_rounded),
                      ),
                      validator: (v) => v!.length < 4 ? 'Min 4 chars' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: _isSaving ? null : _generateRandomCode,
                    icon: const Icon(Icons.autorenew_rounded),
                    tooltip: 'Generate Code',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                enabled: !_isSaving,
                decoration: const InputDecoration(
                  labelText: 'Event Date',
                  prefixIcon: Icon(Icons.calendar_today_rounded),
                ),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                      _dateController.text =
                          '${date.day}/${date.month}/${date.year}';
                    });
                  }
                },
              ),
              const SizedBox(height: 32),

              // QR Preview
              if (_codeController.text.isNotEmpty)
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: QrImageView(
                          data:
                              'https://eventframe.app/event/${_codeController.text}',
                          version: QrVersions.auto,
                          size: 160.0,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'QR code for instant access',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 24),

              Text(
                'Security & Options',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                value: _watermarkEnabled,
                onChanged: _isSaving
                    ? null
                    : (v) => setState(() => _watermarkEnabled = v),
                title: const Text('Apply Watermark'),
                subtitle: const Text('Add your studio logo to low-res photos'),
                contentPadding: EdgeInsets.zero,
                activeColor: AppTheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
