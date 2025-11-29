import 'package:flutter/material.dart';
import 'package:moodle_monitor/services/moodle_client.dart';
import 'package:moodle_monitor/constants/app_strings.dart';
import 'package:moodle_monitor/utils/snackbar_helper.dart';

import 'package:moodle_monitor/services/preferences_service.dart';

/// SettingsView allows users to configure app settings
/// Including Moodle credentials and theme preferences
class SettingsView extends StatefulWidget {
  final VoidCallback? onCredentialsSaved;
  final Function(ThemeMode)? onThemeChanged;

  const SettingsView({
    Key? key,
    this.onCredentialsSaved,
    this.onThemeChanged,
  }) : super(key: key);

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _tokenController = TextEditingController();
  final _moodleClient = MoodleClient();
  
  ThemeMode _currentTheme = ThemeMode.system;

  bool _isLoading = false;
  bool _isSaving = false;
  bool _obscureToken = true;

  @override
  void initState() {
    super.initState();
    _loadExistingCredentials();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await PreferencesService.getInstance();
    final savedTheme = prefs.getThemeMode();
    if (mounted) {
      setState(() {
        _currentTheme = _getThemeModeFromString(savedTheme);
      });
    }
  }

  ThemeMode _getThemeModeFromString(String theme) {
    switch (theme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> _loadExistingCredentials() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final url = await _moodleClient.getMoodleUrl();
      final token = await _moodleClient.getMoodleToken();

      if (mounted) {
        setState(() {
          _urlController.text = url ?? '';
          _tokenController.text = token ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveCredentials() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final url = _urlController.text.trim();
      final token = _tokenController.text.trim();

      await _moodleClient.saveCredentials(url: url, token: token);

      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        SnackbarHelper.showSuccess(
          context,
          AppStrings.credentialsSaved,
          duration: const Duration(seconds: 2),
        );

        // Notify parent that credentials were saved
        widget.onCredentialsSaved?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        SnackbarHelper.showError(
          context,
          '${AppStrings.saveError}: $e',
          duration: const Duration(seconds: 4),
        );
      }
    }
  }

  Future<void> _clearCredentials() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.clearConfirmTitle),
        content: const Text(AppStrings.clearConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancelButton),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(AppStrings.clearConfirmButton),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _moodleClient.clearCredentials();
      setState(() {
        _urlController.clear();
        _tokenController.clear();
      });

      if (mounted) {
        SnackbarHelper.showInfo(
          context,
          AppStrings.credentialsCleared,
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                AppStrings.settingsTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 32),
              
              // Appearance Section
              Text(
                AppStrings.appearanceSection,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.light,
                      label: Text(AppStrings.themeModeLight),
                      icon: Icon(Icons.wb_sunny_outlined),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.dark,
                      label: Text(AppStrings.themeModeDark),
                      icon: Icon(Icons.dark_mode_outlined),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.system,
                      label: Text(AppStrings.themeModeSystem),
                      icon: Icon(Icons.brightness_auto_outlined),
                    ),
                  ],
                  selected: {_currentTheme},
                  onSelectionChanged: (Set<ThemeMode> newSelection) {
                    setState(() {
                      _currentTheme = newSelection.first;
                    });
                    widget.onThemeChanged?.call(newSelection.first);
                  },
                ),
              ),
              
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 24),

              // Credentials Section
              Text(
                AppStrings.connectionSection,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.settingsDescription,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: AppStrings.moodleUrlLabel,
                  hintText: AppStrings.moodleUrlHint,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.urlRequired;
                  }
                  if (!value.trim().startsWith('http://') &&
                      !value.trim().startsWith('https://')) {
                    return AppStrings.urlInvalid;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _tokenController,
                decoration: InputDecoration(
                  labelText: AppStrings.moodleTokenLabel,
                  hintText: AppStrings.moodleTokenHint,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.vpn_key),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureToken ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureToken = !_obscureToken;
                      });
                    },
                  ),
                ),
                obscureText: _obscureToken,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppStrings.tokenRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isSaving ? null : _saveCredentials,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1.5,
                    ),
                  ),
                  icon: _isSaving
                      ? SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )
                      : const Icon(Icons.check_circle, size: 20),
                  label: const Text(
                    AppStrings.saveButton,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _clearCredentials,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1.5,
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline, size: 20),
                  label: const Text(
                    AppStrings.clearButton,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                AppStrings.tokenInstructionsTitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                AppStrings.tokenInstructions,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[700],
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
