import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme/app_theme.dart';

class StudioManagementPage extends ConsumerStatefulWidget {
  const StudioManagementPage({super.key});

  @override
  ConsumerState<StudioManagementPage> createState() =>
      _StudioManagementPageState();
}

class _StudioManagementPageState extends ConsumerState<StudioManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Studio Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending Approval'),
            Tab(text: 'Active Studios'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _StudioList(status: 'pending'),
          _StudioList(status: 'active'),
        ],
      ),
    );
  }
}

class _StudioList extends StatelessWidget {
  final String status;

  const _StudioList({required this.status});

  @override
  Widget build(BuildContext context) {
    // TODO: Connect to Firestore stream
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: status == 'pending' ? 3 : 8,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: status == 'pending'
                  ? AppTheme.warning.withOpacity(0.1)
                  : AppTheme.success.withOpacity(0.1),
              child: Icon(
                status == 'pending'
                    ? Icons.timer_outlined
                    : Icons.check_circle_rounded,
                color:
                    status == 'pending' ? AppTheme.warning : AppTheme.success,
              ),
            ),
            title: Text(
              'Lumina Studio ${index + 1}',
              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('contact@lumina${index + 1}.lk'),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      'Colombo, Sri Lanka',
                      style: GoogleFonts.inter(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            trailing: status == 'pending'
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check_circle_rounded,
                            color: AppTheme.success),
                        onPressed: () {
                          // TODO: Approve studio
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel_rounded,
                            color: AppTheme.error),
                        onPressed: () {
                          // TODO: Reject studio
                        },
                      ),
                    ],
                  )
                : const Chip(
                    label: Text('PRO PLAN',
                        style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
          ),
        );
      },
    );
  }
}
