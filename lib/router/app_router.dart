import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/route_names.dart';
import '../features/contacts/contact_form_screen.dart';
import '../features/contacts/contacts_screen.dart';
import '../features/escalation/escalation_settings_screen.dart';
import '../features/fake_call/fake_call_screen.dart';
import '../features/fake_call/fake_call_settings_screen.dart';
import '../features/home/home_screen.dart';
import '../features/modes/mode_editor_screen.dart';
import '../features/modes/modes_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/session/session_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/templates/reminder_templates_screen.dart';
import '../features/templates/template_editor_screen.dart';

GoRouter createRouter({bool isFirstLaunch = false}) {
  return GoRouter(
    initialLocation: isFirstLaunch ? RouteNames.onboarding : RouteNames.home,
    routes: [
      GoRoute(
        path: RouteNames.home,
        builder: (_, __) => const HomeScreen(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.session,
        builder: (_, __) => const SessionScreen(),
      ),
      GoRoute(
        path: RouteNames.fakeCall,
        builder: (_, __) => const FakeCallScreen(),
      ),
      GoRoute(
        path: RouteNames.contacts,
        builder: (_, __) => const ContactsScreen(),
      ),
      GoRoute(
        path: RouteNames.contactEdit,
        builder: (_, state) => ContactFormScreen(
          contactId: state.uri.queryParameters['id'],
        ),
      ),
      GoRoute(
        path: RouteNames.modes,
        builder: (_, __) => const ModesScreen(),
      ),
      GoRoute(
        path: RouteNames.modeEdit,
        builder: (_, state) => ModeEditorScreen(
          modeId: state.uri.queryParameters['id'],
        ),
      ),
      GoRoute(
        path: RouteNames.settings,
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: RouteNames.fakeCallSettings,
        builder: (_, __) => const FakeCallSettingsScreen(),
      ),
      GoRoute(
        path: RouteNames.escalationSettings,
        builder: (_, __) => const EscalationSettingsScreen(),
      ),
      GoRoute(
        path: RouteNames.reminderTemplates,
        builder: (_, __) => const ReminderTemplatesScreen(),
      ),
      GoRoute(
        path: RouteNames.templateEdit,
        builder: (_, state) => TemplateEditorScreen(
          templateId: state.uri.queryParameters['id'],
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri}'),
      ),
    ),
  );
}
