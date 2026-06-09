/// Per-country emergency-services telephone numbers (R-8).
///
/// **Safety-critical data.** The app DIALS the resolved number in an
/// emergency (`callEmergency` step, spec 02 §9). A wrong entry could send a
/// user to a dead line, so every value is sourced and the few entries that
/// were adjusted away from the base reference carry an inline citation.
///
/// ## Methodology
/// Base reference: Wikipedia "List of emergency telephone numbers", cross-
/// checked against ITU / national-government / embassy sources. Owner-reviewed
/// 2026-06-09.
///
/// ## Selection rule — "unified-else-police"
/// For each country the value is **the official unified all-services number
/// where one genuinely exists** (one number reaching police + fire +
/// ambulance — e.g. `112` across the EU and the many GSM-112 countries, `911`
/// where it is the integrated US/Canada/Latin-America number, `999` for the
/// unified UK/Bangladesh/Kenya line, `000` AU, `111` NZ). **For countries with
/// no single all-services number (split services) the value is the POLICE
/// line** (e.g. CN `110`, JP `110`, BR `190`, VN `113`, TH `191`). Police is
/// chosen for split countries because a distress call is most often a personal-
/// safety event, and police dispatchers can escalate to fire/ambulance.
///
/// ## Fallback
/// [kEmergencyFallback] (`'112'`) is the GSM international standard: GSM
/// handsets route `112` to local emergency services in virtually every
/// network worldwide, even with no SIM, no credit, or the keypad locked. It is
/// the safest possible value for an unmapped region, so countries absent from
/// this map (including the deliberately-excluded micro-states) resolve to it.
///
/// ## Keys
/// ISO 3166-1 alpha-2 country codes (upper-case).
library;

/// GSM international-standard emergency number used when the device region is
/// not present in [emergencyNumbers] or region resolution fails.
///
/// `112` is reachable on GSM/UMTS/LTE networks worldwide without a SIM or
/// credit; it is the universally-safe default (spec 06 §Emergency Number).
const String kEmergencyFallback = '112';

/// Emergency-services number by ISO 3166-1 alpha-2 region code.
///
/// See the library doc-comment for the sourcing methodology and the
/// "unified-else-police" selection rule. Unmapped regions fall through to
/// [kEmergencyFallback].
const Map<String, String> emergencyNumbers = <String, String>{
  // ── Top countries by population ──────────────────────────────────────
  'IN': '112', // India — unified emergency number.
  'CN': '110', // China — split; police line (ambulance 120, fire 119).
  'US': '911', // United States — unified.
  'ID': '112', // Indonesia — unified.
  // Pakistan — split; POLICE line 15 (nationwide). Adjusted from the draft's
  // 1122, which is Rescue 1122 (ambulance/fire, Punjab/KP/AJK/GB only, not
  // nationwide police). Verified: Punjab Police / Islamabad Police helplines.
  'PK': '15',
  'NG': '112', // Nigeria — unified.
  'BR': '190', // Brazil — split; police line (ambulance 192, fire 193).
  'BD': '999', // Bangladesh — unified national emergency number.
  'RU': '112', // Russia — unified.
  'MX': '911', // Mexico — unified.
  'JP': '110', // Japan — split; police line (fire/ambulance 119).
  // Ethiopia — VERIFY: sources conflict (Wikipedia lists police 991 and a
  // unified 911). Owner accepted shipping 911 + this flag.
  'ET': '911', // VERIFY: sources conflict (911 unified vs 991 police).
  'PH': '911', // Philippines — unified (911).
  'EG': '112', // Egypt — unified (112; police also 122).
  'VN': '113', // Vietnam — split; police line (ambulance 115, fire 114).
  'CD': '112', // DR Congo — 112.
  'TR': '112', // Turkey — unified.
  'IR': '110', // Iran — split; police line.
  // Germany — 112 (EU unified all-services). Owner final review 2026-06-09 chose
  // 112 over the police line 110: the 112 control centre dispatches all services
  // (police/fire/ambulance), so it is Germany's unified emergency number.
  'DE': '112',
  'TH': '191', // Thailand — split; police line.
  // ── Large European / other ───────────────────────────────────────────
  'GB': '999', // United Kingdom — unified (999; 112 also works).
  'FR': '112', // France — unified (EU 112).
  'IT': '112', // Italy — unified (EU 112).
  // South Africa — KEEP 112: from a mobile, 112 routes to an all-services
  // emergency dispatch centre (a genuine unified route). Landline police is
  // 10111. Owner-confirmed.
  'ZA': '112',
  'TZ': '112', // Tanzania — unified.
  'MM': '199', // Myanmar — split; police line (fire 191, ambulance 192).
  'KE': '999', // Kenya — unified (999; 112 also reaches all services).
  'KR': '112', // South Korea — police line (112; fire/medical 119).
  'CO': '123', // Colombia — unified national line (NUSE 123, all services).
  'ES': '112', // Spain — unified (EU 112).
  'AR': '911', // Argentina — unified.
  'DZ': '17', // Algeria — split; police line (17; fire 14, ambulance 16).
  'SD': '999', // Sudan — unified.
  'UA': '112', // Ukraine — unified.
  'UG': '999', // Uganda — unified (999; 112 also reaches all services).
  'IQ': '104', // Iraq — split; police line (104).
  'PL': '112', // Poland — unified (EU 112).
  'CA': '911', // Canada — unified.
  'MA': '19', // Morocco — split; police line (19; 112 mobile-only).
  'SA': '911', // Saudi Arabia — unified (911).
  // ── Mid-population ───────────────────────────────────────────────────
  'UZ': '112', // Uzbekistan — unified.
  'NP': '100', // Nepal — split; police line.
  'LK': '119', // Sri Lanka — split; police line.
  'MY': '999', // Malaysia — unified (999).
  'AF': '119', // Afghanistan — split; police line.
  'PE': '105', // Peru — police line (105; 911 also operates).
  'IL': '100', // Israel — split; police line (fire 102, ambulance 101).
  'AE': '999', // United Arab Emirates — unified (999).
  'GH': '112', // Ghana — unified.
  'KZ': '112', // Kazakhstan — unified.
  'CL': '133', // Chile — split; police line (Carabineros 133).
  'SG': '999', // Singapore — unified (999; ambulance/fire 995).
  'VE': '911', // Venezuela — unified.
  'EC': '911', // Ecuador — unified.
  'BO': '110', // Bolivia — split; police line.
  'JO': '911', // Jordan — unified (911).
  'QA': '999', // Qatar — unified (999).
  'OM': '9999', // Oman — unified (9999).
  'KW': '112', // Kuwait — unified.
  'CM': '117', // Cameroon — split; police line (fire 118, medical 119).
  // Côte d'Ivoire — VERIFY: sources conflict (police listed variously as
  // 110 / 111 / 170; no single unified number). Owner accepted shipping 111
  // + this flag.
  'CI': '111', // VERIFY: sources conflict (police 110/111/170).
  'SN': '17', // Senegal — split; police line.
  'TW': '110', // Taiwan — split; police line (fire/ambulance 119).
  'HK': '999', // Hong Kong — unified (999).
  'AO': '113', // Angola — split; police line.
  'MZ': '119', // Mozambique — split; police line.
  'TN': '197', // Tunisia — split; police line.
  'LY': '1515', // Libya — split; police line.
  'RW': '112', // Rwanda — unified.
  'BW': '999', // Botswana — unified (999).
  'NA': '10111', // Namibia — police line (nationwide).
  'MG': '117', // Madagascar — split; police line.
  'ML': '17', // Mali — split; police line.
  'NE': '17', // Niger — split; police line.
  'BF': '17', // Burkina Faso — split; police line.
  'YE': '199', // Yemen — split; police line.
  'SY': '112', // Syria — unified (112).
  'LB': '112', // Lebanon — unified (112; police 999/112).
  // ── Remaining EU / EEA (all unified EU 112) ──────────────────────────
  'NL': '112', // Netherlands.
  'BE': '112', // Belgium.
  'SE': '112', // Sweden.
  'PT': '112', // Portugal.
  'GR': '112', // Greece.
  'CH': '112', // Switzerland.
  'AT': '112', // Austria.
  'IE': '112', // Ireland.
  'RO': '112', // Romania.
  'NO': '112', // Norway.
  'DK': '112', // Denmark.
  'FI': '112', // Finland.
  'CZ': '112', // Czechia.
  'HU': '112', // Hungary.
  'HR': '112', // Croatia.
  'RS': '112', // Serbia.
  'GE': '112', // Georgia.
  'AZ': '112', // Azerbaijan.
  'BY': '112', // Belarus.
  // ── Remaining Latin America (911 unified) ────────────────────────────
  'DO': '911', // Dominican Republic.
  'CR': '911', // Costa Rica.
  'PA': '911', // Panama.
  'GT': '110', // Guatemala — split; police line.
  'CU': '106', // Cuba — split; police line.
  'HN': '911', // Honduras — unified.
  'SV': '911', // El Salvador — unified.
  'NI': '118', // Nicaragua — split; police line.
  'PY': '911', // Paraguay — unified.
  'UY': '911', // Uruguay — unified.
  // ── Oceania ──────────────────────────────────────────────────────────
  'AU': '000', // Australia — unified (000; 112 also works on mobiles).
  'NZ': '111', // New Zealand — unified (111).
};

/// Resolves the seed emergency number for a device [locale] string.
///
/// Used for first-launch seeding (spec 06 §Emergency Number, precedence
/// tier 2). [locale] is a platform locale identifier such as `en_US`,
/// `de-DE`, `pt_BR.UTF-8`, or a bare language tag like `en`. The region is
/// taken as the segment after the first `_` or `-`, up to any `.` codeset
/// suffix, upper-cased; an empty or region-less locale, or a region not in
/// [emergencyNumbers], yields [kEmergencyFallback].
///
/// Pure and total: never throws, always returns a non-empty number.
String emergencyNumberForLocale(String locale) {
  final String region = _regionOf(locale);
  if (region.isEmpty) {
    return kEmergencyFallback;
  }
  return emergencyNumbers[region] ?? kEmergencyFallback;
}

/// Extracts the upper-cased region subtag from a platform [locale] string, or
/// `''` when none is present.
///
/// Handles `lang_REGION`, `lang-REGION`, and a trailing `.codeset`
/// (e.g. `en_US.UTF-8` → `US`). Returns `''` for a bare language (`en`) or an
/// empty string.
String _regionOf(String locale) {
  if (locale.isEmpty) {
    return '';
  }
  // Strip a POSIX codeset/modifier suffix: `en_US.UTF-8` / `en_US@euro`.
  final String base = locale.split('.').first.split('@').first;
  final List<String> parts = base.split(RegExp('[_-]'));
  if (parts.length < 2) {
    return '';
  }
  return parts[1].toUpperCase();
}
