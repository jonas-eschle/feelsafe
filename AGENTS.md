# SafeWayHome - Agent Documentation

This document provides a high-level overview of the SafeWayHome repository to help AI agents and developers navigate and understand the codebase.

## Project Overview
SafeWayHome is a personal safety application built with Flutter. It implements a "dead man's switch" mechanism to ensure user safety during activities like walking home alone or going on dates.

## Tech Stack
- **Framework:** Flutter (Dart)
- **State Management:** Riverpod (`flutter_riverpod`)
- **Navigation:** GoRouter
- **Local Storage:** Hive (NoSQL)
- **Service Integration:** 
  - `geolocator` for location tracking.
  - `url_launcher` for SMS/WhatsApp/Calls.
  - `just_audio` & `vibration` for alerts.
  - `flutter_local_notifications` for disguised reminders.

## Architecture
The project follows a feature-first folder structure:
- `lib/core`: Shared utilities and constants.
- `lib/data`: Data models (Hive adapters), repositories, and seed data.
- `lib/features`: Module-specific logic and UI.
  - `session`: Core logic for the safety timer and escalation.
  - `escalation`: Management of what happens when a check-in is missed.
  - `contacts`: Emergency contact management.
- `lib/services`: Infrastructure-level services (Messaging, Location, Audio, etc.).
- `lib/router`: Centralized navigation configuration.

## Core Logic: The Session Engine
The `SessionEngine` (`lib/features/session/session_engine.dart`) is a pure Dart state machine that manages the safety session lifecycle. It supports two primary mechanisms:
1. **Hold Button (Walk Mode):** User must keep a button pressed. Releasing starts a grace period.
2. **Disguised Reminder (Date Mode):** Periodic notifications require user interaction.

If a check-in is missed beyond the allowed tolerance, the engine triggers an **Escalation Chain**.

## Escalation Chain
Defined in `lib/data/models/escalation_chain.dart`, the chain consists of sequential steps:
1. **Countdown Warning:** UI-based warning.
2. **Disguised Reminder:** Silent/Stealth notification.
3. **Fake Call:** Simulates an incoming call.
4. **SMS Contacts:** Sends GPS coordinates to emergency contacts.
5. **Loud Alarm:** Plays high-volume audio.
6. **Emergency Services:** Direct dial to 911/112.

## Messaging & Communication
`MessagingService` (`lib/services/messaging_service.dart`) handles outgoing communication via:
- SMS (using `sms:` URIs)
- WhatsApp (using `wa.me` links)
- Telegram (using `tg:` deep links)
- Phone Calls (using `tel:` URIs)

## Getting Started for Agents
- Start with `lib/main.dart` to see initialization and Hive setup.
- Examine `lib/features/session/session_engine.dart` for the core business logic.
- Look at `lib/data/models/` for the schema of the application's state.
