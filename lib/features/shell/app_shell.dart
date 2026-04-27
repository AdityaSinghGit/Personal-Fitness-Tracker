// Main shell: responsive [NavigationRail] or [NavigationBar], page switcher, and sign out.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_fitness_tracker/features/activity/activity_bloc.dart';
import 'package:personal_fitness_tracker/features/ai/ai_coach_bloc.dart';
import 'package:personal_fitness_tracker/features/ai/ai_page.dart';
import 'package:personal_fitness_tracker/features/auth/auth_bloc.dart';
import 'package:personal_fitness_tracker/features/progress/progress_page.dart';
import 'package:personal_fitness_tracker/features/profile/profile_bloc.dart';
import 'package:personal_fitness_tracker/features/profile/profile_page.dart';
import 'package:personal_fitness_tracker/features/activity/log_activity_page.dart';
import 'package:personal_fitness_tracker/util/app_colors.dart';
import 'package:personal_fitness_tracker/util/app_spacing.dart';
import 'package:personal_fitness_tracker/widgets/ambient_background.dart';
import 'package:personal_fitness_tracker/widgets/website/app_site_header.dart';

/// Main navigation after authentication. Uses a rail on wide web and a bottom bar on narrow viewports.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  /// Bumps to force the active page widget to remount (soft reload with [AppShell._onTab] data refresh).
  int _contentEpoch = 0;

  void _reloadCurrentPage() {
    setState(() {
      _contentEpoch++;
    });
    _onTab(_index);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints c) {
        final useRail = c.maxWidth >= AppSpacing.railBreakpoint;
        return AmbientBackground(
          blobs: _index != 3,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: useRail
                ? null
                : AppBar(
                    title: LumaFitAppBarTitle(onTap: _reloadCurrentPage),
                    actions: const <Widget>[_SignOutAction()],
                  ),
            body: useRail
                ? Column(
                    children: <Widget>[
                      AppSiteHeader(
                        sectionIndex: _index,
                        onBrandTap: _reloadCurrentPage,
                        actions: const <Widget>[_SignOutAction()],
                      ),
                      Expanded(
                        child: Row(
                          children: <Widget>[
                            _buildRail(context),
                            Expanded(
                              child: AnimatedSwitcher(
                                duration: AppSpacing.pageFade,
                                switchInCurve: Curves.easeOutCubic,
                                switchOutCurve: Curves.easeInCubic,
                                child: KeyedSubtree(
                                  key: ValueKey<String>('$_index-$_contentEpoch'),
                                  child: _pageFor(_index),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : SafeArea(
                    bottom: false,
                    top: true,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: AppSpacing.pageFade,
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeInCubic,
                            child: KeyedSubtree(
                              key: ValueKey<String>('$_index-$_contentEpoch'),
                              child: _pageFor(_index),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            bottomNavigationBar: useRail
                ? null
                : SafeArea(
                    top: false,
                    child: NavigationBar(
                      selectedIndex: _index,
                      onDestinationSelected: (int i) {
                        setState(() => _index = i);
                        _onTab(i);
                      },
                      destinations: const <NavigationDestination>[
                        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
                        NavigationDestination(icon: Icon(Icons.fitness_center_outlined), selectedIcon: Icon(Icons.fitness_center), label: 'Log'),
                        NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'Progress'),
                        NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Coach'),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildRail(BuildContext context) {
    return SafeArea(
      child: NavigationRail(
        selectedIndex: _index,
        onDestinationSelected: (int i) {
          setState(() => _index = i);
          _onTab(i);
        },
        backgroundColor: AppColors.surface.withValues(alpha: 0.35),
        labelType: NavigationRailLabelType.all,
        destinations: const <NavigationRailDestination>[
          NavigationRailDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: Text('Profile')),
          NavigationRailDestination(icon: Icon(Icons.fitness_center_outlined), selectedIcon: Icon(Icons.fitness_center), label: Text('Log')),
          NavigationRailDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: Text('Progress')),
          NavigationRailDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: Text('Coach')),
        ],
      ),
    );
  }

  void _onTab(int i) {
    if (i == 0) {
      context.read<ProfileBloc>().add(const ProfileLoad());
    } else if (i == 1 || i == 2) {
      context.read<ActivityBloc>().add(const ActivityLoad());
    } else if (i == 3) {
      context.read<AiCoachBloc>().add(const AiLoadKeyStatus());
    }
  }

  Widget _pageFor(int i) {
    switch (i) {
      case 0:
        return const ProfilePage();
      case 1:
        return const LogActivityPage();
      case 2:
        return const ProgressPage();
      case 3:
        return const AiPage();
      default:
        return const ProfilePage();
    }
  }
}

class _SignOutAction extends StatelessWidget {
  const _SignOutAction();
  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: IconButton.styleFrom(
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.all(12),
      ),
      tooltip: 'Sign out',
      onPressed: () {
        showDialog<void>(
          context: context,
          builder: (BuildContext c) => AlertDialog(
            title: const Text('Sign out?'),
            content: const Text(
              'You will need to sign in again to access your data after a full page refresh. Your encrypted API key file stays on this device.',
            ),
            actions: <Widget>[
              TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
              FilledButton(
                onPressed: () {
                  Navigator.pop(c);
                  context.read<AuthBloc>().add(const AuthSignOutRequested());
                },
                child: const Text('Sign out'),
              ),
            ],
          ),
        );
      },
      icon: const Icon(Icons.logout),
    );
  }
}
