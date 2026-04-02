# Bio Garden (Roblox MVP)

Рабочий MVP Roblox-симулятора в стиле BioSim: личные участки, выращивание растений, мутации, посещение чужих участков, защита от краж и интеграция Developer Products.

## 1) Структура проекта

- `ServerScriptService/`
  - `Main.server.lua`
  - `DataService.lua`
  - `PlotService.lua`
  - `PlantService.lua`
  - `MutationService.lua`
  - `ProtectionService.lua`
  - `RaidService.lua`
  - `MonetizationService.lua`
  - `LeaderstatsService.lua`
  - `VisualService.lua`
- `ReplicatedStorage/`
  - `Shared/`
    - `PlantConfig.lua`
    - `MutationConfig.lua`
    - `RarityConfig.lua`
    - `EconomyConfig.lua`
    - `VisualConfig.lua`
  - `Remotes/README.md` (список обязательных RemoteEvent/RemoteFunction)
- `StarterPlayer/StarterPlayerScripts/MainHUD.client.lua`
- `StarterGui/README.md`

## 2) Что создать в Roblox Studio вручную

### Workspace

Создайте папку `Workspace/Plots` и несколько plot-моделей (например `Plot1..Plot8`) с:

- `Part` `HomeSpawn`
- `Part` `VisitorSpawn`
- (опционально) декор, грядки, лаборатория.

### ReplicatedStorage

Создайте папку `Remotes`, внутри неё:

- `RemoteEvent` `RequestPlant`
- `RemoteEvent` `HarvestPlant`
- `RemoteFunction` `OpenMutation`
- `RemoteEvent` `ActivateFreeProtection`
- `RemoteEvent` `RequestStealPlant`
- `RemoteEvent` `TeleportToPlayerPlot`
- `RemoteEvent` `BuyProtection`

### StarterGui

Создайте интерфейсы по `StarterGui/README.md`.

## 3) Developer Products

ID уже зашиты в `MonetizationService.lua`:

- Coins1000 — `3567502722`
- Coins5000 — `3567503034`
- donate 10 — `3568008173`
- donate 50 — `3568008392`
- donate 100 — `3568008795`
- protection — `3567814697`
- steal a plant — `3567811809`

Обработка покупок сделана через `MarketplaceService.ProcessReceipt`.

### Как подключить

1. В Roblox Creator Dashboard создайте Developer Products с этими ID в том же Experience.
2. Опубликуйте игру.
3. Убедитесь, что `MonetizationService` загружен из `Main.server.lua`.

## 4) ProcessReceipt: как тестировать

1. Запустите игру в режиме **Start Server + 1/2 Players**.
2. Для проверок покупок используйте реальный тест в опубликованной игре (или Studio API Access с тестовым аккаунтом).
3. Купите продукт `Coins1000` и проверьте рост `leaderstats.Coins`.
4. Купите `protection` и убедитесь, что в профиле:
   - `Protection.Mode = "PremiumProtection"`
   - `Protection.EndsAt` = now + ~24 часа.
5. Проверьте повторную обработку одной и той же транзакции: награда не должна выдаваться повторно (receipt anti-dup в DataStore).

## 5) Реализованные MVP-механики

- Личный участок и телепорт домой.
- Посадка и рост растений по стадиям (`Seed -> ... -> Evolved`).
- Сбор монет с взрослых растений.
- Минимум 10 видов растений и 4 редкости в конфиге (Common/Uncommon/Rare/Epic).
- Лаборатория скрещивания (базовые + скрытые рецепты).
- Визиты на участки других игроков.
- Бесплатная защита на 20 минут (с cooldown 2 часа).
- Платная защита на 24 часа через dev product.
- Кража растения с проверками на сервере (в MVP: soft steal).
- DataStore профиль + autosave + save on leave + retry.
- Leaderstats (`Coins`, `Plants`).

## 6) Анти-эксплойт, встроенный в MVP

- Серверные проверки для посадки/сбора/краж/телепорта.
- Remote rate-limit/debounce.
- Проверка защиты, зрелости растения, лимитов краж.
- Purchase fulfillment только на сервере.
- Защита от double-grant по `PurchaseId`.

## 7) Что расширить следующим шагом

- Визуальные модели растений по стадиям роста.
- 2–3 полноценные мини-игры через отдельные UI.
- Inventory/Lab/Visit UI с полным UX циклом.
- Рейтинги и сезонные мутации.
- Глубокая система декора и апгрейдов участка.


## 8) Визуальная атмосфера и окружение (новое)

Теперь сервер автоматически настраивает атмосферу и сцену через `VisualService`:

- cinematic greenhouse lighting (fog, bloom, color correction, sun rays);
- декорирует каждый plot (платформа, неон-лампы, биоспоры);
- процедурно строит визуальные растения по видам и редкости;
- учитывает стадию роста + случайный size multiplier + визуальные мутации;
- поддерживает эффекты событий: Harvest / Mutation / Rare Mutation / Protection / Steal.

### Важно для Workspace

Для лучшего результата у каждого plot добавьте `Part` с именем `PlotBase` (желательно размером ~`40x1x40`).
Если `PlotBase` нет, система берёт первый `BasePart` plot-модели.

### Как проверять визуал

1. Запустите `Start Server` + 2 players.
2. Посадите 5-10 растений, подождите 2-4 минуты и убедитесь, что видны стадии роста.
3. Проведите мутацию, проверьте изменение внешности и редкий визуальный burst.
4. Активируйте щит и проверьте VFX-отклик на растениях.
5. Проверьте кражу на незащищённом участке и убедитесь, что VFX и данные синхронны.
