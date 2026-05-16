import 'package:flutter/material.dart';
import 'package:mente_cart/core/errors/exceptions.dart';

import '../../data/models/auth_me_model.dart';
import '../../data/repositories/auth_repository.dart';

class ProfilePage extends StatefulWidget {
  final AuthRepository authRepository;

  const ProfilePage({super.key, required this.authRepository});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<AuthMeModel> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<AuthMeModel> _loadProfile() async {
    final response = await widget.authRepository.me();
    return AuthMeModel.fromJson(response);
  }

  Future<void> _refresh() async {
    setState(() {
      _profileFuture = _loadProfile();
    });
    await _profileFuture;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<AuthMeModel>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final error = snapshot.error;
            final message = error is AppException ? error.message : 'Failed to load profile';
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 100),
                Icon(Icons.person_outline, size: 56, color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  'Profile unavailable',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                ),
              ],
            );
          }

          final profile = snapshot.data;
          if (profile == null) {
            return const Center(child: Text('No profile data found'));
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 12),
              CircleAvatar(
                radius: 44,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  profile.firstName.isNotEmpty ? profile.firstName[0].toUpperCase() : 'U',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                profile.fullName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                profile.message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              _InfoCard(label: 'First Name', value: profile.firstName),
              _InfoCard(label: 'Last Name', value: profile.lastName),
              _InfoCard(label: 'Email', value: profile.email),
              _InfoCard(label: 'Role', value: profile.role),
            ],
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;

  const _InfoCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              value.isEmpty ? '-' : value,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}
