/// Neutral filler words used as decoys for `tapWord` confirmations.
///
/// Chosen to look at home next to a real reminder's keyword (short, generic,
/// upper-cased in the UI) so the correct word does not stand out.
const List<String> _decoyPool = <String>[
  'LATER',
  'SKIP',
  'DONE',
  'OPEN',
  'VIEW',
  'OKAY',
  'NEXT',
  'MORE',
  'SNOOZE',
  'CLOSE',
];

/// Builds the word grid for a `tapWord` confirmation: the template [keyword]
/// plus decoys, in a deterministic order.
///
/// Decoys are generated UI-side (spec 03 §ReminderTemplate keyword). The
/// order is derived from the keyword's characters rather than a `Random`
/// instance so the layout is stable across rebuilds and golden tests, while
/// still differing between keywords. [optionCount] is the total number of
/// words shown (default 3, per spec 02 §disguisedReminder Disarm tapWord).
///
/// Matching against the result is case-insensitive in the UI; the keyword is
/// returned with its original casing.
List<String> buildReminderWordChoices(String keyword, {int optionCount = 3}) {
  assert(optionCount >= 1, 'optionCount must be at least 1');
  final upper = keyword.toUpperCase();
  // Stable per-keyword seed: sum of code units (deterministic, no Random).
  final seed = keyword.codeUnits.fold<int>(0, (sum, c) => sum + c);

  final decoys = _decoyPool.where((w) => w != upper).toList();
  final picked = <String>[];
  for (var i = 0; picked.length < optionCount - 1 && i < decoys.length; i++) {
    final candidate = decoys[(seed + i) % decoys.length];
    if (!picked.contains(candidate)) {
      picked.add(candidate);
    }
  }

  final words = <String>[keyword, ...picked];
  // Rotate so the keyword does not always sit first.
  final shift = words.isEmpty ? 0 : seed % words.length;
  return <String>[
    for (var i = 0; i < words.length; i++) words[(i + shift) % words.length],
  ];
}
