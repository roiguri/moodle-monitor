import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:moodie/constants/app_strings.dart';
import 'package:moodie/services/moodle_client.dart';
import 'package:moodie/utils/snackbar_helper.dart';

class OnboardingConfigPage extends StatefulWidget {
  final VoidCallback onNext;

  const OnboardingConfigPage({super.key, required this.onNext});

  @override
  State<OnboardingConfigPage> createState() => _OnboardingConfigPageState();
}

class _OnboardingConfigPageState extends State<OnboardingConfigPage> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _tokenController = TextEditingController();
  final _moodleClient = MoodleClient();

  bool _isLoading = false;
  bool _obscureToken = true;
  bool _hasUrlError = false;
  bool _hasTokenError = false;

  @override
  void dispose() {
    _urlController.dispose();
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _validateAndContinue() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url = _urlController.text.trim();
      final token = _tokenController.text.trim();

      // Validate credentials
      await _moodleClient.validateCredentials(url: url, token: token);

      // Save credentials
      await _moodleClient.saveCredentials(url: url, token: token);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        widget.onNext();
      }
    } on AuthException {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasUrlError = false;
          _hasTokenError = true;
        });
        SnackbarHelper.showError(
          context,
          AppStrings.validationInvalidToken,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasUrlError = true;
          _hasTokenError = false;
        });
        
        String errorMessage;
        if (e.toString().contains('timeout') || e.toString().contains('Connection timeout')) {
          errorMessage = AppStrings.validationTimeout;
        } else if (e.toString().contains('connect') || e.toString().contains('SocketException')) {
          errorMessage = AppStrings.validationConnectionError;
        } else {
          errorMessage = AppStrings.validationConnectionError;
        }

        SnackbarHelper.showError(
          context,
          errorMessage,
          duration: const Duration(seconds: 4),
        );
      }
    }
  }

  void _showTokenHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.onboardingTokenHelpTitle),
        content: const Text(AppStrings.tokenInstructions),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(AppStrings.onboardingFinish), // Using "Finish" as "Close/OK"
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final buttonColor = isDark ? Colors.white : const Color(0xFF2C2C2C);
    final buttonTextColor = isDark ? Colors.black : Colors.white;

    return Column(
      children: [
        const SizedBox(height: 60),
        Expanded(
          child: Column(
            children: [
              Flexible(
                child: Image.asset(
                  'assets/images/sign-up-screen-transparent.webp',
                  width: double.infinity,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  AppStrings.onboardingConfigBody,
                  style: GoogleFonts.assistant(
                    textStyle: Theme.of(context).textTheme.bodyLarge,
                    color: textColor,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _urlController,
                        decoration: InputDecoration(
                          labelText: AppStrings.moodleUrlLabel,
                          hintText: AppStrings.moodleUrlHint,
                          helperText: ' ',
                          border: const OutlineInputBorder(),
                          enabledBorder: _hasUrlError
                              ? OutlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2),
                                )
                              : null,
                          focusedBorder: _hasUrlError
                              ? OutlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2),
                                )
                              : null,
                          prefixIcon: const Icon(Icons.link),
                        ),
                        keyboardType: TextInputType.url,
                        onChanged: (_) {
                          if (_hasUrlError) {
                            setState(() {
                              _hasUrlError = false;
                            });
                          }
                        },
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
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _tokenController,
                        decoration: InputDecoration(
                          labelText: AppStrings.moodleTokenLabel,
                          hintText: AppStrings.moodleTokenHint,
                          helperText: ' ',
                          border: const OutlineInputBorder(),
                          enabledBorder: _hasTokenError
                              ? OutlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2),
                                )
                              : null,
                          focusedBorder: _hasTokenError
                              ? OutlineInputBorder(
                                  borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2),
                                )
                              : null,
                          prefixIcon: const Icon(Icons.vpn_key),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  _obscureToken ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureToken = !_obscureToken;
                                  });
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.info_outline),
                                onPressed: _showTokenHelp,
                                tooltip: AppStrings.onboardingTokenHelpTitle,
                              ),
                            ],
                          ),
                        ),
                        obscureText: _obscureToken,
                        onChanged: (_) {
                          if (_hasTokenError) {
                            setState(() {
                              _hasTokenError = false;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppStrings.tokenRequired;
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isLoading ? null : _validateAndContinue,
              style: FilledButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: buttonTextColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: buttonTextColor,
                      ),
                    )
                  : const Text(
                      AppStrings.onboardingContinue,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 64),
      ],
    );
  }
}
