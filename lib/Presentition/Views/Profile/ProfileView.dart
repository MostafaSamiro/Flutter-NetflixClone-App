import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../Provider/LocaliztionProvider.dart';
import '../../../Provider/ThemeProvider.dart';
import '../AuthScreens/LoginScreen.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('theme') ?? 'dark';
    final language = prefs.getString('language') ?? 'english';

    if (mounted) {
      if (theme == 'dark') {
        context.read<ThemeProvider>().setDarkTheme();
      } else {
        context.read<ThemeProvider>().setLightTheme();
      }

      if (language == 'arabic') {
        context.read<LocalizationProvider>().setArabic();
      } else {
        context.read<LocalizationProvider>().setEnglish();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final isArabic = context.watch<LocalizationProvider>().isArabic;

    if (user == null) {
      return Scaffold(
        backgroundColor: NetflixColors.getBackground(context, isDark),
        body: Center(
          child: Text(
            'please_log_in'.tr(context),
            style: TextStyle(
              color: NetflixColors.getTextPrimary(context, isDark),
              fontSize: 18,
            ),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: NetflixColors.getBackground(context, isDark),
        body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('user')
              .doc(user.uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: NetflixColors.netflixRed,
                ),
              );
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return Center(
                child: Text(
                  'no_profile_data'.tr(context),
                  style: TextStyle(
                    color: NetflixColors.getTextPrimary(context, isDark),
                  ),
                ),
              );
            }

            final userData = userSnapshot.data!.data() as Map<String, dynamic>;
            final profileName = userData['profileName'] ?? 'User';
            final profileImage = userData['profileImage'] ?? '';

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('user')
                  .doc(user.uid)
                  .collection('My List')
                  .snapshots(),
              builder: (context, listSnapshot) {
                final listCount =
                listSnapshot.hasData ? listSnapshot.data!.docs.length : 0;

                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: CustomScrollView(
                    slivers: [
                      // Custom App Bar with gradient
                      SliverAppBar(
                        expandedHeight: 200,
                        floating: false,
                        pinned: true,
                        backgroundColor: Colors.transparent,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  NetflixColors.netflixRed.withOpacity(0.8),
                                  NetflixColors.getBackground(context, isDark),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Profile Content
                      SliverToBoxAdapter(
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            children: [
                              const SizedBox(height: 20),

                              // Profile Image with Animation
                              ScaleTransition(
                                scale: _scaleAnimation,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        NetflixColors.netflixRed,
                                        NetflixColors.netflixRed.withOpacity(0.7),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: NetflixColors.netflixRed
                                            .withOpacity(0.5),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: NetflixColors.getBackground(
                                          context, isDark),
                                    ),
                                    child: CircleAvatar(
                                      radius: 70,
                                      backgroundColor: isDark
                                          ? Colors.grey[800]
                                          : Colors.grey[300],
                                      backgroundImage: profileImage.isNotEmpty
                                          ? AssetImage(profileImage)
                                          : null,
                                      child: profileImage.isEmpty
                                          ? Icon(
                                        Icons.person,
                                        size: 70,
                                        color: NetflixColors
                                            .getTextSecondary(
                                            context, isDark),
                                      )
                                          : null,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Profile Name
                              Text(
                                profileName,
                                style: TextStyle(
                                  color: NetflixColors.getTextPrimary(
                                      context, isDark),
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 5),

                              // Email
                              Text(
                                user.email ?? '',
                                style: TextStyle(
                                  color: NetflixColors.getTextSecondary(
                                      context, isDark),
                                  fontSize: 14,
                                ),
                              ),

                              const SizedBox(height: 30),

                              // Stats Cards
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatCard(
                                        icon: Icons.movie,
                                        title: 'my_list'.tr(context),
                                        value: listCount.toString(),
                                        color: NetflixColors.netflixRed,
                                        isDark: isDark,
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Expanded(
                                      child: _buildStatCard(
                                        icon: Icons.play_circle_filled,
                                        title: 'watched'.tr(context),
                                        value: '0',
                                        color: Colors.blue,
                                        isDark: isDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 30),
                              const SizedBox(height: 15),

                              _buildActionButton(
                                icon: Icons.settings,
                                text: 'settings'.tr(context),
                                isDark: isDark,
                                onTap: () {
                                  _showSettingsDialog(context);
                                },
                              ),

                              const SizedBox(height: 15),

                              _buildActionButton(
                                icon: Icons.help_outline,
                                text: 'help_support'.tr(context),
                                isDark: isDark,
                                onTap: () {},
                              ),

                              const SizedBox(height: 30),

                              // Logout Button
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      showDialog(
                                        context: context,
                                        builder: (context) =>
                                            _buildLogoutDialog(context, isDark),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: NetflixColors.netflixRed,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      'sign_out'.tr(context),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 50),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, animValue, child) {
        return Transform.scale(
          scale: animValue,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: NetflixColors.getCardBackground(context, isDark),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(isDark ? 0.2 : 0.1),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 40),
                const SizedBox(height: 10),
                Text(
                  value,
                  style: TextStyle(
                    color: NetflixColors.getTextPrimary(context, isDark),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  title,
                  style: TextStyle(
                    color: NetflixColors.getTextSecondary(context, isDark),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String text,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: NetflixColors.getCardBackground(context, isDark),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: NetflixColors.getBorder(context, isDark),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: NetflixColors.getTextPrimary(context, isDark),
                size: 24,
              ),
              const SizedBox(width: 15),
              Text(
                text,
                style: TextStyle(
                  color: NetflixColors.getTextPrimary(context, isDark),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                color: NetflixColors.getTextSecondary(context, isDark),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutDialog(BuildContext context, bool isDark) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          color: NetflixColors.getCardBackground(context, isDark),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: NetflixColors.netflixRed, width: 2),
          boxShadow: [
            BoxShadow(
              color: NetflixColors.netflixRed.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.logout,
              color: NetflixColors.netflixRed,
              size: 60,
            ),
            const SizedBox(height: 20),
            Text(
              'sign_out'.tr(context),
              style: TextStyle(
                color: NetflixColors.getTextPrimary(context, isDark),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'sign_out_confirm'.tr(context),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: NetflixColors.getTextSecondary(context, isDark),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                      NetflixColors.getTextPrimary(context, isDark),
                      side: BorderSide(
                        color: NetflixColors.getBorder(context, isDark),
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'cancel'.tr(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => Login()),
                            (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NetflixColors.netflixRed,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'sign_out'.tr(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = context.read<ThemeProvider>().isDarkMode;

    String currentTheme = prefs.getString('theme') ?? 'dark';
    String currentLanguage = prefs.getString('language') ?? 'english';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: NetflixColors.getCardBackground(context, isDark),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: NetflixColors.netflixRed, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: NetflixColors.netflixRed.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.settings,
                    color: NetflixColors.netflixRed,
                    size: 50,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'settings'.tr(context),
                    style: TextStyle(
                      color: NetflixColors.getTextPrimary(context, isDark),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Theme Section
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: NetflixColors.getBorder(context, isDark),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.palette,
                              color: NetflixColors.getTextSecondary(
                                  context, isDark),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'theme'.tr(context),
                              style: TextStyle(
                                color: NetflixColors.getTextPrimary(
                                    context, isDark),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildThemeOption(
                                context,
                                title: 'dark'.tr(context),
                                icon: Icons.dark_mode,
                                isSelected: currentTheme == 'dark',
                                isDark: isDark,
                                onTap: () async {
                                  setState(() => currentTheme = 'dark');
                                  await prefs.setString('theme', 'dark');
                                  this.context.read<ThemeProvider>().setDarkTheme();
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildThemeOption(
                                context,
                                title: 'light'.tr(context),
                                icon: Icons.light_mode,
                                isSelected: currentTheme == 'light',
                                isDark: isDark,
                                onTap: () async {
                                  setState(() => currentTheme = 'light');
                                  await prefs.setString('theme', 'light');
                                  this.context.read<ThemeProvider>().setLightTheme();
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Language Section
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: NetflixColors.getBorder(context, isDark),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.language,
                              color: NetflixColors.getTextSecondary(
                                  context, isDark),
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'language'.tr(context),
                              style: TextStyle(
                                color: NetflixColors.getTextPrimary(
                                    context, isDark),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildLanguageOption(
                                context,
                                title: 'english'.tr(context),
                                flag: '🇺🇸',
                                isSelected: currentLanguage == 'english',
                                isDark: isDark,
                                onTap: () async {
                                  setState(() => currentLanguage = 'english');
                                  await prefs.setString('language', 'english');
                                  this.context.read<LocalizationProvider>().setEnglish();
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildLanguageOption(
                                context,
                                title: 'arabic'.tr(context),
                                flag: '🇪🇬',
                                isSelected: currentLanguage == 'arabic',
                                isDark: isDark,
                                onTap: () async {
                                  setState(() => currentLanguage = 'arabic');
                                  await prefs.setString('language', 'arabic');
                                  this.context.read<LocalizationProvider>().setArabic();
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Done Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'settings_saved'.tr(context),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NetflixColors.netflixRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'done'.tr(context),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildThemeOption(
      BuildContext context, {
        required String title,
        required IconData icon,
        required bool isSelected,
        required bool isDark,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? NetflixColors.netflixRed.withOpacity(0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? NetflixColors.netflixRed
                : NetflixColors.getBorder(context, isDark),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? NetflixColors.netflixRed
                  : NetflixColors.getTextSecondary(context, isDark),
              size: 30,
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? NetflixColors.getTextPrimary(context, isDark)
                    : NetflixColors.getTextSecondary(context, isDark),
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
      BuildContext context, {
        required String title,
        required String flag,
        required bool isSelected,
        required bool isDark,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? NetflixColors.netflixRed.withOpacity(0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? NetflixColors.netflixRed
                : NetflixColors.getBorder(context, isDark),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              flag,
              style: const TextStyle(fontSize: 30),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                color: isSelected
                    ? NetflixColors.getTextPrimary(context, isDark)
                    : NetflixColors.getTextSecondary(context, isDark),
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

