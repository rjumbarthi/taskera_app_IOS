import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/asana_service.dart';
import '../../services/github_service.dart';
import '../../services/google_service.dart';
import '../../services/jira_service.dart';
import '../../services/linear_service.dart';
import '../../services/microsoft_service.dart';
import '../../services/notion_service.dart';
import '../../services/openai_service.dart';
import '../../services/slack_service.dart';
import '../../services/todoist_service.dart';

class IntegrationsState {
  const IntegrationsState({
    this.googleCalendarConnected = false,
    this.gmailConnected          = false,
    this.microsoftConnected      = false,
    this.notionConnected         = false,
    this.todoistConnected        = false,
    this.slackConnected          = false,
    this.jiraConnected           = false,
    this.asanaConnected          = false,
    this.linearConnected         = false,
    this.githubConnected         = false,
    this.openAiConnected         = false,
    this.anthropicConnected      = false,
    this.loading                 = false,
  });

  final bool googleCalendarConnected;
  final bool gmailConnected;
  final bool microsoftConnected;
  final bool notionConnected;
  final bool todoistConnected;
  final bool slackConnected;
  final bool jiraConnected;
  final bool asanaConnected;
  final bool linearConnected;
  final bool githubConnected;
  final bool openAiConnected;
  final bool anthropicConnected;
  final bool loading;

  IntegrationsState copyWith({
    bool? googleCalendarConnected,
    bool? gmailConnected,
    bool? microsoftConnected,
    bool? notionConnected,
    bool? todoistConnected,
    bool? slackConnected,
    bool? jiraConnected,
    bool? asanaConnected,
    bool? linearConnected,
    bool? githubConnected,
    bool? openAiConnected,
    bool? anthropicConnected,
    bool? loading,
  }) =>
      IntegrationsState(
        googleCalendarConnected:
            googleCalendarConnected ?? this.googleCalendarConnected,
        gmailConnected:     gmailConnected     ?? this.gmailConnected,
        microsoftConnected: microsoftConnected ?? this.microsoftConnected,
        notionConnected:    notionConnected    ?? this.notionConnected,
        todoistConnected:   todoistConnected   ?? this.todoistConnected,
        slackConnected:     slackConnected     ?? this.slackConnected,
        jiraConnected:      jiraConnected      ?? this.jiraConnected,
        asanaConnected:     asanaConnected     ?? this.asanaConnected,
        linearConnected:    linearConnected    ?? this.linearConnected,
        githubConnected:    githubConnected    ?? this.githubConnected,
        openAiConnected:    openAiConnected    ?? this.openAiConnected,
        anthropicConnected: anthropicConnected ?? this.anthropicConnected,
        loading:            loading            ?? this.loading,
      );
}

class IntegrationsNotifier extends Notifier<IntegrationsState> {
  @override
  IntegrationsState build() => const IntegrationsState();

  // ── Status check ────────────────────────────────────────────────────────────

  Future<void> checkStatus() async {
    final gs     = ref.read(googleServiceProvider);
    final ms     = ref.read(microsoftServiceProvider);
    final notion = ref.read(notionServiceProvider);
    final td     = ref.read(todoistServiceProvider);
    final slack  = ref.read(slackServiceProvider);
    final jira   = ref.read(jiraServiceProvider);
    final asana  = ref.read(asanaServiceProvider);
    final linear = ref.read(linearServiceProvider);
    final gh     = ref.read(githubServiceProvider);
    final oai    = ref.read(openAiServiceProvider);
    final anth   = ref.read(anthropicServiceProvider);

    final results = await Future.wait([
      gs.isCalConnected,
      gs.isGmailConnected,
      ms.isConnected,
      notion.isConnected,
      td.isConnected,
      slack.isConnected,
      jira.isConnected,
      asana.isConnected,
      linear.isConnected,
      gh.isConnected,
      oai.isConnected,
      anth.isConnected,
    ]);

    state = IntegrationsState(
      googleCalendarConnected: results[0],
      gmailConnected:          results[1],
      microsoftConnected:      results[2],
      notionConnected:         results[3],
      todoistConnected:        results[4],
      slackConnected:          results[5],
      jiraConnected:           results[6],
      asanaConnected:          results[7],
      linearConnected:         results[8],
      githubConnected:         results[9],
      openAiConnected:         results[10],
      anthropicConnected:      results[11],
    );
  }

  // ── Google Calendar ──────────────────────────────────────────────────────────

  Future<bool> connectGoogleCalendar() async {
    state = state.copyWith(loading: true);
    try {
      final ok = await ref.read(googleServiceProvider).connectCalendar();
      state = state.copyWith(loading: false, googleCalendarConnected: ok);
      return ok;
    } catch (_) {
      state = state.copyWith(loading: false);
      return false;
    }
  }

  Future<void> disconnectCalendar() async {
    await ref.read(googleServiceProvider).disconnectCalendar();
    state = state.copyWith(googleCalendarConnected: false);
  }

  // ── Gmail ────────────────────────────────────────────────────────────────────

  Future<bool> connectGmail() async {
    state = state.copyWith(loading: true);
    try {
      final ok = await ref.read(googleServiceProvider).connectGmail();
      state = state.copyWith(loading: false, gmailConnected: ok);
      return ok;
    } catch (_) {
      state = state.copyWith(loading: false);
      return false;
    }
  }

  Future<void> disconnectGmail() async {
    await ref.read(googleServiceProvider).disconnectGmail();
    state = state.copyWith(gmailConnected: false);
  }

  Future<void> disconnectGoogle() async {
    await ref.read(googleServiceProvider).disconnect();
    state = state.copyWith(googleCalendarConnected: false, gmailConnected: false);
  }

  // ── Microsoft ────────────────────────────────────────────────────────────────

  Future<bool> connectMicrosoft() async {
    state = state.copyWith(loading: true);
    try {
      final ok = await ref.read(microsoftServiceProvider).connect();
      state = state.copyWith(loading: false, microsoftConnected: ok);
      return ok;
    } catch (_) {
      state = state.copyWith(loading: false);
      return false;
    }
  }

  Future<void> disconnectMicrosoft() async {
    await ref.read(microsoftServiceProvider).disconnect();
    state = state.copyWith(microsoftConnected: false);
  }

  // ── Notion ───────────────────────────────────────────────────────────────────

  Future<bool> connectNotion() async {
    state = state.copyWith(loading: true);
    try {
      final ok = await ref.read(notionServiceProvider).connect();
      state = state.copyWith(loading: false, notionConnected: ok);
      return ok;
    } catch (_) {
      state = state.copyWith(loading: false);
      return false;
    }
  }

  Future<void> disconnectNotion() async {
    await ref.read(notionServiceProvider).disconnect();
    state = state.copyWith(notionConnected: false);
  }

  // ── Todoist ──────────────────────────────────────────────────────────────────

  Future<bool> connectTodoist() async {
    state = state.copyWith(loading: true);
    try {
      final ok = await ref.read(todoistServiceProvider).connect();
      state = state.copyWith(loading: false, todoistConnected: ok);
      return ok;
    } catch (_) {
      state = state.copyWith(loading: false);
      return false;
    }
  }

  Future<void> disconnectTodoist() async {
    await ref.read(todoistServiceProvider).disconnect();
    state = state.copyWith(todoistConnected: false);
  }

  // ── Slack ────────────────────────────────────────────────────────────────────

  Future<bool> connectSlack() async {
    state = state.copyWith(loading: true);
    try {
      final ok = await ref.read(slackServiceProvider).connect();
      state = state.copyWith(loading: false, slackConnected: ok);
      return ok;
    } catch (_) {
      state = state.copyWith(loading: false);
      return false;
    }
  }

  Future<void> disconnectSlack() async {
    await ref.read(slackServiceProvider).disconnect();
    state = state.copyWith(slackConnected: false);
  }

  // ── Jira ─────────────────────────────────────────────────────────────────────

  Future<bool> connectJira() async {
    state = state.copyWith(loading: true);
    try {
      final ok = await ref.read(jiraServiceProvider).connect();
      state = state.copyWith(loading: false, jiraConnected: ok);
      return ok;
    } catch (_) {
      state = state.copyWith(loading: false);
      return false;
    }
  }

  Future<void> disconnectJira() async {
    await ref.read(jiraServiceProvider).disconnect();
    state = state.copyWith(jiraConnected: false);
  }

  // ── Asana ────────────────────────────────────────────────────────────────────

  Future<bool> connectAsana() async {
    state = state.copyWith(loading: true);
    try {
      final ok = await ref.read(asanaServiceProvider).connect();
      state = state.copyWith(loading: false, asanaConnected: ok);
      return ok;
    } catch (_) {
      state = state.copyWith(loading: false);
      return false;
    }
  }

  Future<void> disconnectAsana() async {
    await ref.read(asanaServiceProvider).disconnect();
    state = state.copyWith(asanaConnected: false);
  }

  // ── Linear ───────────────────────────────────────────────────────────────────

  Future<bool> connectLinear() async {
    state = state.copyWith(loading: true);
    try {
      final ok = await ref.read(linearServiceProvider).connect();
      state = state.copyWith(loading: false, linearConnected: ok);
      return ok;
    } catch (_) {
      state = state.copyWith(loading: false);
      return false;
    }
  }

  Future<void> disconnectLinear() async {
    await ref.read(linearServiceProvider).disconnect();
    state = state.copyWith(linearConnected: false);
  }

  // ── GitHub ───────────────────────────────────────────────────────────────────

  Future<bool> connectGitHub() async {
    state = state.copyWith(loading: true);
    try {
      final ok = await ref.read(githubServiceProvider).connect();
      state = state.copyWith(loading: false, githubConnected: ok);
      return ok;
    } catch (_) {
      state = state.copyWith(loading: false);
      return false;
    }
  }

  Future<void> disconnectGitHub() async {
    await ref.read(githubServiceProvider).disconnect();
    state = state.copyWith(githubConnected: false);
  }

  // ── OpenAI ───────────────────────────────────────────────────────────────────

  Future<bool> connectOpenAi(String apiKey) async {
    state = state.copyWith(loading: true);
    try {
      final ok = await ref.read(openAiServiceProvider).setKey(apiKey);
      state = state.copyWith(loading: false, openAiConnected: ok);
      return ok;
    } catch (_) {
      state = state.copyWith(loading: false);
      return false;
    }
  }

  Future<void> disconnectOpenAi() async {
    await ref.read(openAiServiceProvider).disconnect();
    state = state.copyWith(openAiConnected: false);
  }

  // ── Anthropic / Claude ───────────────────────────────────────────────────────

  Future<bool> connectAnthropic(String apiKey) async {
    state = state.copyWith(loading: true);
    try {
      final ok = await ref.read(anthropicServiceProvider).setKey(apiKey);
      state = state.copyWith(loading: false, anthropicConnected: ok);
      return ok;
    } catch (_) {
      state = state.copyWith(loading: false);
      return false;
    }
  }

  Future<void> disconnectAnthropic() async {
    await ref.read(anthropicServiceProvider).disconnect();
    state = state.copyWith(anthropicConnected: false);
  }
}

final integrationsProvider =
    NotifierProvider<IntegrationsNotifier, IntegrationsState>(
  IntegrationsNotifier.new,
);
