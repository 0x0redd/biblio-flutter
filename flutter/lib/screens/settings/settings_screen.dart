import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _version = info.version);
  }

  Future<void> _editName() async {
    final auth = context.read<AuthProvider>();
    final controller = TextEditingController(text: auth.user?.name);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      final userService = UserService();
      final updated = await userService.updateProfile(name: name);
      auth.updateUser(updated);
    }
  }

  Future<void> _pickTheme() async {
    final settings = context.read<SettingsProvider>();
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(title: const Text('Light'), onTap: () => Navigator.pop(ctx, 'light')),
          ListTile(title: const Text('Dark'), onTap: () => Navigator.pop(ctx, 'dark')),
          ListTile(title: const Text('System'), onTap: () => Navigator.pop(ctx, 'system')),
        ],
      ),
    );
    if (choice != null) await settings.setTheme(choice);
  }

  Future<void> _pickLanguage() async {
    final settings = context.read<SettingsProvider>();
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(title: const Text('English'), onTap: () => Navigator.pop(ctx, 'en')),
          ListTile(title: const Text('French'), onTap: () => Navigator.pop(ctx, 'fr')),
        ],
      ),
    );
    if (choice != null) await settings.setLanguage(choice);
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Log Out')),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) context.go('/login');
    }
  }

  Future<void> _deleteAccount() async {
    final first = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text('This action cannot be undone. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Continue')),
        ],
      ),
    );
    if (first != true) return;

    final second = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you absolutely sure? All data will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (second == true && mounted) {
      await UserService().deleteAccount();
      await AuthService().logout();
      if (mounted) context.go('/login');
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final settings = context.watch<SettingsProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          Center(
            child: CircleAvatar(
              radius: 40,
              child: Text(
                (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _section('Account'),
          ListTile(
            title: const Text('Display Name'),
            subtitle: Text(user?.name ?? ''),
            trailing: const Icon(Icons.chevron_right),
            onTap: _editName,
          ),
          ListTile(
            title: const Text('Email'),
            subtitle: Text(user?.email ?? ''),
          ),
          ListTile(
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password change coming soon')),
              );
            },
          ),
          _section('Preferences'),
          ListTile(
            title: const Text('Theme'),
            subtitle: Text(settings.themeMode.name),
            onTap: _pickTheme,
          ),
          ListTile(
            title: const Text('Language'),
            subtitle: Text(settings.language),
            onTap: _pickLanguage,
          ),
          SwitchListTile(
            title: const Text('Notifications'),
            value: settings.notificationsEnabled,
            onChanged: settings.setNotifications,
          ),
          _section('Library'),
          ListTile(
            title: const Text('My Favorites'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/favorites'),
          ),
          ListTile(
            title: const Text('Reading List'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/reading-list'),
          ),
          _section('About'),
          ListTile(title: const Text('App Version'), subtitle: Text(_version)),
          ListTile(
            title: const Text('Privacy Policy'),
            onTap: () => _openUrl('https://example.com/privacy'),
          ),
          ListTile(
            title: const Text('Terms of Service'),
            onTap: () => _openUrl('https://example.com/terms'),
          ),
          ListTile(
            title: const Text('Rate the App'),
            onTap: () {},
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: _logout,
              child: const Text('Log Out'),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
              onPressed: _deleteAccount,
              child: const Text('Delete Account'),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}
