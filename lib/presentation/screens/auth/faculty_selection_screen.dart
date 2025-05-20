import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/themed_button.dart';
import 'package:final_project/core/constants/faculty_constants.dart'; // Import AppFaculties

class FacultySelectionScreen extends ConsumerStatefulWidget {
  const FacultySelectionScreen({super.key});

  @override
  ConsumerState<FacultySelectionScreen> createState() =>
      _FacultySelectionScreenState();
}

class _FacultySelectionScreenState
    extends ConsumerState<FacultySelectionScreen> {
  String? _selectedFacultyId;
  final List<MapEntry<String, String>> _facultyList = AppFaculties.facultyList;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkRedirect();
    });
  }

  void _checkRedirect() {
    final authState = ref.read(authProvider);
    final authNotifier = ref.read(authProvider.notifier);

    if (authState.user == null || !authNotifier.requiresFacultySelection()) {
      print(
          'FacultySelectionScreen: Redirecting. User null: ${authState.user == null}, Needs selection: ${authNotifier.requiresFacultySelection()}');
      GoRouter.of(context).go(AppConstants.homeRoute);
    } else {
      print('FacultySelectionScreen: User needs faculty selection.');
    }
  }

  void _selectFaculty() async {
    if (_selectedFacultyId == null || _selectedFacultyId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your faculty')),
      );
      return;
    }

    final authNotifier = ref.read(authProvider.notifier);
    final currentUser = ref.read(authProvider).user;

    if (currentUser == null || !authNotifier.requiresFacultySelection()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Error: User session invalid or faculty already set.')),
      );
      GoRouter.of(context).go(AppConstants.loginRoute);
      return;
    }

    final success = await authNotifier.updateUserFaculty(
      userId: currentUser.id,
      facultyId: _selectedFacultyId!,
    );

    if (success) {
      print('Faculty updated successfully!');
      GoRouter.of(context).go(AppConstants.homeRoute);
    } else {
      final errorMessage = ref.read(authProvider).errorMessage;
      print('Faculty update failed: $errorMessage');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage ?? 'Failed to update faculty')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;
    final requiresFacultySelection =
        ref.watch(requiresFacultySelectionProvider);

    if (authState.user == null || !requiresFacultySelection) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Select Your Faculty')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Welcome! Please select your faculty to continue.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge, // Use theme style for better scaling
                ),
                const SizedBox(height: 24),
                DropdownButtonFormField<String>(
                  decoration:
                      const InputDecoration(labelText: 'Select Faculty'),
                  value: _selectedFacultyId,
                  items: _facultyList.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedFacultyId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select your faculty';
                    }
                    return null;
                  },
                  hint: const Text('Choose a Faculty'),
                ),
                const SizedBox(height: 24),
                ThemedButton(
                  text: 'Confirm Faculty',
                  onPressed: isLoading ? null : _selectFaculty,
                  isLoading: isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
