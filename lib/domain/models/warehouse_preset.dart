import 'shift_template.dart';

class WarehousePreset {
  const WarehousePreset({
    required this.id,
    required this.name,
    required this.blurb,
    required this.monogram,
    required this.accentHex,
    required this.secondaryHex,
    required this.templates,
  });

  final String id;
  final String name;
  final String blurb;
  final String monogram;
  final String accentHex;
  final String secondaryHex;
  final List<ShiftTemplate> templates;
}
