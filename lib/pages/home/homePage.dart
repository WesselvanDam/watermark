import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../utils/shortcuts.dart';
import 'select/select.dart';
import 'settings/settings.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.arrowLeft): const PreviousIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowRight): const NextIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowUp): const MarkIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowDown): const UnmarkIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          PreviousIntent: PreviousAction(context, ref),
          NextIntent: NextAction(context, ref),
          UnmarkIntent: UnmarkAction(context, ref),
          MarkIntent: MarkAction(context, ref),
        },
        child: Builder(
          builder: (context) {
            return Focus(
              autofocus: true,
              child: Scaffold(
                body: Center(
                  heightFactor: 1,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: const SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Settings(),
                          Select(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
