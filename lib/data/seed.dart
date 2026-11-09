import '../core/constants.dart';
import '../domain/models/shift_template.dart';

const defaultTemplates = [
  ShiftTemplate(
    id: SeedTemplateIds.day,
    name: 'День',
    baseRate: 5000,
    isNightShift: false,
    colorHex: '#2F6F5E',
  ),
  ShiftTemplate(
    id: SeedTemplateIds.night,
    name: 'Ночь',
    baseRate: 5000,
    isNightShift: true,
    colorHex: '#3D4C73',
  ),
  ShiftTemplate(
    id: SeedTemplateIds.gig,
    name: 'Подработка',
    baseRate: 4500,
    isNightShift: false,
    colorHex: '#B0893E',
  ),
  ShiftTemplate(
    id: SeedTemplateIds.off,
    name: 'Выходной',
    baseRate: 0,
    isNightShift: false,
    colorHex: '#6E6A64',
  ),
];
