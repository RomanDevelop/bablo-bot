/// Futures flip position side label: LONG | SHORT | flat.
String formatPositionSide(String? side, {required bool isOpen}) {
  if (!isOpen) return 'flat';
  if (side == null || side.isEmpty) return 'flat';
  final normalized = side.toLowerCase();
  if (normalized == 'flat') return 'flat';
  return side.toUpperCase();
}

bool isPositionOpen(String? side, String quantity) {
  final qty = double.tryParse(quantity) ?? 0;
  if (qty <= 0) return false;
  if (side == null || side.isEmpty) return false;
  return side.toLowerCase() != 'flat';
}
