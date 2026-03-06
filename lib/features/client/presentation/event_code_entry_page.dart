import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme/app_theme.dart';
import '../../photographer/data/event_repository.dart';

class EventCodeEntryPage extends ConsumerStatefulWidget {
  final String? prefilledCode;
  const EventCodeEntryPage({super.key, this.prefilledCode});

  @override
  ConsumerState<EventCodeEntryPage> createState() => _EventCodeEntryPageState();
}

class _EventCodeEntryPageState extends ConsumerState<EventCodeEntryPage> {
  late final TextEditingController _codeController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.prefilledCode ?? '');
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    setState(() => _loading = true);

    try {
      final event =
          await ref.read(eventRepositoryProvider).getEventByCode(code);

      if (mounted) {
        if (event != null) {
          context.go('/gallery/${event.id}');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid event code. Please check and try again.'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.accent],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.qr_code_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ).animate().fadeIn().scale(),

              const SizedBox(height: 24),

              Text(
                'Enter Event Code',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),

              const SizedBox(height: 8),

              Text(
                'Type the 6-character code from your photographer\nor scan the QR code.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ).animate().fadeIn(delay: 150.ms),

              const SizedBox(height: 36),

              // Code input
              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                maxLength: 8,
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 8,
                ),
                decoration: InputDecoration(
                  hintText: 'SMITH26',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 8,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.3),
                  ),
                  counterText: '',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _verifyCode,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Access My Gallery'),
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),

              const SizedBox(height: 16),

              // QR Scan option
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    // TODO: Open QR scanner
                  },
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  label: const Text('Scan QR Code instead'),
                ),
              ).animate().fadeIn(delay: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
