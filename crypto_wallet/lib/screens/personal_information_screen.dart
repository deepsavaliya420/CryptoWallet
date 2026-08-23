import 'package:flutter/material.dart';

import '../services/user_service.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState
    extends State<PersonalInformationScreen> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController locationController;
  late final TextEditingController phoneController;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    final user = UserService.currentUser;

    nameController = TextEditingController(
      text: user?.fullName ?? '',
    );

    emailController = TextEditingController(
      text: user?.email ?? '',
    );

    locationController = TextEditingController(
      text: user?.location ?? '',
    );

    phoneController = TextEditingController(
      text: user?.phone ?? '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    locationController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> saveChanges() async {
    if (nameController.text.trim().isEmpty) {
      showMessage('Please enter your name.');
      return;
    }

    if (emailController.text.trim().isEmpty) {
      showMessage('Please enter your email.');
      return;
    }

    setState(() {
      isSaving = true;
    });

    await UserService.updateProfile(
      fullName: nameController.text.trim(),
      email: emailController.text.trim(),
      location: locationController.text.trim(),
      phone: phoneController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Profile updated successfully.',
        ),
      ),
    );

    Navigator.pop(context, true);
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = UserService.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'No user is currently logged in.',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Personal Information',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Profile Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Update your personal information below.',
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 24),

            TextField(
              controller: nameController,
              textCapitalization:
              TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(
                  Icons.person_outline,
                ),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: emailController,
              keyboardType:
              TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(
                  Icons.email_outlined,
                ),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: locationController,
              decoration: const InputDecoration(
                labelText: 'Location',
                prefixIcon: Icon(
                  Icons.location_on_outlined,
                ),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone',
                prefixIcon: Icon(
                  Icons.phone_outlined,
                ),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Account Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.badge_outlined,
                    ),
                    title: const Text('User ID'),
                    subtitle: Text(user.userId),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.account_balance_wallet_outlined,
                    ),
                    title: const Text('Wallet Address'),
                    subtitle: Text(
                      user.walletAddress,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed:
                isSaving ? null : saveChanges,
                icon: isSaving
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(
                  Icons.save_outlined,
                ),
                label: Text(
                  isSaving
                      ? 'Saving...'
                      : 'Save Changes',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}