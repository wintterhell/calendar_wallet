import '../domain/models/shift_template.dart';
import '../domain/models/warehouse_preset.dart';

class PresetTemplateIds {
  static const ozonDay = 'preset_ozon_day';
  static const ozonNight = 'preset_ozon_night';
  static const wbShift = 'preset_wb_shift';
  static const wbNight = 'preset_wb_night';
  static const yandexDay = 'preset_ym_day';
  static const yandexNight = 'preset_ym_night';
  static const courier6 = 'preset_courier_6';
  static const courier8 = 'preset_courier_8';
  static const courier10 = 'preset_courier_10';
  static const courier12 = 'preset_courier_12';
}

/// Стартовые ставки — ориентир, пользователь может поправить в конструкторе.
const warehousePresets = <WarehousePreset>[
  WarehousePreset(
    id: 'preset_ozon',
    name: 'Ozon Склад',
    blurb: 'Ozon День и Ozon Ночь',
    monogram: 'O',
    accentHex: '#005BFF',
    secondaryHex: '#F91155',
    templates: [
      ShiftTemplate(
        id: PresetTemplateIds.ozonDay,
        name: 'Ozon День',
        baseRate: 4500,
        isNightShift: false,
        colorHex: '#005BFF',
      ),
      ShiftTemplate(
        id: PresetTemplateIds.ozonNight,
        name: 'Ozon Ночь',
        baseRate: 5000,
        isNightShift: true,
        colorHex: '#F91155',
      ),
    ],
  ),
  WarehousePreset(
    id: 'preset_wb',
    name: 'Wildberries',
    blurb: 'WB Смена и WB Ночь',
    monogram: 'WB',
    accentHex: '#7B2CBF',
    secondaryHex: '#C77DFF',
    templates: [
      ShiftTemplate(
        id: PresetTemplateIds.wbShift,
        name: 'WB Смена',
        baseRate: 4300,
        isNightShift: false,
        colorHex: '#7B2CBF',
      ),
      ShiftTemplate(
        id: PresetTemplateIds.wbNight,
        name: 'WB Ночь',
        baseRate: 4800,
        isNightShift: true,
        colorHex: '#5A189A',
      ),
    ],
  ),
  WarehousePreset(
    id: 'preset_yandex',
    name: 'Яндекс Маркет',
    blurb: 'Яндекс День и Яндекс Ночь',
    monogram: 'Я',
    accentHex: '#FCE000',
    secondaryHex: '#1A1A1A',
    templates: [
      ShiftTemplate(
        id: PresetTemplateIds.yandexDay,
        name: 'Яндекс День',
        baseRate: 4400,
        isNightShift: false,
        colorHex: '#F5C400',
      ),
      ShiftTemplate(
        id: PresetTemplateIds.yandexNight,
        name: 'Яндекс Ночь',
        baseRate: 4900,
        isNightShift: true,
        colorHex: '#1A1A1A',
      ),
    ],
  ),
  WarehousePreset(
    id: 'preset_courier',
    name: 'Курьер',
    blurb: 'Смены 6, 8, 10 и 12 часов',
    monogram: 'К',
    accentHex: '#E85A9B',
    secondaryHex: '#FFB4D6',
    templates: [
      ShiftTemplate(
        id: PresetTemplateIds.courier6,
        name: 'Смена 6ч',
        baseRate: 2100,
        isNightShift: false,
        colorHex: '#F4A6C8',
      ),
      ShiftTemplate(
        id: PresetTemplateIds.courier8,
        name: 'Смена 8ч',
        baseRate: 2800,
        isNightShift: false,
        colorHex: '#E85A9B',
      ),
      ShiftTemplate(
        id: PresetTemplateIds.courier10,
        name: 'Смена 10ч',
        baseRate: 3500,
        isNightShift: false,
        colorHex: '#D63384',
      ),
      ShiftTemplate(
        id: PresetTemplateIds.courier12,
        name: 'Смена 12ч',
        baseRate: 4200,
        isNightShift: false,
        colorHex: '#B5176A',
      ),
    ],
  ),
];
