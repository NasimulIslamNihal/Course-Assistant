import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- THIS WAS MISSING! Fixes the crash!
import 'package:http/http.dart' as http;
import 'dart:convert';

// --- SECURE API CALL FROM FLUTTER ---
Future<void> fetchSecureProfileData() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("User is not logged in!");
      return;
    }
    final idToken = await user.getIdToken(false);
    final url =
        Uri.parse('https://chafe-alphabet-perfected.ngrok-free.dev/api/papers');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print("Secure Data Received: ${data['message']}");
      print("User Email from Node.js: ${data['email']}");
    } else {
      print("Security Check Failed: ${response.statusCode} - ${response.body}");
    }
  } catch (e) {
    print("Error making secure request: $e");
  }
}

// 1. MAIN FUNCTION
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyCHHU1jLffeA60kxlxaLa9aWOczZlAPyL0",
      appId: "1:444416261664:web:dd88246ebd4477bb4c0645",
      messagingSenderId: "444416261664",
      projectId: "course-assistant-6af50",
      authDomain: "course-assistant-6af50.firebaseapp.com",
    ),
  );

  runApp(const StudyHubApp());
}

class StudyHubApp extends StatelessWidget {
  const StudyHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudyHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B4EE6),
          surface: const Color(0xFFFAFAFA),
        ),
        useMaterial3: true,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      ),
      home: const LoginScreen(),
    );
  }
}

// MARK: - 1. Login Screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainDashboardLayout()),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message ?? 'Login failed'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                      color: Color(0xFF333366), shape: BoxShape.circle),
                  child: const Icon(Icons.menu_book,
                      color: Colors.white, size: 40),
                ),
                const SizedBox(height: 24),
                const Text('Welcome to Course Assistant',
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A)),
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('Sign in to continue',
                    style:
                        TextStyle(fontSize: 15, color: Colors.grey.shade600)),
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.g_mobiledata,
                      size: 32, color: Colors.black87),
                  label: const Text('Continue with Google',
                      style: TextStyle(color: Colors.black87, fontSize: 16)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('OR',
                            style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 12,
                                fontWeight: FontWeight.bold))),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),
                const SizedBox(height: 24),
                const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Email',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A)))),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      hintText: 'you@example.com',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: const Icon(Icons.email_outlined, size: 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16)),
                ),
                const SizedBox(height: 20),
                const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Password',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F172A)))),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                      hintText: '••••••••',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade200)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16)),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Sign in',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    TextButton(
                        onPressed: () {},
                        child: Text('Forgot password?',
                            style: TextStyle(color: Color(0xff0e0505)))),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Create an Account',
                            style: TextStyle(color: Color(0xff1a1515))),
                        TextButton(
                            onPressed: () {},
                            child: const Text('Sign up',
                                style: TextStyle(
                                    color: Color(0xfffd780c),
                                    fontWeight: FontWeight.bold))),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// MARK: - 2. Master Dashboard Layout
class MainDashboardLayout extends StatefulWidget {
  const MainDashboardLayout({super.key});

  @override
  State<MainDashboardLayout> createState() => _MainDashboardLayoutState();
}

class _MainDashboardLayoutState extends State<MainDashboardLayout> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardView(),
    const PastPapersView(),
    const FindTutorsView(),
    const MySessionsView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 850;

    return Scaffold(
      appBar: isMobile
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: const Row(
                children: [
                  Icon(Icons.school, color: Color(0xFF6B4EE6), size: 28),
                  SizedBox(width: 8),
                  Text('StudyHub',
                      style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: CircleAvatar(
                      backgroundColor: Colors.grey.shade200,
                      radius: 16,
                      child: const Icon(Icons.person_outline,
                          color: Colors.black87, size: 18)),
                )
              ],
            )
          : null,
      bottomNavigationBar: isMobile
          ? NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) =>
                  setState(() => _selectedIndex = index),
              backgroundColor: Colors.white,
              indicatorColor: const Color(0xFF6B4EE6).withValues(alpha: 0.15),
              destinations: const [
                NavigationDestination(
                    icon: Icon(Icons.dashboard_outlined),
                    selectedIcon:
                        Icon(Icons.dashboard, color: Color(0xFF6B4EE6)),
                    label: 'Home'),
                NavigationDestination(
                    icon: Icon(Icons.description_outlined),
                    selectedIcon:
                        Icon(Icons.description, color: Color(0xFF6B4EE6)),
                    label: 'Papers'),
                NavigationDestination(
                    icon: Icon(Icons.school_outlined),
                    selectedIcon: Icon(Icons.school, color: Color(0xFF6B4EE6)),
                    label: 'Tutors'),
                NavigationDestination(
                    icon: Icon(Icons.menu_book_outlined),
                    selectedIcon:
                        Icon(Icons.menu_book, color: Color(0xFF6B4EE6)),
                    label: 'Sessions'),
                NavigationDestination(
                    icon: Icon(Icons.person_outline),
                    selectedIcon: Icon(Icons.person, color: Color(0xFF6B4EE6)),
                    label: 'Profile'),
              ],
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            Container(
              width: 260,
              color: const Color(0xFF1E1B2E),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      children: [
                        Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                                color: Color(0xFF6B4EE6),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            child: const Icon(Icons.school,
                                color: Colors.white, size: 24)),
                        const SizedBox(width: 12),
                        const Text('StudyHub',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSidebarItem(Icons.dashboard_outlined, 'Dashboard', 0),
                  _buildSidebarItem(
                      Icons.description_outlined, 'Past Papers', 1),
                  _buildSidebarItem(Icons.school_outlined, 'Find Tutors', 2),
                  _buildSidebarItem(Icons.menu_book_outlined, 'My Sessions', 3),
                  _buildSidebarItem(Icons.person_outline, 'Profile', 4),
                  const Spacer(),
                  ListTile(
                      leading: const Icon(Icons.logout, color: Colors.grey),
                      title: const Text('Log out',
                          style: TextStyle(color: Colors.grey)),
                      onTap: () async {
                        await FirebaseAuth.instance.signOut();
                        if (mounted) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginScreen()));
                        }
                      }),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          Expanded(
            child: Column(
              children: [
                if (!isMobile)
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CircleAvatar(
                            backgroundColor: Colors.grey.shade200,
                            radius: 18,
                            child: const Icon(Icons.person_outline,
                                color: Colors.black87, size: 20))
                      ],
                    ),
                  ),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: _pages,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6B4EE6) : Colors.transparent,
            borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? Colors.white : Colors.grey.shade400,
                size: 20),
            const SizedBox(width: 12),
            Text(title,
                style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade400,
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}

// MARK: - Responsive Grid Helper
Widget _buildResponsiveGrid(BuildContext context, List<Widget> children) {
  double width = MediaQuery.of(context).size.width;
  if (width < 650) {
    return Column(
        children: children
            .map((c) =>
                Padding(padding: const EdgeInsets.only(bottom: 16), child: c))
            .toList());
  } else if (width < 1100) {
    return Column(
      children: [
        Row(children: [
          Expanded(child: children[0]),
          const SizedBox(width: 16),
          Expanded(child: children[1])
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: children[2]),
          const SizedBox(width: 16),
          Expanded(child: children[3])
        ]),
      ],
    );
  } else {
    return Row(
        children: children
            .map((c) => Expanded(
                child: Padding(
                    padding:
                        EdgeInsets.only(right: c == children.last ? 0 : 16),
                    child: c)))
            .toList());
  }
}

// MARK: - 3. Dashboard View
class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 650;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 20.0 : 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isMobile) ...[
            const Text('Good morning, Md. Nihal 👋',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87)),
            const SizedBox(height: 4),
            Text('Thursday, April 16, 2026',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                  color: const Color(0xFFF3F0FF),
                  borderRadius: BorderRadius.circular(20)),
              child: const Text('Uttara University • CS • Batch 2025',
                  style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF4A3B8C),
                      fontWeight: FontWeight.w600)),
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Good morning, Md. Nihal 👋',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87)),
                    const SizedBox(height: 6),
                    Text('Thursday, April 16, 2026',
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade600)),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF3F0FF),
                      borderRadius: BorderRadius.circular(20)),
                  child: const Row(
                    children: [
                      Icon(Icons.auto_awesome,
                          size: 16, color: Color(0xFF6B4EE6)),
                      SizedBox(width: 8),
                      Text('Uttara University • Computer Science • Batch 2025',
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4A3B8C),
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 32),
          _buildResponsiveGrid(context, [
            const SummaryCard(
                iconColor: Color(0xFF6B4EE6),
                iconBgColor: Color(0xFFF3F0FF),
                icon: Icons.description_outlined,
                count: '2',
                label: 'Past Papers'),
            SummaryCard(
                iconColor: Colors.orange.shade700,
                iconBgColor: Colors.orange.shade50,
                icon: Icons.school_outlined,
                count: '0',
                label: 'Available Tutors'),
            SummaryCard(
                iconColor: Colors.blue.shade700,
                iconBgColor: Colors.blue.shade50,
                icon: Icons.menu_book_outlined,
                count: '0',
                label: 'My Sessions'),
            SummaryCard(
                iconColor: Colors.green.shade700,
                iconBgColor: Colors.green.shade50,
                icon: Icons.trending_up,
                count: '0h',
                label: 'This Month'),
          ]),
          const SizedBox(height: 40),
          const Text('→ Quick Actions',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 16),
          _buildResponsiveGrid(context, [
            const QuickActionCard(
                title: 'Browse Past Papers',
                subtitle: 'Access exam questions & answers',
                icon: Icons.description_outlined,
                color: Color(0xFFF3F0FF),
                iconColor: Color(0xFF6B4EE6)),
            QuickActionCard(
                title: 'Find a Tutor',
                subtitle: 'Get 1-on-1 tutoring from seniors',
                icon: Icons.school_outlined,
                color: Colors.orange.shade50,
                iconColor: Colors.orange.shade700),
            QuickActionCard(
                title: 'My Sessions',
                subtitle: 'View your upcoming tutoring sessions',
                icon: Icons.menu_book_outlined,
                color: Colors.blue.shade50,
                iconColor: Colors.blue.shade700),
            QuickActionCard(
                title: 'Become a Tutor',
                subtitle: 'Share your knowledge and earn money',
                icon: Icons.access_time_outlined,
                color: Colors.green.shade50,
                iconColor: Colors.green.shade700),
          ]),
          const SizedBox(height: 40),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  const Color(0xFFF3F0FF),
                  const Color(0xFFF8EFFF).withValues(alpha: 0.5)
                ], begin: Alignment.topLeft, end: Alignment.bottomRight),
                borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: [
                Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: const Color(0xFFE5DFFF),
                        borderRadius: BorderRadius.circular(16)),
                    child: const Icon(Icons.school,
                        size: 32, color: Color(0xFF6B4EE6))),
                const SizedBox(height: 20),
                const Text('Organize Your Academic Life',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87),
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text(
                    'Access past papers, connect with senior tutors, and ace your exams.',
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey.shade700, height: 1.5),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// MARK: - 4. Past Papers View (Direct Firebase Connection)
class PastPapersView extends StatelessWidget {
  const PastPapersView({super.key});

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 650;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 20.0 : 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F0FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.description_outlined,
                              color: Color(0xFF6B4EE6), size: 24),
                        ),
                        const SizedBox(width: 12),
                        Text('Past Papers',
                            style: TextStyle(
                                fontSize: isMobile ? 24 : 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Browse exam questions & answers from your department',
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              if (!isMobile)
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 18, color: Colors.white),
                  label: const Text('Upload Paper',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B4EE6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                ),
            ],
          ),

          if (isMobile) ...[
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 18, color: Colors.white),
                label: const Text('Upload Paper',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B4EE6),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
              ),
            ),
          ],

          const SizedBox(height: 32),

          if (isMobile) ...[
            _buildSearchBar(),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _buildFilterDropdown(
                        'Types', Icons.filter_alt_outlined)),
                const SizedBox(width: 12),
                Expanded(child: _buildFilterDropdown('Years', null)),
              ],
            )
          ] else ...[
            Row(
              children: [
                Expanded(flex: 3, child: _buildSearchBar()),
                const SizedBox(width: 16),
                Expanded(
                    flex: 1,
                    child: _buildFilterDropdown(
                        'All Types', Icons.filter_alt_outlined)),
                const SizedBox(width: 16),
                Expanded(
                    flex: 1, child: _buildFilterDropdown('All Years', null)),
              ],
            ),
          ],

          const SizedBox(height: 32),

          // --- DIRECT FIREBASE CONNECTION HERE ---
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('past_papers')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(
                            color: Color(0xFF6B4EE6))));
              }

              if (snapshot.hasError) {
                return Center(
                    child: Text('Database Error: \n${snapshot.error}',
                        style: const TextStyle(color: Colors.red)));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                    child: Text('No past papers found in database.'));
              }

              final papers = snapshot.data!.docs;

              return Wrap(
                spacing: 24,
                runSpacing: 24,
                children: papers.map((doc) {
                  final paper = doc.data() as Map<String, dynamic>;

                  return Container(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: PaperCard(
                      title: paper['Title']?.toString() ?? 'Unknown Title',
                      subtitle:
                          paper['Subject']?.toString() ?? 'Unknown Subject',
                      dateText: '20${paper['Year']}   Sem ${paper['Semester']}',
                      hasAnswers: paper['hasanswer'] ?? false,
                      type: paper['Type']?.toString() ??
                          paper['type']?.toString() ??
                          'Midterm',
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
        decoration: InputDecoration(
      hintText: 'Search papers...',
      prefixIcon: const Icon(Icons.search, color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200)),
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
    ));
  }

  Widget _buildFilterDropdown(String hint, IconData? icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
              child: Row(children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: Colors.black87),
              const SizedBox(width: 8)
            ],
            Flexible(
                child: Text(hint,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis))
          ])),
          const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey),
        ],
      ),
    );
  }
}

// MARK: - UPGRADED PAPER CARD (With Colored Badges & Responsiveness)
class PaperCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String dateText;
  final bool hasAnswers;
  final String type;

  const PaperCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.dateText,
    required this.hasAnswers,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 650;
    bool isFinal = type.toLowerCase().contains('final');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: const Color(0xFFF3F0FF),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.description_outlined,
                      color: Color(0xFF6B4EE6), size: 28)),

              // BEAUTIFUL COLORED BADGES
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                      color: isFinal
                          ? const Color(0xFFF3E8FF)
                          : const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(type,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isFinal
                              ? const Color(0xFF9333EA)
                              : const Color(0xFF1D4ED8)))),
            ],
          ),
          const SizedBox(height: 20),
          Text(title,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 6),
          Text(subtitle,
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600)),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 18, color: Colors.grey.shade500),
              const SizedBox(width: 8),
              Text(dateText,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 28),
          if (isMobile) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.remove_red_eye_outlined,
                    size: 20, color: Colors.black87),
                label: const Text('Questions',
                    style: TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
              ),
            ),
            if (hasAnswers) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.download_outlined,
                      size: 20, color: Colors.white),
                  label: const Text('Answers',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF6B4EE6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0),
                ),
              ),
            ]
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.remove_red_eye_outlined,
                        size: 20, color: Colors.black87),
                    label: const Text('Questions',
                        style: TextStyle(
                            color: Colors.black87,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                  ),
                ),
                if (hasAnswers) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download_outlined,
                          size: 20, color: Colors.white),
                      label: const Text('Answers',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF6B4EE6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0),
                    ),
                  ),
                ],
              ],
            )
          ]
        ],
      ),
    );
  }
}

// MARK: - 5. Find Tutors View
class FindTutorsView extends StatelessWidget {
  const FindTutorsView({super.key});

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 650;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 20.0 : 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.school_outlined,
                  color: Color(0xFF6B4EE6), size: 28),
              const SizedBox(width: 12),
              Text('Find a Tutor',
                  style: TextStyle(
                      fontSize: isMobile ? 24 : 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Get 1-on-1 tutoring from talented seniors',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          const SizedBox(height: 32),
          if (isMobile) ...[
            TextField(
                decoration: InputDecoration(
                    hintText: 'Search...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200)))),
            const SizedBox(height: 12),
            Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(12)),
                child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.filter_alt_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Top Rated',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      SizedBox(width: 8),
                      Icon(Icons.keyboard_arrow_down,
                          size: 18, color: Colors.grey)
                    ])),
          ] else ...[
            Row(
              children: [
                Expanded(
                    child: TextField(
                        decoration: InputDecoration(
                            hintText: 'Search by name, subject...',
                            prefixIcon:
                                const Icon(Icons.search, color: Colors.grey),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade200)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade200))))),
                const SizedBox(width: 16),
                Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Row(children: [
                      Icon(Icons.filter_alt_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Top Rated',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      SizedBox(width: 8),
                      Icon(Icons.keyboard_arrow_down,
                          size: 18, color: Colors.grey)
                    ])),
              ],
            ),
          ],
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.school, size: 70, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('No tutors found',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  const SizedBox(height: 8),
                  Text('Check back later!',
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

// MARK: - 6. My Sessions View
class MySessionsView extends StatelessWidget {
  const MySessionsView({super.key});

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 650;

    return Padding(
      padding: EdgeInsets.all(isMobile ? 20.0 : 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book_outlined,
                  color: Color(0xFF6B4EE6), size: 28),
              const SizedBox(width: 12),
              Text('My Sessions',
                  style: TextStyle(
                      fontSize: isMobile ? 24 : 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 8),
          Text('Track your tutoring requests and sessions',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.menu_book, size: 70, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('No sessions yet',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  const SizedBox(height: 8),
                  Text('Book your first tutoring session!',
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

// MARK: - 7. Profile View
class ProfileView extends StatefulWidget {
  const ProfileView({super.key});
  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool isTutor = true;
  bool isAvailable = true;

  String secureMessage = "Loading...";
  String fetchedEmail = "Loading...";
  String tutorStatus = "Loading...";
  bool isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _fetchSecureProfileData();
  }

  Future<void> _fetchSecureProfileData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final idToken = await user.getIdToken(false);
      final url = Uri.parse(
          'https://chafe-alphabet-perfected.ngrok-free.dev/api/my-profile');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            secureMessage = data['message'] ?? '';
            fetchedEmail = data['email'] ?? '';
            tutorStatus = data['status'] ?? '';
            isLoadingProfile = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            secureMessage = "Error: Unauthorized";
            isLoadingProfile = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          secureMessage = "Server connection failed";
          isLoadingProfile = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 650;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 20.0 : 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline,
                  color: Color(0xFF6B4EE6), size: 28),
              const SizedBox(width: 12),
              Text('My Profile',
                  style: TextStyle(
                      fontSize: isMobile ? 24 : 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: EdgeInsets.all(isMobile ? 20 : 24),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.lock_outline, size: 20, color: Colors.green),
                  SizedBox(width: 12),
                  Text('Secure Node.js Data',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87))
                ]),
                const SizedBox(height: 24),
                if (isLoadingProfile)
                  const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF6B4EE6)))
                else if (isMobile) ...[
                  _infoBox('SERVER MESSAGE', secureMessage, fullWidth: true),
                  const SizedBox(height: 12),
                  _infoBox('VERIFIED EMAIL', fetchedEmail, fullWidth: true),
                  const SizedBox(height: 12),
                  _infoBox('STATUS', tutorStatus, fullWidth: true),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                          child: _infoBox('SERVER MESSAGE', secureMessage)),
                      const SizedBox(width: 16),
                      Expanded(child: _infoBox('VERIFIED EMAIL', fetchedEmail)),
                      const SizedBox(width: 16),
                      Expanded(child: _infoBox('STATUS', tutorStatus)),
                    ],
                  )
                ]
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: EdgeInsets.all(isMobile ? 20 : 24),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(children: [
                      Icon(Icons.school_outlined,
                          size: 20, color: Color(0xFF6B4EE6)),
                      SizedBox(width: 12),
                      Text('Become a Tutor',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87))
                    ]),
                    Switch(
                        value: isTutor,
                        activeColor: const Color(0xFF6B4EE6),
                        onChanged: (val) => setState(() => isTutor = val)),
                  ],
                ),
                const Divider(height: 40),
                const Text('Subjects you can teach',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                        child: TextField(
                            decoration: InputDecoration(
                                hintText: 'Add a subject...',
                                hintStyle: TextStyle(color: Color(0xff3f3c3c)),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        BorderSide(color: Color(0xff574242))),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide:
                                        BorderSide(color: Color(0xff5e4444))),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 16)))),
                    const SizedBox(width: 12),
                    Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.add, color: Colors.black87)),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Hourly Rate (BDT)',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Color(0xff06080c))),
                const SizedBox(height: 8),
                TextField(
                    decoration: InputDecoration(
                        hintText: '500',
                        hintStyle: TextStyle(color: Color(0xff555151)),
                        suffixIcon: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_drop_up, size: 30),
                              Icon(Icons.arrow_drop_down, size: 30)
                            ]),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color(0xff4b4040))),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Colors.grey.shade200)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16))),
                const SizedBox(height: 24),
                const Text('Bio',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                const SizedBox(height: 8),
                TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                        hintText:
                            'Tell students about your teaching experience...',
                        hintStyle: TextStyle(color: Color(0xff2b2424)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color(0xff494242))),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: Colors.grey.shade200)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16))),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Flexible(
                        child: Text('Available for new students',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF0F172A)))),
                    Switch(
                        value: isAvailable,
                        activeColor: const Color(0xFF6B4EE6),
                        onChanged: (val) => setState(() => isAvailable = val)),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.save_outlined,
                      size: 20, color: Colors.white),
                  label: const Text('Save Profile',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 54),
                      backgroundColor: const Color(0xFF6B4EE6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _infoBox(String label, String value, {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: const Color(0xFFF4F6F8),
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                  letterSpacing: 1.2)),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A))),
        ],
      ),
    );
  }
}

// MARK: - Reusable UI Components
class SummaryCard extends StatelessWidget {
  final IconData icon;
  final String count;
  final String label;
  final Color iconColor;
  final Color iconBgColor;

  const SummaryCard(
      {super.key,
      required this.icon,
      required this.count,
      required this.label,
      required this.iconColor,
      required this.iconBgColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: iconColor, size: 28)),
              const SizedBox(width: 16),
              Text(count,
                  style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 16),
          Text(label,
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color iconColor;

  const QuickActionCard(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.icon,
      required this.color,
      required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.5))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor, size: 28)),
          const SizedBox(height: 20),
          Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 8),
          Text(subtitle,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87.withValues(alpha: 0.6),
                  height: 1.5)),
        ],
      ),
    );
  }
}
