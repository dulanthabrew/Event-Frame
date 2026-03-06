import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme/app_theme.dart';
import '../../../app/providers/auth_provider.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Admin settings
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
            tooltip: 'Logout',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Header
          Text(
            'Platform Overview',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage studios, monitor revenue and platform growth.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 32),

          // Stats Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 1,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: const [
              _StatCard(
                title: 'Total Studios',
                value: '42',
                icon: Icons.store_rounded,
                color: AppTheme.primary,
              ),
              _StatCard(
                title: 'Total Revenue',
                value: '\$1,240',
                icon: Icons.attach_money_rounded,
                color: AppTheme.success,
              ),
              _StatCard(
                title: 'Pending Approvals',
                value: '5',
                icon: Icons.pending_actions_rounded,
                color: AppTheme.warning,
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Quick Actions
          Text(
            'Quick Actions',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          _QuickActionTile(
            title: 'Manage Studios',
            subtitle: 'Approve or reject photographer studio requests',
            icon: Icons.manage_accounts_rounded,
            onTap: () => context.go('/admin/studios'),
          ),
          const SizedBox(height: 12),
          _QuickActionTile(
            title: 'Membership Plans',
            subtitle: 'Configure subscription tiers and pricing',
            icon: Icons.credit_card_rounded,
            onTap: () => context.go('/admin/plans'),
          ),
          const SizedBox(height: 12),
          _QuickActionTile(
            title: 'User Management',
            subtitle: 'Manage all platform users and their roles',
            icon: Icons.people_outline_rounded,
            onTap: () => context.go('/admin/users'),
          ),
          const SizedBox(height: 12),
          _QuickActionTile(
            title: 'Platform Analytics',
            subtitle: 'Detailed breakdown of usage and growth',
            icon: Icons.analytics_rounded,
            onTap: () {
              // TODO: Analytics page
            },
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const Spacer(),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(fontSize: 12),
        ),
        trailing: Icon(icon, color: AppTheme.primary),
        onTap: onTap,
      ),
    );
  }
}
