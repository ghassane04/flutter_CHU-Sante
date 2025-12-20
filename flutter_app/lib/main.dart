import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/services/api_service.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/providers/patient_provider.dart';
import 'package:flutter_app/providers/service_provider.dart';
import 'package:flutter_app/providers/sejour_provider.dart';
import 'package:flutter_app/providers/acte_medical_provider.dart';
import 'package:flutter_app/providers/dashboard_provider.dart';
import 'package:flutter_app/providers/prediction_provider.dart';
import 'package:flutter_app/providers/investment_provider.dart';
import 'package:flutter_app/providers/alert_provider.dart';
import 'package:flutter_app/providers/report_provider.dart';
import 'package:flutter_app/providers/ai_provider.dart';
import 'package:flutter_app/providers/settings_provider.dart';
import 'package:flutter_app/providers/medecin_provider.dart';
import 'package:flutter_app/providers/user_provider.dart';
import 'package:flutter_app/screens/login_screen.dart';
import 'package:flutter_app/screens/dashboard_screen.dart';
import 'package:flutter_app/screens/predictions_screen.dart';
import 'package:flutter_app/screens/patients_screen.dart';
import 'package:flutter_app/screens/services_screen.dart';
import 'package:flutter_app/screens/sejours_screen.dart';
import 'package:flutter_app/screens/actes_medicaux_screen.dart';
import 'package:flutter_app/screens/ai_assistant_screen.dart';
import 'package:flutter_app/screens/investments_screen.dart';
import 'package:flutter_app/screens/alerts_screen.dart';
import 'package:flutter_app/screens/reports_screen.dart';
import 'package:flutter_app/screens/settings_screen.dart';
import 'package:flutter_app/screens/medecins_screen.dart';
import 'package:flutter_app/models/index.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();

    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => apiService),
        ChangeNotifierProvider(create: (_) => AuthProvider(apiService)),
        ChangeNotifierProvider(create: (_) => PatientProvider(apiService)),
        ChangeNotifierProvider(create: (_) => ServiceProvider(apiService)),
        ChangeNotifierProvider(create: (_) => SejourProvider(apiService)),
        ChangeNotifierProvider(create: (_) => ActeMedicalProvider(apiService)),
        ChangeNotifierProvider(create: (_) => DashboardProvider(apiService)),
        ChangeNotifierProvider(create: (_) => PredictionProvider(apiService)),
        ChangeNotifierProvider(create: (_) => InvestmentProvider(apiService)),
        ChangeNotifierProvider(create: (_) => AlertProvider(apiService)),
        ChangeNotifierProvider(create: (_) => ReportProvider(apiService)),
        ChangeNotifierProvider(create: (_) => AIProvider(apiService)),
        ChangeNotifierProvider(create: (_) => SettingsProvider(apiService)),
        ChangeNotifierProvider(create: (_) => MedecinProvider(apiService)),
        ChangeNotifierProvider(create: (_) => UserProvider(apiService)),
      ],
      child: MaterialApp(
        title: 'Healthcare Dashboard',
        theme: ThemeData(
          // Using grey-100 as the background color
          scaffoldBackgroundColor: const Color(0xFFF3F4F6), 
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0B6FB0)),
          useMaterial3: true,
          fontFamily: 'Inter', // Assumes Inter is available or falls back to system
        ),
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => _checkAuthentication(),
    );
  }

  Future<void> _checkAuthentication() async {
    // Token is loaded in ApiService, check if authenticated
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isAuthenticated) {
          return const MainAppScreen();
        } else {
          return LoginScreen(
            onLoginSuccess: () {
              setState(() {});
            },
          );
        }
      },
    );
  }
}

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({Key? key}) : super(key: key);

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<SettingsProvider>().fetchSettings();
    });
  }

  final List<Widget> _screens = const [
    DashboardScreen(),
    PredictionsScreen(),
    ServicesScreen(),
    MedecinsScreen(),
    PatientsScreen(),
    SejoursScreen(),
    ActesMedicauxScreen(),
    AIAssistantScreen(),
    InvestmentsScreen(),
    AlertsScreen(),
    ReportsScreen(),
    SettingsScreen(),
  ];

  final List<NavigationItem> _navItems = const [
    NavigationItem(id: 'dashboard', icon: Icons.grid_view, label: 'Tableau de bord'),
    NavigationItem(id: 'predictions', icon: Icons.trending_up, label: 'Prédictions'),
    NavigationItem(id: 'services', icon: Icons.business, label: 'Services'),
    NavigationItem(id: 'medecins', icon: Icons.manage_accounts, label: 'Médecins'),
    NavigationItem(id: 'patients', icon: Icons.people_outline, label: 'Patients'),
    NavigationItem(id: 'sejours', icon: Icons.bed, label: 'Séjours'),
    NavigationItem(id: 'actes', icon: Icons.medical_services_outlined, label: 'Actes Médicaux'),
    NavigationItem(id: 'ai', icon: Icons.smart_toy_outlined, label: 'Assistant IA'),
    NavigationItem(id: 'investments', icon: Icons.account_balance_wallet_outlined, label: 'Investissements'),
    NavigationItem(id: 'alerts', icon: Icons.warning_amber_rounded, label: 'Alertes'),
    NavigationItem(id: 'reports', icon: Icons.description_outlined, label: 'Rapports'),
    NavigationItem(id: 'settings', icon: Icons.settings_outlined, label: 'Paramètres'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar matched to React styling
          Container(
            width: 260, // React Sidebar is w-64 (16rem = 256px), close to 260
            color: const Color(0xFF0B6FB0), // React bg-[#0B6FB0]
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Border bottom blue-700)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFF1D4ED8)), // blue-700
                    ),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Consumer<SettingsProvider>(
                            builder: (context, settingsProvider, _) {
                              final appTitle = settingsProvider.getSettingValue('app_title') ?? 'CHU Santé';
                              return Text(
                                appTitle,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20, // text-xl
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 4),
                           const Text(
                            'Finance Dashboard',
                            style: TextStyle(
                              color: Color(0xFFBFDBFE), // blue-200
                              fontSize: 14, // text-sm
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Navigation Items
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _navItems.length,
                    separatorBuilder: (ctx, idx) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final isSelected = _selectedIndex == index;
                      final item = _navItems[index];

                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedIndex = index;
                            });
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF1D4ED8) : Colors.transparent, // blue-700 vs transparent
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ) 
                                    ]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  item.icon,
                                  size: 20,
                                  color: isSelected ? Colors.white : const Color(0xFFDBEAFE), // white vs blue-100
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  item.label,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : const Color(0xFFDBEAFE),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Footer (User Info)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFF1D4ED8)), // blue-700
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1D4ED8), // blue-700
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'AD',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             Text(
                              'Administrateur',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                             Text(
                              'admin@chu-sante.fr',
                              style: TextStyle(
                                color: Color(0xFFBFDBFE), // blue-200
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top Header (Sticky-like)
                Container(
                  height: 64, // h-16
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey[200]!),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Search Bar (Left)
                      Container(
                        width: 320, // w-80
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6), // gray-100
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Colors.grey[400], size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Rechercher...',
                                  border: InputBorder.none,
                                  isDense: true,
                                  hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Right Actions
                      Row(
                        children: [
                          // Notifications
                          Stack(
                            children: [
                              IconButton(
                                icon: Icon(Icons.notifications_outlined, color: Colors.grey[600]),
                                onPressed: () {},
                                tooltip: 'Notifications',
                              ),
                              Positioned(
                                right: 8,
                                top: 8,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          
                          // Logout
                          TextButton.icon(
                            onPressed: () {
                              context.read<AuthProvider>().logout();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.grey[700],
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            icon: const Icon(Icons.logout, size: 20),
                            label: const Text('Déconnexion'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Screen Content
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(24), // p-6
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1280), // max-w-7xl
                      child: _selectedIndex < _screens.length
                          ? _screens[_selectedIndex]
                          : _screens[0],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NavigationItem {
  final String id;
  final IconData icon;
  final String label;

  const NavigationItem({required this.id, required this.icon, required this.label});
}
