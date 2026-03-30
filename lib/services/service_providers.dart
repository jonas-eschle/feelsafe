import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'audio_service.dart';
import 'location_service.dart';
import 'messaging_service.dart';
import 'phone_service.dart';
import 'vibration_service.dart';
import 'wakelock_service.dart';

final audioServiceProvider = Provider((_) => AudioService());
final locationServiceProvider = Provider((_) => LocationService());
final messagingServiceProvider = Provider((_) => MessagingService());
final phoneServiceProvider = Provider((_) => PhoneService());
final vibrationServiceProvider = Provider((_) => VibrationService());
final wakelockServiceProvider = Provider((_) => WakelockService());
