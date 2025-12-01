import 'package:flutter/material.dart';
import 'package:moodie/constants/app_strings.dart';

class MoodleCredentialsForm extends StatefulWidget {
  final TextEditingController urlController;
  final TextEditingController tokenController;
  final bool hasUrlError;
  final bool hasTokenError;
  final VoidCallback? onUrlChanged;
  final VoidCallback? onTokenChanged;
  final VoidCallback? onHelpPressed;

  const MoodleCredentialsForm({
    super.key,
    required this.urlController,
    required this.tokenController,
    this.hasUrlError = false,
    this.hasTokenError = false,
    this.onUrlChanged,
    this.onTokenChanged,
    this.onHelpPressed,
  });

  @override
  State<MoodleCredentialsForm> createState() => _MoodleCredentialsFormState();
}

class _MoodleCredentialsFormState extends State<MoodleCredentialsForm> {
  bool _obscureToken = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: widget.urlController,
          decoration: InputDecoration(
            labelText: AppStrings.moodleUrlLabel,
            hintText: AppStrings.moodleUrlHint,
            helperText: ' ', // Reserve space for helper text to align with token field if needed, or just for spacing
            border: const OutlineInputBorder(),
            enabledBorder: widget.hasUrlError
                ? OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2),
                  )
                : null,
            focusedBorder: widget.hasUrlError
                ? OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2),
                  )
                : null,
            prefixIcon: const Icon(Icons.link),
          ),
          keyboardType: TextInputType.url,
          onChanged: (_) => widget.onUrlChanged?.call(),
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
          controller: widget.tokenController,
          decoration: InputDecoration(
            labelText: AppStrings.moodleTokenLabel,
            hintText: AppStrings.moodleTokenHint,
            helperText: ' ',
            border: const OutlineInputBorder(),
            enabledBorder: widget.hasTokenError
                ? OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.error, width: 2),
                  )
                : null,
            focusedBorder: widget.hasTokenError
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
                if (widget.onHelpPressed != null)
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: widget.onHelpPressed,
                    tooltip: AppStrings.onboardingTokenHelpTitle,
                  ),
              ],
            ),
          ),
          obscureText: _obscureToken,
          onChanged: (_) => widget.onTokenChanged?.call(),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return AppStrings.tokenRequired;
            }
            return null;
          },
        ),
      ],
    );
  }
}
