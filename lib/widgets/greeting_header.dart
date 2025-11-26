import 'package:flutter/material.dart';
import 'package:moodle_monitor/utils/greeting_helper.dart';
import 'package:moodle_monitor/constants/text_styles.dart';

class GreetingHeader extends StatelessWidget {
  final Widget? trailingWidget;

  const GreetingHeader({Key? key, this.trailingWidget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final greeting = GreetingHelper.getGreeting(DateTime.now());

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              greeting,
              style: TextStyles.heading,
            ),
          ),
          if (trailingWidget != null)
            trailingWidget!
          else
            Image.asset(
              'assets/images/logo.png',
              width: 32,
              height: 32,
              fit: BoxFit.contain,
            ),
        ],
      ),
    );
  }
}
