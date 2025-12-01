import 'package:flutter/material.dart';
import 'package:moodie/constants/app_strings.dart';
import 'package:moodie/services/moodle_client.dart';
import 'package:moodie/utils/snackbar_helper.dart';
import 'package:moodie/screens/onboarding/onboarding_page_layout.dart';
import 'package:moodie/widgets/moodle_credentials_form.dart';

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
    return OnboardingPageLayout(
      image: Image.asset(
        'assets/images/sign-up-screen-transparent.webp',
        width: double.infinity,
        fit: BoxFit.contain,
      ),
      title: '', 
      body: AppStrings.onboardingConfigBody,
      content: Form(
        key: _formKey,
        child: Column(
          children: [
            MoodleCredentialsForm(
              urlController: _urlController,
              tokenController: _tokenController,
              hasUrlError: _hasUrlError,
              hasTokenError: _hasTokenError,
              onUrlChanged: () {
                if (_hasUrlError) {
                  setState(() {
                    _hasUrlError = false;
                  });
                }
              },
              onTokenChanged: () {
                if (_hasTokenError) {
                  setState(() {
                    _hasTokenError = false;
                  });
                }
              },
              onHelpPressed: _showTokenHelp,
            ),
          ],
        ),
      ),
      buttonText: AppStrings.onboardingContinue,
      onButtonPressed: _validateAndContinue,
      isLoading: _isLoading,
    );
  }
}
