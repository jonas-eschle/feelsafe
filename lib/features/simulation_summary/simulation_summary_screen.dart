import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import 'package:guardianangela/core/constants/route_names.dart';
import 'package:guardianangela/core/widgets/pin_keypad.dart';
import 'package:guardianangela/domain/models/session_log.dart';
import 'package:guardianangela/domain/models/session_log_event.dart';
import 'package:guardianangela/features/simulation_summary/simulation_summary_controller.dart';
import 'package:guardianangela/l10n/l10n/app_localizations.dart';

/// Shown after a simulation ends.
///
/// Renders the event timeline, missed-event badges, total duration,
/// and Share / Done CTAs. If `appSettings.sessionEndPinHash` is set a
/// PIN prompt blocks the summary until the user enters the correct PIN
/// or taps "Skip" (spec 04:1206–1235).
class SimulationSummaryScreen extends ConsumerStatefulWidget {
  /// Creates a [SimulationSummaryScreen].
  ///
  /// [logId] is the id of the [SessionLog] to summarise. When null or
  /// empty the screen falls back to the empty-state body.
  const SimulationSummaryScreen({super.key, this.logId});

  /// Session log id passed via the `?id=` route parameter.
  final String? logId;

  @override
  ConsumerState<SimulationSummaryScreen> createState() =>
      _SimulationSummaryScreenState();
}

class _SimulationSummaryScreenState
    extends ConsumerState<SimulationSummaryScreen> {
  @override
  void initState() {
    super.initState();
    final id = widget.logId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(simulationSummaryControllerProvider.notifier).loadFor(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final id = widget.logId;
    if (id == null || id.isEmpty) {
      return _EmptyScaffold(title: l10n.simulationSummaryTitle);
    }
    final async = ref.watch(simulationSummaryControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.simulationSummaryTitle),
        actions: <Widget>[
          if (async.value?.pinUnlocked ?? false)
            IconButton(
              tooltip: l10n.simulationSummaryShare,
              icon: const Icon(Icons.share),
              onPressed: () => _share(context, async.value!.log!, l10n),
            ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => Center(child: Text('Error: $e')),
        data: (state) {
          if (!state.pinUnlocked) {
            return _PinPrompt(state: state);
          }
          return _SummaryBody(state: state);
        },
      ),
    );
  }

  Future<void> _share(
    BuildContext context,
    SessionLog log,
    AppLocalizations l10n,
  ) async {
    final buf = StringBuffer()
      ..writeln('Guardian Angela simulation summary')
      ..writeln('Mode: ${log.modeName}')
      ..writeln('Start: ${log.startedAt.toIso8601String()}')
      ..writeln('End: ${log.endedAt?.toIso8601String() ?? '—'}')
      ..writeln('Events:');
    for (final e in log.events) {
      buf.writeln(
        '  ${e.timestamp.toIso8601String()} — ${e.eventType} — '
        '${e.description}',
      );
    }
    await SharePlus.instance.share(
      ShareParams(
        text: buf.toString(),
        subject: l10n.simulationSummaryShareSubject,
      ),
    );
  }
}

class _EmptyScaffold extends StatelessWidget {
  const _EmptyScaffold({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Icon(
                Icons.play_circle_outline,
                size: 64,
                color: Colors.orange,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Expanded(child: Center(child: Text(l10n.simulationSummaryEmpty))),
              FilledButton(
                onPressed: () => context.goNamed(RouteNames.home),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(l10n.simulationSummaryReturn),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinPrompt extends ConsumerStatefulWidget {
  const _PinPrompt({required this.state});

  final SimulationSummaryState state;

  @override
  ConsumerState<_PinPrompt> createState() => _PinPromptState();
}

class _PinPromptState extends ConsumerState<_PinPrompt>
    with SingleTickerProviderStateMixin {
  final List<int> _entry = <int>[];
  late final AnimationController _shake;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _shakeAnim = Tween<double>(
      begin: 0,
      end: 8,
    ).animate(CurvedAnimation(parent: _shake, curve: Curves.elasticIn));
  }

  @override
  void didUpdateWidget(covariant _PinPrompt old) {
    super.didUpdateWidget(old);
    if (widget.state.pinError && !old.state.pinError) {
      _shake.forward().then((_) {
        _shake.reset();
        if (!mounted) return;
        ref.read(simulationSummaryControllerProvider.notifier).clearPinError();
        setState(_entry.clear);
      });
    }
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  Future<void> _onDigit(int d) async {
    setState(() => _entry.add(d));
    if (_entry.length >= 4) {
      await ref
          .read(simulationSummaryControllerProvider.notifier)
          .submitPin(_entry.join());
    }
  }

  void _backspace() {
    if (_entry.isEmpty) return;
    setState(_entry.removeLast);
  }

  void _skip() =>
      ref.read(simulationSummaryControllerProvider.notifier).skipPin();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: <Widget>[
            const Icon(Icons.lock, size: 48),
            const SizedBox(height: 16),
            Text(l10n.simulationPinPromptTitle, style: textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              l10n.simulationPinPromptBody,
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: _shakeAnim,
              builder: (BuildContext ctx, Widget? child) {
                return Transform.translate(
                  offset: Offset(_shakeAnim.value, 0),
                  child: child,
                );
              },
              child: Text(
                List<String>.generate(
                  4,
                  (int i) => i < _entry.length ? '●' : '○',
                ).join(' '),
                style: textTheme.headlineMedium,
              ),
            ),
            if (widget.state.pinError) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                l10n.simulationPinIncorrect,
                style: textTheme.bodySmall?.copyWith(color: Colors.red),
              ),
            ],
            const SizedBox(height: 16),
            PinKeypad(onDigit: _onDigit, onBackspace: _backspace),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _skip,
              child: Text(l10n.simulationPinPromptSkip),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryBody extends StatelessWidget {
  const _SummaryBody({required this.state});

  final SimulationSummaryState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final log = state.log;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Icon(
              Icons.play_circle_outline,
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.simulationSummaryTitle,
              style: textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.simulationSummaryDuration(
                _formatDuration(state.durationSeconds),
              ),
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              alignment: WrapAlignment.center,
              children: <Widget>[
                Chip(
                  label: Text(
                    l10n.simulationSummaryStepsFiredBadge(
                      state.stepsFiredCount,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    l10n.simulationSummaryMissedEventsBadge(state.missedCount),
                  ),
                ),
                Chip(
                  label: Text(
                    l10n.simulationSummaryDistressBadge(state.distressCount),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.simulationSummaryTimelineHeader,
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(child: _Timeline(log: log)),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: () => context.goNamed(RouteNames.home),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(l10n.simulationSummaryReturn),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    final mm = minutes.toString().padLeft(2, '0');
    final ss = secs.toString().padLeft(2, '0');
    if (hours > 0) {
      final hh = hours.toString().padLeft(2, '0');
      return '$hh:$mm:$ss';
    }
    return '$mm:$ss';
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.log});

  final SessionLog? log;

  @override
  Widget build(BuildContext context) {
    final l = log;
    if (l == null || l.events.isEmpty) {
      final l10n = AppLocalizations.of(context);
      return Center(child: Text(l10n.simulationSummaryEmpty));
    }
    return ListView.builder(
      itemCount: l.events.length,
      itemBuilder: (BuildContext ctx, int i) {
        final e = l.events[i];
        return ListTile(
          dense: true,
          leading: _EventTypeBadge(eventType: e.eventType),
          title: Text(e.description.isEmpty ? e.eventType : e.description),
          subtitle: Text(_TimelineRow.timeOf(e)),
        );
      },
    );
  }
}

/// Renders a small coloured badge per event type (teal / amber / red
/// per spec 04:1282).
class _EventTypeBadge extends StatelessWidget {
  const _EventTypeBadge({required this.eventType});

  final String eventType;

  Color get _color {
    return switch (eventType) {
      'completed' || 'disarmed' || 'started' => Colors.teal,
      'step_fired' || 'escalated' => Colors.amber,
      'missed' || 'error' => Colors.red,
      _ => Colors.grey,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
    );
  }
}

/// Helper namespace for [_Timeline] formatters.
abstract final class _TimelineRow {
  /// Returns the event's UTC timestamp formatted as `HH:mm:ss`.
  static String timeOf(SessionLogEvent e) {
    final t = e.timestamp.toUtc();
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    final ss = t.second.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }
}
