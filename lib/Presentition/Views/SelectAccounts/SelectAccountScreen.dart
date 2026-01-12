import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:netflix_clone/Presentition/Widgets/BuildSmoothNavigates.dart';
import 'package:netflix_clone/Presentition/Widgets/BuildTexts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../Widgets/BuildSelectedAccount.dart';
import '../Home/HomeView.dart';

class ProfileSelectionScreen extends StatefulWidget {
  const ProfileSelectionScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}


class _ProfileSelectionScreenState extends State<ProfileSelectionScreen> {
  String? selectedProfile;
  bool isAnimating = false;
  bool isFirstTime = true;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // SharedPreferences keys
  static const String _hasSelectedProfileKey = 'hasSelectedProfile';

  @override
  void initState() {
    super.initState();
    _checkIfFirstTime();
  }

  // Check if this is user's first time selecting a profile
  Future<void> _checkIfFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSelectedProfile = prefs.getBool(_hasSelectedProfileKey) ?? false;

    setState(() {
      isFirstTime = !hasSelectedProfile;
    });
  }

  // Save profile to Firebase
  Future<bool> _saveProfileToFirebase(String name, String imagePath) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Save to Firestore
        await _firestore.collection('user').doc(FirebaseAuth.instance.currentUser!.uid).set({
          'profileName': name,
          'profileImage': imagePath,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)); // Use merge to update existing document

        return true; // Success
      }
      return false; // No user
    } catch (e) {
      print('Error saving profile: $e');
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error saving profile. Please try again.',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false; // Failed
    }
  }

  void onProfileSelected(String name, String image) async {
    setState(() {
      selectedProfile = name;
      isAnimating = true;
    });

    // Save profile to Firebase and wait for success
    bool success = await _saveProfileToFirebase(name, image);

    if (success) {
      // If first time, mark it in SharedPreferences
      if (isFirstTime) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_hasSelectedProfileKey, true);
      }

      // Wait for animation to complete
      await Future.delayed(const Duration(seconds: 3));

      // Navigate to home screen only after successful upload
      if (mounted) {
        navigateWithTransitionPush(context, NetflixStyleHome());
      }
    } else {
      // If failed, stop animation and allow user to try again
      setState(() {
        isAnimating = false;
        selectedProfile = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff151515),
      body: Stack(
        children: [
          // Main content
          if (!isAnimating)
            Column(
              children: [
                const SizedBox(height: 60),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Who's watching?",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildProfileContainer("assets/images/Samir.png", "Samir"),
                    buildProfileContainer("assets/images/Hazem.png", "Hazem"),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildProfileContainer("assets/images/tedo.png", "Tedo"),
                    buildProfileContainer("assets/images/yasser.png", "Hamada"),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildProfileContainer("assets/images/hussain.png", "Hussain"),
                    buildProfileContainer("assets/images/Ghoost.png", "Ghoost"),
                  ],
                ),
              ],
            ),
          // Animated overlay
          if (isAnimating)
            AnimatedProfileOverlay(
              profileName: selectedProfile!,
              profileImage: _getImageForName(selectedProfile!),
            ),
        ],
      ),
    );
  }

  String _getImageForName(String name) {
    final Map<String, String> profiles = {
      'Samir': 'assets/images/Samir.png',
      'Hazem': 'assets/images/Hazem.png',
      'Tedo': 'assets/images/tedo.png',
      'Hamada': 'assets/images/yasser.png',
      'Hussain': 'assets/images/hussain.png',
      'Ghoost': 'assets/images/Ghoost.png',
    };
    return profiles[name] ?? '';
  }

  Widget buildProfileContainer(String image, String name) {
    return GestureDetector(
      onTap: () => onProfileSelected(name, image),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(width: 2, color: const Color(0xff1f1f1f)),
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedProfileOverlay extends StatefulWidget {
  final String profileName;
  final String profileImage;

  const AnimatedProfileOverlay({
    Key? key,
    required this.profileName,
    required this.profileImage,
  }) : super(key: key);

  @override
  State<AnimatedProfileOverlay> createState() => _AnimatedProfileOverlayState();
}

class _AnimatedProfileOverlayState extends State<AnimatedProfileOverlay>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _indicatorController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _indicatorAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _indicatorController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _indicatorAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _indicatorController, curve: Curves.easeOut),
    );

    _controller.forward();
    Future.delayed(const Duration(milliseconds: 10), () {
      if (mounted) _indicatorController.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _indicatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          color: const Color(0xff151515),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 3,
                        color: Colors.red,
                      ),
                      image: DecorationImage(
                        image: AssetImage(widget.profileImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.profileName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedBuilder(
                  animation: _indicatorAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _indicatorAnimation.value,
                      child: const SpinKitCircle(
                        color: Colors.red,
                        size: 50.0,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}