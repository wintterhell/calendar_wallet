# Календарь-кошелек

MVP для сменных работников и самозанятых в РФ: шаблоны смен, календарь дохода и прогноз налога 6%.

Стек: **Flutter + Riverpod + локальное хранилище** (SharedPreferences JSON). Supabase и Drift — этап 2.

## Roadmap

1. **Сейчас (v0.1)** — главный экран: финансы месяца, сетка календаря, тап по дню → смена / симуляция / премия и штраф.
2. **v0.2** — экран конструктора шаблонов, ночная ставка по ст. 154 ТК РФ (20%), цвета и порядок смен.
3. **v0.3** — Drift/SQLite, экспорт месяца, график «закрытых» vs прогнозных дней.
4. **v0.4** — опциональный аккаунт Supabase, бэкап шаблонов и календаря.

## Архитектура

```
lib/
  domain/     модели и FinanceService (чистая логика, без Flutter UI)
  data/       seed + LocalStore
  state/      Riverpod: календарь и computed MonthlySummary
  features/   UI главного экрана
  core/       тема, форматтеры, константы
```

- **ShiftTemplate** — ставка за смену. Ночная смена хранит уже итоговую сумму (например 6000 ₽).
- **CalendarDay** — факт или симуляция на дату, премия и штраф.
- **MonthlySummary** — `earned` (прошлые и сегодня, без симуляций), `projected` (все смены месяца), `taxReserve` = 6% от прогноза.

## Запуск

Flutter SDK: `%USERPROFILE%\flutter`. Добавьте `%USERPROFILE%\flutter\bin` в PATH.

```bash
flutter pub get
flutter test
flutter run
```
