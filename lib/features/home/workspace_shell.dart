import 'package:flutter/material.dart';

import '../config/settings.dart';
import '../inspector/inspector_panel.dart';
import '../workspace/select/workspace.dart';

const double _leftPanelWidth = 320.0;
const double _rightPanelWidth = 320.0;
const double _fullShellBreakpoint = 1280.0;
const double _leftOnlyBreakpoint = 768.0;

class WorkspaceShell extends StatelessWidget {
  const WorkspaceShell({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final showLeft = width >= _leftOnlyBreakpoint;
        final showRight = width >= _fullShellBreakpoint;
        final useDrawers = width < _leftOnlyBreakpoint;

        return Scaffold(
          appBar: useDrawers ? _buildAppBar(context) : null,
          drawer: useDrawers
              ? const Drawer(
                  width: _leftPanelWidth,
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Settings(asPanel: true),
                      ),
                    ),
                  ),
                )
              : null,
          endDrawer: useDrawers
              ? const Drawer(
                  width: _rightPanelWidth,
                  child: SafeArea(child: InspectorPanel()),
                )
              : null,
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showLeft)
                const SidebarFrame(
                  width: _leftPanelWidth,
                  borderOnRight: true,
                  child: SingleChildScrollView(
                    child: Settings(asPanel: true),
                  ),
                ),
              const Expanded(child: SelectCanvas()),
              if (showRight)
                const SidebarFrame(
                  width: _rightPanelWidth,
                  borderOnLeft: true,
                  child: InspectorPanel(),
                ),
            ],
          ),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Watermark'),
      actions: [
        Builder(
          builder: (context) {
            return IconButton(
              tooltip: 'Inspector',
              icon: const Icon(Icons.tune),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            );
          },
        ),
      ],
    );
  }
}

class SelectCanvas extends StatelessWidget {
  const SelectCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: colorScheme.surface,
      child: const SafeArea(left: false, right: false, child: Workspace()),
    );
  }
}

class SidebarFrame extends StatelessWidget {
  const SidebarFrame({
    required this.width,
    required this.child,
    this.borderOnLeft = false,
    this.borderOnRight = false,
    super.key,
  });

  final double width;
  final Widget child;
  final bool borderOnLeft;
  final bool borderOnRight;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderSide = BorderSide(color: colorScheme.outlineVariant);
    return Container(
      width: width,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        border: Border(
          left: borderOnLeft ? borderSide : BorderSide.none,
          right: borderOnRight ? borderSide : BorderSide.none,
        ),
      ),
      child: SafeArea(
        child: Padding(padding: const EdgeInsets.all(16.0), child: child),
      ),
    );
  }
}
