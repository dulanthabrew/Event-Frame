// ignore_for_file: deprecated_member_use
// 🚀 EventFrame — Demo Entry Point (no Firebase needed)
// Run: flutter run -d chrome -t lib/demo_main.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

// ── Brand Colors ─────────────────────────────────────────────────────────────
const kPrimary = Color(0xFF6C63FF);
const kAccent = Color(0xFFFF6584);
const kSuccess = Color(0xFF2DD4BF);
const kWarning = Color(0xFFFBBF24);
const kError = Color(0xFFEF4444);
const kBgDark = Color(0xFF0F0F1A);
const kSurfaceDark = Color(0xFF1A1A2E);
const kCardDark = Color(0xFF232338);
const kSubtextDark = Color(0xFF9090B0);

// ── Router ────────────────────────────────────────────────────────────────────
final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/admin', builder: (_, __) => const AdminDashboard()),
    GoRoute(
        path: '/admin/studios',
        builder: (_, __) => const StudioManagementScreen()),
    GoRoute(
        path: '/admin/plans', builder: (_, __) => const PlanManagementScreen()),
    GoRoute(
        path: '/photographer',
        builder: (_, __) => const PhotographerDashboard()),
    GoRoute(
        path: '/photographer/events/new',
        builder: (_, __) => const CreateEventScreen()),
    GoRoute(
      path: '/photographer/events/:id',
      builder: (_, state) =>
          EventDetailScreen(eventId: state.pathParameters['id']!),
    ),
    GoRoute(path: '/client', builder: (_, __) => const ClientCodeEntryScreen()),
    GoRoute(
      path: '/gallery/:code',
      builder: (_, state) =>
          GalleryScreen(eventCode: state.pathParameters['code']!),
    ),
  ],
);

void main() => runApp(const EventFrameDemo());

class EventFrameDemo extends StatelessWidget {
  const EventFrameDemo({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'EventFrame Demo',
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
        theme: _lightTheme,
        darkTheme: _darkTheme,
        themeMode: ThemeMode.dark,
      );
}

// ── Themes ────────────────────────────────────────────────────────────────────
final _darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: kPrimary,
    secondary: kAccent,
    surface: kSurfaceDark,
    error: kError,
  ),
  scaffoldBackgroundColor: kBgDark,
  textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
  appBarTheme: const AppBarTheme(
    backgroundColor: kSurfaceDark,
    elevation: 0,
    foregroundColor: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kPrimary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15),
    ),
  ),
  cardTheme: CardThemeData(
    color: kCardDark,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: kCardDark,
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: kPrimary, width: 2)),
    labelStyle: const TextStyle(color: kSubtextDark),
    hintStyle: const TextStyle(color: kSubtextDark),
  ),
  chipTheme: ChipThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),
);

final _lightTheme = _darkTheme.copyWith(brightness: Brightness.light);

// ════════════════════════════════════════════════════════════════════════════════
// 1. LOGIN SCREEN
// ════════════════════════════════════════════════════════════════════════════════
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _showEmail = false;
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(36),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(children: [
              // Logo
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [kPrimary, kAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                        color: kPrimary.withOpacity(0.4),
                        blurRadius: 32,
                        offset: const Offset(0, 12))
                  ],
                ),
                child: const Icon(Icons.photo_camera_rounded,
                    color: Colors.white, size: 48),
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .scale(begin: const Offset(0.8, 0.8)),

              const SizedBox(height: 28),
              Text('EventFrame',
                      style: GoogleFonts.inter(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: kPrimary))
                  .animate()
                  .fadeIn(delay: 150.ms)
                  .slideY(begin: 0.3),
              const SizedBox(height: 8),
              Text('Your memories, beautifully delivered.',
                      style:
                          GoogleFonts.inter(fontSize: 14, color: kSubtextDark),
                      textAlign: TextAlign.center)
                  .animate()
                  .fadeIn(delay: 250.ms),

              const SizedBox(height: 40),

              // Demo Role Chips
              _GlassCard(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 16, color: kPrimary),
                        const SizedBox(width: 8),
                        Text('DEMO MODE — Pick your role',
                            style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: kPrimary,
                                letterSpacing: 1)),
                      ]),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(
                            child: _RoleButton(
                                emoji: '🔴',
                                label: 'Admin',
                                onTap: () => context.go('/admin'))),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _RoleButton(
                                emoji: '📷',
                                label: 'Photographer',
                                onTap: () => context.go('/photographer'))),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _RoleButton(
                                emoji: '👤',
                                label: 'Client',
                                onTap: () => context.go('/client'))),
                      ]),
                    ]),
              ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2),

              const SizedBox(height: 24),
              _Divider(label: 'or sign in'),
              const SizedBox(height: 24),

              // Google Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/photographer'),
                  icon: const Icon(Icons.g_mobiledata_rounded, size: 24),
                  label: const Text('Continue with Google'),
                ),
              ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.2),

              const SizedBox(height: 12),

              if (_showEmail) ...[
                TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                        labelText: 'Email address',
                        prefixIcon: Icon(Icons.email_outlined))),
                const SizedBox(height: 10),
                SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                        onPressed: () {},
                        child: const Text('Send Magic Link'))),
              ] else
                TextButton(
                    onPressed: () => setState(() => _showEmail = true),
                    child: Text('Client? Use email link instead',
                        style: GoogleFonts.inter(
                            color: kSubtextDark, fontSize: 13))),
            ]),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// 2. ADMIN DASHBOARD
// ════════════════════════════════════════════════════════════════════════════════
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.go('/login')),
        title: const Text('Admin Portal'),
        actions: [
          const CircleAvatar(
              backgroundColor: kPrimary,
              radius: 18,
              child: Icon(Icons.person_rounded, size: 18, color: Colors.white)),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(children: [
        // Left rail nav (for wider screens)
        NavigationRail(
          backgroundColor: kSurfaceDark,
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          extended: MediaQuery.of(context).size.width > 900,
          selectedIconTheme: const IconThemeData(color: kPrimary),
          destinations: const [
            NavigationRailDestination(
                icon: Icon(Icons.dashboard_rounded), label: Text('Overview')),
            NavigationRailDestination(
                icon: Icon(Icons.store_rounded), label: Text('Studios')),
            NavigationRailDestination(
                icon: Icon(Icons.credit_card_rounded), label: Text('Plans')),
            NavigationRailDestination(
                icon: Icon(Icons.analytics_rounded), label: Text('Analytics')),
          ],
        ),
        const VerticalDivider(width: 1),
        Expanded(
            child: [
          const _AdminOverview(),
          const StudioManagementScreen(embedded: true),
          const PlanManagementScreen(embedded: true),
          const _AdminAnalytics(),
        ][_tab]),
      ]),
    );
  }
}

class _AdminOverview extends StatelessWidget {
  const _AdminOverview();
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(24), children: [
      Text('Good evening, Admin 👋',
          style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      Text('Here\'s your platform at a glance.',
          style: GoogleFonts.inter(fontSize: 13, color: kSubtextDark)),
      const SizedBox(height: 24),

      // Stats grid
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: MediaQuery.of(context).size.width > 700 ? 4 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.6,
        children: const [
          _StatCard(
              value: '34',
              label: 'Active Studios',
              icon: Icons.store_rounded,
              color: kPrimary),
          _StatCard(
              value: '1.8k',
              label: 'Total Users',
              icon: Icons.people_rounded,
              color: kSuccess),
          _StatCard(
              value: '\$4,200',
              label: 'Monthly Revenue',
              icon: Icons.attach_money_rounded,
              color: kAccent),
          _StatCard(
              value: '12',
              label: 'Pending Approvals',
              icon: Icons.pending_actions_rounded,
              color: kWarning),
        ],
      ),

      const SizedBox(height: 28),
      Text('Pending Studio Approvals',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 12),

      ..._pendingStudios
          .take(3)
          .map((s) => _StudioApprovalCard(studio: s))
          .toList(),
    ]);
  }
}

class _AdminAnalytics extends StatelessWidget {
  const _AdminAnalytics();
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.analytics_rounded, size: 64, color: kPrimary),
      const SizedBox(height: 16),
      Text('Revenue Analytics',
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      Text('Charts coming in the next sprint!',
          style: GoogleFonts.inter(color: kSubtextDark)),
    ]));
  }
}

// ── Studio Management ────────────────────────────────────────────────────────
class StudioManagementScreen extends StatefulWidget {
  final bool embedded;
  const StudioManagementScreen({super.key, this.embedded = false});
  @override
  State<StudioManagementScreen> createState() => _StudioMgmtState();
}

class _StudioMgmtState extends State<StudioManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabCtrl;
  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body = Column(children: [
      TabBar(controller: _tabCtrl, tabs: const [
        Tab(text: 'Pending Approval'),
        Tab(text: 'Active Studios')
      ]),
      Expanded(
          child: TabBarView(controller: _tabCtrl, children: [
        ListView(
            padding: const EdgeInsets.all(16),
            children: _pendingStudios
                .map((s) => _StudioApprovalCard(studio: s))
                .toList()),
        ListView(
            padding: const EdgeInsets.all(16),
            children: _activeStudios
                .map((s) => _ActiveStudioCard(studio: s))
                .toList()),
      ])),
    ]);

    if (widget.embedded) return body;
    return Scaffold(
        appBar: AppBar(title: const Text('Studio Management')), body: body);
  }
}

// ── Plan Management ─────────────────────────────────────────────────────────
class PlanManagementScreen extends StatelessWidget {
  final bool embedded;
  const PlanManagementScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    Widget body = ListView(padding: const EdgeInsets.all(20), children: [
      if (!embedded) ...[
        Text('Membership Plans',
            style:
                GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Photographer subscription tiers',
            style: GoogleFonts.inter(color: kSubtextDark, fontSize: 13)),
        const SizedBox(height: 24),
      ],
      ..._plans.map((p) => _PlanCard(plan: p)).toList(),
    ]);

    if (embedded) return body;
    return Scaffold(appBar: AppBar(title: const Text('Plans')), body: body);
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// 3. PHOTOGRAPHER DASHBOARD
// ════════════════════════════════════════════════════════════════════════════════
class PhotographerDashboard extends StatefulWidget {
  const PhotographerDashboard({super.key});
  @override
  State<PhotographerDashboard> createState() => _PhotographerDashboardState();
}

class _PhotographerDashboardState extends State<PhotographerDashboard> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(children: [
        NavigationRail(
          backgroundColor: kSurfaceDark,
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          extended: MediaQuery.of(context).size.width > 900,
          selectedIconTheme: const IconThemeData(color: kPrimary),
          leading: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(children: [
              IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.go('/login')),
              const SizedBox(height: 8),
              const CircleAvatar(
                  backgroundColor: kPrimary,
                  radius: 22,
                  child: Icon(Icons.camera_alt_rounded,
                      color: Colors.white, size: 22)),
            ]),
          ),
          destinations: const [
            NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded),
                label: Text('Dashboard')),
            NavigationRailDestination(
                icon: Icon(Icons.event_outlined),
                selectedIcon: Icon(Icons.event_rounded),
                label: Text('Events')),
            NavigationRailDestination(
                icon: Icon(Icons.credit_card_outlined),
                selectedIcon: Icon(Icons.credit_card_rounded),
                label: Text('Plan')),
          ],
        ),
        const VerticalDivider(width: 1),
        Expanded(
            child: [
          const _PhotographerHome(),
          const _PhotographerEvents(),
          const _SubscriptionScreen(),
        ][_tab]),
      ]),
    );
  }
}

class _PhotographerHome extends StatelessWidget {
  const _PhotographerHome();
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(24), children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Hey, Dulan! 👋',
              style:
                  GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700)),
          Text('Lumina Studio  •  Pro Plan',
              style: GoogleFonts.inter(fontSize: 13, color: kSubtextDark)),
        ]),
        ElevatedButton.icon(
          onPressed: () => context.go('/photographer/events/new'),
          icon: const Icon(Icons.add_rounded),
          label: const Text('New Event'),
        ),
      ]),
      const SizedBox(height: 24),
      GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: MediaQuery.of(context).size.width > 700 ? 3 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.7,
        children: const [
          _StatCard(
              value: '12',
              label: 'Total Events',
              icon: Icons.event_rounded,
              color: kPrimary),
          _StatCard(
              value: '84',
              label: 'Clients Served',
              icon: Icons.people_rounded,
              color: kSuccess),
          _StatCard(
              value: '1.2k',
              label: 'Photos Delivered',
              icon: Icons.photo_library_rounded,
              color: kAccent),
        ],
      ),
      const SizedBox(height: 28),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Recent Events',
            style:
                GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
        TextButton(onPressed: () {}, child: const Text('See all')),
      ]),
      const SizedBox(height: 12),
      ..._events
          .take(4)
          .map((e) => _EventListCard(
              event: e,
              onTap: () => context.go('/photographer/events/${e.id}')))
          .toList(),
    ]);
  }
}

class _PhotographerEvents extends StatelessWidget {
  const _PhotographerEvents();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(padding: const EdgeInsets.all(24), children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('My Events',
              style:
                  GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
          ElevatedButton.icon(
            onPressed: () => context.go('/photographer/events/new'),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('New Event'),
          ),
        ]),
        const SizedBox(height: 20),
        ..._events
            .map((e) => _EventListCard(
                event: e,
                onTap: () => context.go('/photographer/events/${e.id}')))
            .toList(),
      ]),
    );
  }
}

// ── Create Event ──────────────────────────────────────────────────────────────
class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});
  @override
  State<CreateEventScreen> createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEventScreen> {
  final _nameCtrl = TextEditingController();
  final _dateCtrl = TextEditingController(text: 'March 15, 2026');
  final _codeCtrl = TextEditingController(text: 'SMITH26');
  bool _watermark = false;
  bool _qrGenerated = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dateCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => context.go('/photographer')),
        title: const Text('Create New Event'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
                onPressed: () => setState(() => _qrGenerated = true),
                child: const Text('Create Event')),
          ),
        ],
      ),
      body: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Form
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _FormSection('Event Details', children: [
                TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Event name',
                        hintText: 'Smith & Silva Wedding')),
                const SizedBox(height: 14),
                TextField(
                    controller: _dateCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Event date',
                        prefixIcon: Icon(Icons.calendar_today_rounded))),
                const SizedBox(height: 14),
                TextField(
                  controller: _codeCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Access code',
                      prefixIcon: Icon(Icons.lock_rounded),
                      hintText: 'SMITH26'),
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 4,
                      fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text('Clients enter this code to access their gallery',
                    style:
                        GoogleFonts.inter(fontSize: 12, color: kSubtextDark)),
              ]),
              const SizedBox(height: 24),
              _FormSection('Options', children: [
                SwitchListTile(
                  value: _watermark,
                  onChanged: (v) => setState(() => _watermark = v),
                  title: const Text('Add watermark to photos'),
                  subtitle: const Text('Free plan only'),
                  contentPadding: EdgeInsets.zero,
                  activeColor: kPrimary,
                ),
              ]),
            ]),
          ),
        ),
        // QR Preview panel
        if (MediaQuery.of(context).size.width > 700) ...[
          const VerticalDivider(width: 1),
          SizedBox(
            width: 320,
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(children: [
                Text('Event QR Code',
                    style: GoogleFonts.inter(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('Share this for instant gallery access',
                    style: GoogleFonts.inter(fontSize: 12, color: kSubtextDark),
                    textAlign: TextAlign.center),
                const SizedBox(height: 24),
                if (_qrGenerated)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: kPrimary.withOpacity(0.2),
                            blurRadius: 24,
                            offset: const Offset(0, 8))
                      ],
                    ),
                    child: Column(children: [
                      QrImageView(
                        data:
                            'https://eventframe.app/event/${_codeCtrl.text.isEmpty ? "SMITH26" : _codeCtrl.text}',
                        version: QrVersions.auto,
                        size: 200,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(_codeCtrl.text.isEmpty ? 'SMITH26' : _codeCtrl.text,
                          style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 6,
                              color: kBgDark)),
                      const SizedBox(height: 4),
                      Text('eventframe.app',
                          style: GoogleFonts.inter(
                              fontSize: 11, color: Colors.grey)),
                    ]),
                  ).animate().fadeIn().scale()
                else
                  Container(
                    height: 260,
                    decoration: BoxDecoration(
                      color: kCardDark,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: kPrimary.withOpacity(0.3), width: 2),
                    ),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.qr_code_rounded,
                              size: 64, color: kSubtextDark),
                          const SizedBox(height: 12),
                          Text('Tap "Create Event"\nto generate QR code',
                              style: GoogleFonts.inter(
                                  color: kSubtextDark, fontSize: 13),
                              textAlign: TextAlign.center),
                        ]),
                  ),
                const SizedBox(height: 20),
                if (_qrGenerated) ...[
                  Row(children: [
                    Expanded(
                        child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.download_rounded, size: 18),
                            label: const Text('Save PNG'))),
                    const SizedBox(width: 10),
                    Expanded(
                        child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.share_rounded, size: 18),
                            label: const Text('Share'))),
                  ]),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.message_rounded, size: 18),
                    label: const Text('Send via WhatsApp'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366)),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ]),
    );
  }
}

// ── Event Detail ──────────────────────────────────────────────────────────────
class EventDetailScreen extends StatelessWidget {
  final String eventId;
  const EventDetailScreen({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final event =
        _events.firstWhere((e) => e.id == eventId, orElse: () => _events.first);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.go('/photographer')),
        title: Text(event.name),
        actions: [
          Chip(
              label: Text(event.code,
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                      fontSize: 13))),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView(padding: const EdgeInsets.all(24), children: [
        Row(children: [
          Expanded(
              child: _StatCard(
                  value: '${event.clientCount}',
                  label: 'Clients',
                  icon: Icons.people_rounded,
                  color: kPrimary)),
          const SizedBox(width: 12),
          Expanded(
              child: _StatCard(
                  value: '${event.photoCount}',
                  label: 'Photos',
                  icon: Icons.photo_library_rounded,
                  color: kSuccess)),
          const SizedBox(width: 12),
          Expanded(
              child: _StatCard(
                  value: '${event.delivered}%',
                  label: 'Delivered',
                  icon: Icons.cloud_done_rounded,
                  color: kAccent)),
        ]),
        const SizedBox(height: 28),
        Text('Clients',
            style:
                GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ..._clientsForEvent.map((c) => _ClientCard(client: c)).toList(),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(
              child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.upload_rounded),
                  label: const Text('Upload Photos'))),
          const SizedBox(width: 12),
          Expanded(
              child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.qr_code_rounded),
                  label: const Text('Show QR'))),
        ]),
      ]),
    );
  }
}

// ── Subscription ──────────────────────────────────────────────────────────────
class _SubscriptionScreen extends StatelessWidget {
  const _SubscriptionScreen();
  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(24), children: [
      Text('Your Subscription',
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      Text('Upgrade to unlock more features',
          style: GoogleFonts.inter(color: kSubtextDark, fontSize: 13)),
      const SizedBox(height: 24),
      ..._plans
          .map((p) => _PlanCard(plan: p, current: p.name == 'Pro'))
          .toList(),
    ]);
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// 4. CLIENT SCREENS
// ════════════════════════════════════════════════════════════════════════════════
class ClientCodeEntryScreen extends StatefulWidget {
  const ClientCodeEntryScreen({super.key});
  @override
  State<ClientCodeEntryScreen> createState() => _ClientCodeEntryState();
}

class _ClientCodeEntryState extends State<ClientCodeEntryScreen> {
  final _ctrl = TextEditingController(text: 'SMITH26');
  bool _loading = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(36),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [kPrimary, kAccent]),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                        color: kPrimary.withOpacity(0.4),
                        blurRadius: 28,
                        offset: const Offset(0, 10))
                  ],
                ),
                child: const Icon(Icons.qr_code_rounded,
                    color: Colors.white, size: 48),
              ).animate().fadeIn().scale(),
              const SizedBox(height: 32),
              Text('Enter Event Code',
                      style: GoogleFonts.inter(
                          fontSize: 28, fontWeight: FontWeight.w800))
                  .animate()
                  .fadeIn(delay: 150.ms),
              const SizedBox(height: 8),
              Text('Type the code from your photographer or scan the QR code',
                      style:
                          GoogleFonts.inter(fontSize: 14, color: kSubtextDark),
                      textAlign: TextAlign.center)
                  .animate()
                  .fadeIn(delay: 250.ms),
              const SizedBox(height: 40),
              TextField(
                controller: _ctrl,
                textCapitalization: TextCapitalization.characters,
                textAlign: TextAlign.center,
                maxLength: 8,
                style: GoogleFonts.inter(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 10),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'CODE',
                  hintStyle: GoogleFonts.inter(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 10,
                      color: kSubtextDark.withOpacity(0.4)),
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                ),
              ).animate().fadeIn(delay: 350.ms),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading
                      ? null
                      : () async {
                          setState(() => _loading = true);
                          await Future.delayed(
                              const Duration(milliseconds: 900));
                          if (context.mounted)
                            context.go(
                                '/gallery/${_ctrl.text.trim().toUpperCase()}');
                        },
                  child: _loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Access My Gallery'),
                ),
              ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.3),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                label: Text('Scan QR Code instead',
                    style: GoogleFonts.inter(color: kSubtextDark)),
              ),
              const SizedBox(height: 24),
              TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text('← Back',
                      style: GoogleFonts.inter(color: kSubtextDark))),
            ]),
          ),
        ),
      ),
    );
  }
}

// ── Gallery ───────────────────────────────────────────────────────────────────
class GalleryScreen extends StatefulWidget {
  final String eventCode;
  const GalleryScreen({super.key, required this.eventCode});
  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  int? _selectedPhoto;
  final List<Color> _colors = const [
    kPrimary,
    kAccent,
    kSuccess,
    Color(0xFF8B5CF6),
    kWarning,
    Color(0xFF06B6D4)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.go('/client')),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Smith Wedding 2026',
              style:
                  GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 15)),
          Text('${widget.eventCode}  •  486 photos',
              style: GoogleFonts.inter(fontSize: 11, color: kSubtextDark)),
        ]),
        actions: [
          IconButton(
              icon: const Icon(Icons.download_rounded),
              onPressed: () {},
              tooltip: 'Download all'),
          IconButton(
              icon: const Icon(Icons.share_rounded),
              onPressed: () {},
              tooltip: 'Share'),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(children: [
        // Drive info banner
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
              kPrimary.withOpacity(0.15),
              kAccent.withOpacity(0.08)
            ]),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kPrimary.withOpacity(0.3)),
          ),
          child: Row(children: [
            const Icon(Icons.cloud_done_rounded, color: kSuccess, size: 22),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Photos saved to your Google Drive',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  Text('Accessible anytime from drive.google.com',
                      style:
                          GoogleFonts.inter(fontSize: 11, color: kSubtextDark)),
                ])),
            TextButton(onPressed: () {}, child: const Text('Open Drive')),
          ]),
        ).animate().fadeIn(),

        // Photo Grid
        Expanded(
          child: _selectedPhoto == null
              ? GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 900
                        ? 5
                        : MediaQuery.of(context).size.width > 600
                            ? 4
                            : 3,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: 48,
                  itemBuilder: (ctx, i) {
                    final c = _colors[i % _colors.length];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedPhoto = i),
                      child: Container(
                        decoration: BoxDecoration(
                          color: c.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(children: [
                          Center(
                              child: Icon(Icons.photo_rounded,
                                  color: c, size: 32)),
                          Positioned(
                              right: 6,
                              bottom: 4,
                              child: Text('DSC_${1000 + i}',
                                  style: const TextStyle(
                                      fontSize: 8,
                                      color: Colors.white70,
                                      fontWeight: FontWeight.w600))),
                        ]),
                      ).animate().fadeIn(delay: Duration(milliseconds: i * 20)),
                    );
                  },
                )
              : _PhotoViewer(
                  photoIndex: _selectedPhoto!,
                  color: _colors[_selectedPhoto! % _colors.length],
                  onClose: () => setState(() => _selectedPhoto = null),
                ),
        ),
      ]),
    );
  }
}

class _PhotoViewer extends StatelessWidget {
  final int photoIndex;
  final Color color;
  final VoidCallback onClose;
  const _PhotoViewer(
      {required this.photoIndex, required this.color, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Stack(children: [
        Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
                color: color.withOpacity(0.25),
                borderRadius: BorderRadius.circular(16)),
            child: Icon(Icons.photo_rounded, color: color, size: 80),
          ),
          const SizedBox(height: 20),
          Text('DSC_${1000 + photoIndex}',
              style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
        ])).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
        Positioned(
            top: 16,
            right: 16,
            child: IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: onClose)),
        Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text('Download')),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.shopping_cart_rounded, size: 18),
                label: const Text('Order Print'),
                style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white30)),
              ),
            ])),
      ]),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════════
// SHARED COMPONENTS
// ════════════════════════════════════════════════════════════════════════════════

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kCardDark.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kPrimary.withOpacity(0.25)),
        ),
        child: child,
      );
}

class _RoleButton extends StatelessWidget {
  final String emoji, label;
  final VoidCallback onTap;
  const _RoleButton(
      {required this.emoji, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimary.withOpacity(0.18),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: kPrimary.withOpacity(0.4))),
          elevation: 0,
        ),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(label,
              style:
                  GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700)),
        ]),
      );
}

class _Divider extends StatelessWidget {
  final String label;
  const _Divider({required this.label});
  @override
  Widget build(BuildContext context) => Row(children: [
        const Expanded(child: Divider()),
        Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(label,
                style: GoogleFonts.inter(color: kSubtextDark, fontSize: 12))),
        const Expanded(child: Divider()),
      ]);
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  const _StatCard(
      {required this.value,
      required this.label,
      required this.icon,
      required this.color});
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
            padding: const EdgeInsets.all(14),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 10),
              Text(value,
                  style: GoogleFonts.inter(
                      fontSize: 22, fontWeight: FontWeight.w800)),
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      color: kSubtextDark,
                      fontWeight: FontWeight.w500)),
            ])),
      );
}

class _FormSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _FormSection(this.title, {required this.children});
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: kSubtextDark,
                letterSpacing: 0.5)),
        const SizedBox(height: 14),
        Card(
            child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: children))),
      ]);
}

class _EventListCard extends StatelessWidget {
  final _EventData event;
  final VoidCallback onTap;
  const _EventListCard({required this.event, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                        gradient:
                            const LinearGradient(colors: [kPrimary, kAccent]),
                        borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.photo_album_rounded,
                        color: Colors.white, size: 24)),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(event.name,
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w700, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(
                          '${event.clientCount} clients  •  ${event.photoCount} photos',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: kSubtextDark)),
                    ])),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: kPrimary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(event.code,
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              letterSpacing: 2,
                              color: kPrimary))),
                  const SizedBox(height: 4),
                  Text(event.date,
                      style:
                          GoogleFonts.inter(fontSize: 11, color: kSubtextDark)),
                ]),
              ])),
        ),
      );
}

class _StudioApprovalCard extends StatefulWidget {
  final _StudioData studio;
  const _StudioApprovalCard({required this.studio});
  @override
  State<_StudioApprovalCard> createState() => _StudioApprovalCardState();
}

class _StudioApprovalCardState extends State<_StudioApprovalCard> {
  String? _status;
  @override
  Widget build(BuildContext context) {
    if (_status != null)
      return Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: Icon(
              _status == 'approved'
                  ? Icons.check_circle_rounded
                  : Icons.cancel_rounded,
              color: _status == 'approved' ? kSuccess : kError),
          title: Text(widget.studio.name),
          subtitle: Text(_status == 'approved' ? 'Approved ✓' : 'Rejected'),
        ),
      );
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            CircleAvatar(
                backgroundColor: kPrimary.withOpacity(0.2),
                radius: 22,
                child: Text(widget.studio.name[0],
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        color: kPrimary,
                        fontSize: 18))),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(widget.studio.name,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                  Text(widget.studio.email,
                      style:
                          GoogleFonts.inter(fontSize: 12, color: kSubtextDark)),
                  const SizedBox(height: 4),
                  Text(widget.studio.plan,
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: kPrimary,
                          fontWeight: FontWeight.w600)),
                ])),
            Row(children: [
              IconButton(
                  icon: const Icon(Icons.check_circle_rounded,
                      color: kSuccess, size: 28),
                  onPressed: () => setState(() => _status = 'approved'),
                  tooltip: 'Approve'),
              IconButton(
                  icon:
                      const Icon(Icons.cancel_rounded, color: kError, size: 28),
                  onPressed: () => setState(() => _status = 'rejected'),
                  tooltip: 'Reject'),
            ]),
          ])),
    );
  }
}

class _ActiveStudioCard extends StatelessWidget {
  final _StudioData studio;
  const _ActiveStudioCard({required this.studio});
  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: CircleAvatar(
              backgroundColor: kSuccess.withOpacity(0.2),
              child: Text(studio.name[0],
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800, color: kSuccess))),
          title: Text(studio.name,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(studio.email),
          trailing:
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Chip(
                label: Text(studio.plan,
                    style: GoogleFonts.inter(
                        fontSize: 11, fontWeight: FontWeight.w700)),
                backgroundColor: kPrimary.withOpacity(0.15),
                padding: EdgeInsets.zero),
          ]),
        ),
      );
}

class _ClientCard extends StatelessWidget {
  final _ClientData client;
  const _ClientCard({required this.client});
  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: CircleAvatar(
              backgroundColor: kPrimary.withOpacity(0.2),
              child: Text(client.name[0],
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800, color: kPrimary))),
          title: Text(client.name,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(client.email),
          trailing: Icon(
              client.delivered
                  ? Icons.cloud_done_rounded
                  : Icons.pending_rounded,
              color: client.delivered ? kSuccess : kWarning),
        ),
      );
}

class _PlanCard extends StatelessWidget {
  final _PlanData plan;
  final bool current;
  const _PlanCard({required this.plan, this.current = false});
  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
              color: current ? kPrimary : kPrimary.withOpacity(0.2),
              width: current ? 2 : 1),
        ),
        child: Padding(
            padding: const EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  Text(plan.emoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 10),
                  Text(plan.name,
                      style: GoogleFonts.inter(
                          fontSize: 18, fontWeight: FontWeight.w800)),
                ]),
                if (current)
                  Chip(
                      label: Text('Current Plan',
                          style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: kPrimary)),
                      backgroundColor: kPrimary.withOpacity(0.15)),
              ]),
              const SizedBox(height: 8),
              Text(plan.price,
                  style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: kPrimary)),
              const SizedBox(height: 12),
              ...plan.features.map((f) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(children: [
                      const Icon(Icons.check_circle_rounded,
                          color: kSuccess, size: 16),
                      const SizedBox(width: 8),
                      Text(f, style: GoogleFonts.inter(fontSize: 13)),
                    ]),
                  )),
              const SizedBox(height: 16),
              if (!current)
                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {},
                        child: Text('Upgrade to ${plan.name}'))),
            ])),
      );
}

// ════════════════════════════════════════════════════════════════════════════════
// DEMO DATA MODELS
// ════════════════════════════════════════════════════════════════════════════════
class _EventData {
  final String id, name, code, date;
  final int clientCount, photoCount, delivered;
  const _EventData(
      {required this.id,
      required this.name,
      required this.code,
      required this.date,
      required this.clientCount,
      required this.photoCount,
      required this.delivered});
}

class _StudioData {
  final String name, email, plan;
  const _StudioData(
      {required this.name, required this.email, required this.plan});
}

class _ClientData {
  final String name, email;
  final bool delivered;
  const _ClientData(
      {required this.name, required this.email, required this.delivered});
}

class _PlanData {
  final String name, price, emoji;
  final List<String> features;
  const _PlanData(
      {required this.name,
      required this.price,
      required this.emoji,
      required this.features});
}

const _events = [
  _EventData(
      id: 'ev1',
      name: 'Smith & Silva Wedding',
      code: 'SMITH26',
      date: 'Mar 15, 2026',
      clientCount: 24,
      photoCount: 486,
      delivered: 92),
  _EventData(
      id: 'ev2',
      name: 'Perera Graduation',
      code: 'PGRAD26',
      date: 'Mar 8, 2026',
      clientCount: 12,
      photoCount: 210,
      delivered: 100),
  _EventData(
      id: 'ev3',
      name: 'SLT Corporate Day',
      code: 'SLTCORP',
      date: 'Feb 28, 2026',
      clientCount: 38,
      photoCount: 790,
      delivered: 87),
  _EventData(
      id: 'ev4',
      name: 'Rajapaksa Birthday',
      code: 'RAJA26',
      date: 'Feb 14, 2026',
      clientCount: 8,
      photoCount: 134,
      delivered: 100),
];

final _pendingStudios = [
  const _StudioData(
      name: 'Lumina Studios', email: 'lumina@gmail.com', plan: 'Pro Plan'),
  const _StudioData(
      name: 'Pixel Perfect LK', email: 'pixel@studio.lk', plan: 'Basic Plan'),
  const _StudioData(
      name: 'Kalani Photography',
      email: 'kalani@photo.com',
      plan: 'Enterprise'),
];

final _activeStudios = [
  const _StudioData(
      name: 'Priya Visuals', email: 'priya@visuals.lk', plan: 'Pro'),
  const _StudioData(
      name: 'Lanka Moments', email: 'info@lankamoments.com', plan: 'Basic'),
  const _StudioData(
      name: 'Flash Photography', email: 'flash@photo.lk', plan: 'Free'),
  const _StudioData(
      name: 'Dulantha Studio', email: 'dulan@studio.com', plan: 'Enterprise'),
];

const _clientsForEvent = [
  _ClientData(name: 'Amara Silva', email: 'amara@gmail.com', delivered: true),
  _ClientData(
      name: 'Roshan Perera', email: 'roshan@icloud.com', delivered: true),
  _ClientData(
      name: 'Nadeeka Fernando', email: 'nadeeka@gmail.com', delivered: false),
  _ClientData(
      name: 'Kasun Rajapaksa', email: 'kasun@gmail.com', delivered: true),
];

const _plans = [
  _PlanData(name: 'Free', price: '\$0/month', emoji: '🆓', features: [
    '5 events/month',
    '100 photos/event',
    'Watermarked delivery',
    'Basic support'
  ]),
  _PlanData(name: 'Basic', price: '\$19/month', emoji: '⚡', features: [
    '25 events/month',
    '500 photos/event',
    'No watermarks',
    'Email support'
  ]),
  _PlanData(name: 'Pro', price: '\$49/month', emoji: '🚀', features: [
    'Unlimited events',
    'Unlimited photos',
    'QR code generator',
    'Photo sales feature',
    'Priority support'
  ]),
  _PlanData(name: 'Enterprise', price: 'Custom', emoji: '🏢', features: [
    'Everything in Pro',
    'White-label branding',
    'AI face recognition',
    'Dedicated account manager',
    'SLA guarantee'
  ]),
];
