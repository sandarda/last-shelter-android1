# Changelog

## v0.39.2
- Replaced the seven remaining room backgrounds with the exact user-approved images: kitchen, lookout, greenhouse, laboratory, armory, workshop, and storage.
- Preserved the approved bedroom and living room images from v0.39.1.
- Updated Android version to 0.39.2 (version code 43).

- Replaced bedroom and living room artwork with the individually approved room images.
- Kept the other seven approved room images and gameplay code unchanged.
- Android version updated to 0.39.2 (version code 43).

# CHANGELOG

## v0.39.0
- Integrated the nine final, individually approved room interiors as separate 1536×864 PNGs.
- Preserved room navigation, story actions, save/load, autosave, sniper defense, zombie animation, and the approved main bunker screen.

## v0.38.1
- Replaced all nine room images with individual high-resolution 1536×864 PNGs cropped from the user-supplied reference collage.


## v0.36.0
- Persistent hero portrait replaces the tiny moving avatar on the main bunker map.
- Static hero presence in room views; no miniature room movement controls.
- Sniper rifle defense replaces the machine gun: left-side optical aim, right-side single-shot fire, 5-round magazine, 25-round reserve, reload.
- Animated 4×4 transparent RGBA zombie sprite sheet with 16 walking frames.
- Retains the nine approved high-detail room illustrations, autosave, room stories, and Android export workflow.




## v0.35.0 — Approved visual implementation pass

- Updated the bunker hub to the approved detailed artwork and removed the right-side action list from the main location.
- Added dedicated full-screen artwork backplates for all nine rooms in the same warm stone/wood/metal visual language.
- Removed the procedural primitive room renderer; missing room art now raises an asset error instead of silently drawing a placeholder.
- Added a detailed transparent machine-gun turret sprite and connected its rotation to manual touch/mouse aiming.
- Added a detailed infected sprite; individual zombie scale remains tied to travelled distance from the surf to the balcony.
- Repositioned room hit areas, floor movement planes, and spiral-stair traversal to the approved bunker layout.
- Preserved autosave, survival progression, room stories, and four escalating balcony-defense waves.
- Android version name: 0.35.0; version code: 37.


## v0.34.1 — Distance-based zombie perspective
- Zombie scale now derives from each target's progress between its individual water spawn line and the balcony breach line.
- Uses smoothstep easing for gradual, frame-rate-independent growth from 26–38% at spawn to 155% near the balcony.
- Removed time-only scale growth so zombies do not grow while standing still or change size inconsistently with movement speed.


- Full-screen room scenes with horizontal-only player movement.
- Yellow Shelter return control and room-to-stairwell exit.
- Contextual up/down stair controls appear at the stair landing.
- Individual story threads and activities for all nine rooms, persisted in save data.
- Balcony defense starts with an empty shoreline; zombies spawn from the water and grow as they approach.
- Turret aims toward the reticle, fires continuously, flashes at the muzzle, and ejects brass casings.
- Infinite machine-gun belt; no reload interaction.

# v0.34.0 — Room exploration, stories, and turret controls

- Full-screen room scenes with horizontal-only player movement.
- Yellow Shelter return control and room-to-stairwell exit.
- Contextual up/down stair controls appear at the stair landing.
- Individual story threads and activities for all nine rooms, persisted in save data.
- Balcony defense starts with an empty shoreline; zombies spawn from the water and grow as they approach.
- Turret aims toward the reticle, fires continuously, flashes at the muzzle, and ejects brass casings.
- Infinite machine-gun belt; no reload interaction.

# Журнал изменений

## v0.11
- Исправлено соответствие симуляции потребностей игровому времени: голод, жажда и энергия теперь расходуются не только при нажатии кнопок действий, но и во время обычного перемещения/ожидания.
- Для непрерывного времени и действий используется единая функция расчёта потребностей, чтобы баланс не расходился между разными способами продвижения времени.
- Сохранены механики и данные предыдущего прототипа.

## v0.10 и ранее
См. историю предыдущих архивов и описание в README.md.

## v0.12
- Added room selection by tapping/clicking a room on the current floor.
- Added a contextual room interaction button with actions for bedrooms, living room, kitchen, workshop, storage and arsenal.
- Added a visible highlight around the selected room.
- Selected room is saved and restored; changing floors selects a valid room on the destination floor.
- This remains a greybox prototype; Godot runtime and Android export have not yet been validated in this environment.

## v0.13
- Исправлен двойной расход потребностей во время реального времени: непрерывный цикл ранее применял расход через `_advance_time()` и повторно напрямую; теперь потребности применяются один раз.
- Добавлен документ утверждённой архитектуры жилища: состав трёх этажей, связи комнат, лестничный узел, скрытые окна и балконы.
- Добавлена концептуальная иллюстрация жилища в папку `art/reference` как визуальный ориентир, не как готовый игровой спрайт.


## v0.14
- Заменён циклический переход по этажам на корректное перемещение только между соседними уровнями.
- Добавлены отдельные команды подъёма и спуска по центральной винтовой лестнице.
- Команды лестницы доступны только в радиусе площадки; на крайних этажах недоступное направление отключено.
- Клавиша E использует ближайшее допустимое направление движения по лестнице.
- Godot runtime и Android export по-прежнему требуют проверки в установленном Godot 4.x.

## v0.15 — 2026-11-12
- Добавлена автоматическая проверка связности коридорного графа всех трёх этажей при запуске.
- Для каждого этажа проверяется достижимость всех комнат от стартовой комнаты обходом графа.
- При обнаружении изолированной комнаты выводится ошибка с номером этажа.
- Добавлена документация схемы связности и ограничений проверки.
- Версия формата сохранения повышена до 6.

## v0.16
- Добавлен скрипт статической проверки целостности проекта.
- Проверяются главная сцена, пути ресурсов, наличие восьми комнат и ключевых игровых функций.
- Добавлена инструкция запуска проверок.
- Проверка явно отделена от runtime-тестирования Godot и Android export.

## v0.17 — сенсорное управление
- Добавлен виртуальный джойстик для Android в нижней левой части игрового экрана.
- Поддерживается управление удержанием и перетаскиванием пальца; направление движения плавно нормализуется.
- Отпускание пальца останавливает персонажа.
- Сенсорный джойстик не перехватывает нажатия по HUD и комнатам.
- Клавиатурное управление WASD/стрелками сохранено.

## v0.18 — три последовательных этапа
- Арт интерьеров: созданы отдельные PNG-подложки для всех восьми комнат в общей тёплой винтажной палитре.
- Персонаж: добавлен спрайт-лист 4 направления × 4 кадра; кадры переключаются при ходьбе, направление выбирается по вектору движения.
- Интерактивная мебель: касание/клик по зонам кровати, гостиной, кухонной печи, верстака, полок и оружейной стойки запускает соответствующее действие.
- Статические проверки проекта пройдены; запуск в Godot и экспорт APK не выполнялись (движок отсутствует в среде).


## v0.19
- Добавлено управление переходом по лестнице нажатием/касанием самой лестничной площадки: персонаж сначала проходит к лестнице, затем переходит на соседний этаж.
- На среднем этаже верхняя и нижняя части площадки ведут соответственно на верхний и нижний этаж; с крайних этажей переход возможен только на соседний.
- Сохранены иллюстрации восьми помещений, анимация персонажа и интерактивные мебельные зоны из v0.18.
- Проверка проекта остаётся статической; запуск в Godot и Android-сборка требуют отдельного тестирования.


## v0.20 — пять последовательных этапов
- Навигация: добавлена проверка проходимости по прямоугольникам комнат, коридорам и лестничному узлу; движение останавливается у стен.
- Интерфейс: добавлены шкалы здоровья, голода, жажды, энергии и прочности убежища.
- Оборона: при разрушении укреплений прорыв зомби начинает наносить прямой урон выжившему.
- Ресурсы: добавлены создание и использование аптечек; аптечки включены в инвентарь и сохранение.
- Сохранения: добавлена санитарная проверка значений при загрузке старых или повреждённых сохранений; версия данных повышена до 8.
- Выполнена статическая проверка проекта; Godot runtime и Android export не подтверждены.

## v0.21 — десять новых игровых этапов
- Добавлены визуальные переходы дня, сумерек и ночи.
- Добавлены погодные состояния: ясная погода, туман, дождь и ветер.
- Шум от действий влияет на вероятность появления дополнительной угрозы.
- Добавлен поиск припасов с затратой энергии и риском привлечь зомби.
- Добавлена рыбалка и получение еды.
- Добавлена очистка сырой воды и отдельный запас чистой воды.
- Добавлено улучшение баррикад до пяти уровней.
- Добавлен показатель боевого духа выжившего.
- Добавлен дневник с пятью последовательными этапами записей.
- Новые показатели и ресурсы сохраняются и восстанавливаются из сохранения.
- Статическая проверка проекта: 54 успешно, 0 ошибок.

## v0.22 — десять последовательных этапов островного выживания
1. Исследование пяти районов острова с открытием посещённых мест.
2. Сбор ягод и лекарственных трав с проверкой доступа к лесу.
3. Огород с затратами на устройство грядки и периодическим урожаем.
4. Изготовление копья с ограниченной прочностью.
5. Охота, расходующая прочность копья и энергию.
6. Сбор дождевой воды только при соответствующей погоде.
7. Радиомаяк с расходом батарей и вероятностью получить пакет помощи.
8. Улучшение мастерской до трёх уровней.
9. Обработка ран лекарственными травами и восстановление здоровья.
10. Разбор найденных припасов на полезные ресурсы.
- Новые ресурсы, локация, огород, копьё, радиомаяк и травмы сохраняются в файле сохранения.
- Это игровой прототип: статическая проверка не заменяет запуск в Godot и тестирование Android-сборки.


## v0.23 — десять этапов подготовки к сборке
- Версия приложения 0.23.0 и метаданные проекта.
- Мобильная ориентация landscape и canvas stretch.
- Клавиатурные действия движения закреплены в Input Map.
- Добавлена оригинальная иконка приложения.
- Добавлен Android export preset (ARM64, package `com.lastshelter.game`).
- Добавлен GitHub Actions workflow для экспорта APK и загрузки артефакта.
- Добавлен `.gitignore` для build/import и ключей подписи.
- Добавлено автосохранение каждые 60 секунд.
- Добавлено сохранение при сворачивании/закрытии и сообщение при возврате.
- Добавлена инструкция Android build и release signing.
- Godot runtime и реальная Android-сборка в этой среде не выполнялись.


## v0.25 — интерфейс убежища

- Перестроен HUD: компактная верхняя панель времени, состояния и ресурсов.
- Добавлено левое меню разделов убежища с быстрым доступом к основным действиям.
- Добавлена нижняя панель шести основных действий выживания.
- Все прежние действия сохранены в отдельной прокручиваемой панели «Все действия».
- Добавлены блок текущих задач и индикатор угрозы/прочности убежища.
- Сохранены существующие игровые системы, перемещение, комнаты и автосохранение.
- Статическая проверка проекта: 78 проверок пройдены; запуск Godot и Android export требуют отдельной проверки в Godot/CI.

## v0.27 — Cliffside panorama visual pass
- Reworked the coastal backdrop with sunset glow, cloud bands, ruined skyline details, drifting smoke, layered sea and foam.
- Added a stranded yacht silhouette, shoreline rocks and additional approaching infected silhouettes.
- Preserved room navigation, touch controls, survival actions and save data.
- Static validation only; Godot runtime and Android export still require an engine build.


## v0.29 — архитектурная детализация убежища
- Добавлены усиленные балки, металлические/деревянные стойки и заклёпки по периметру каждой комнаты.
- Добавлены отдельные таблички помещений с подсветкой выбранной комнаты.
- Усилен общий контур вырубленного в скале жилища: внешний каменный пояс, внутренний шов и верхняя несущая балка.
- Сохранены существующие интерактивные зоны мебели, навигация, мобильный джойстик и системы выживания.
- Проверка статической целостности выполнена; запуск Godot и экспорт APK не выполнялись.

## v0.30.0 — Approved full-screen interface implementation
- Added the exact user-approved full-screen interface image as the actual in-game background layer.
- Replaced the prototype's hand-drawn room grid and generic HUD panels with transparent interactive hit areas aligned to the approved artwork.
- Connected left navigation, nine room hotspots, task/threat panels, and six bottom action tiles to existing survival actions.
- Updated the design viewport to 1536x864 (16:9) for the approved composition and Android canvas scaling.
- Kept the existing survival state, save/load, and action systems.

## v0.31 — approved balcony defense mode
- Added the separately approved first-person balcony artwork as a second full-screen game scene.
- The lookout room and the main defense action now open the balcony scene; the return control brings the player back to the bunker hub.
- Added four escalating attack waves (8/12/16/20 enemies), timed enemy arrivals, shelter breach damage, wave completion rewards, and a final return to the bunker.
- Added hold-to-fire machine-gun input, ammunition consumption, reloads, touch/mouse aiming, reticle, tracer and muzzle-flash feedback.
- Ammunition and defense kill count are persisted in the save file.
- Added live numeric overlays for the bunker header counters while preserving the approved artwork as the base layer.
- Added a visible survivor sprite while moving in the bunker; kept both approved compositions unchanged.
- Changed stretch behavior to preserve the 16:9 composition on mobile displays.


## v0.32.0 — Stair traversal pass
- Added continuous waypoint-based movement along the spiral stairwell.
- Added separate ascent/descent route direction and landing positions for all three floors.
- Floor state updates at the end of the stair traversal rather than teleporting at the start.
- Updated stair interaction area and walkable corridor to match the left-side stairwell in the approved bunker artwork.
- Kept the survivor's relaxed home movement style.


## v0.33.0 — movement and combat pass

- Floor-aware room geometry and functional room hotspot bounds.
- High-resolution casual survivor animation asset, without backpack or tactical equipment.
- Android virtual joystick touch lifecycle.
- Aim-accurate zombie target combat with movement, health, breach damage, and wave progression.
- Visible aim/zoom state.


## v0.33.1 — Android import fixes

- Converted `art/ui/approved_fullscreen.png` from JPEG bytes to a valid PNG file while preserving its 1536×864 dimensions.
- Fixed the indentation after the furniture-room `match` block so `if hotspot` is evaluated after the match, not parsed as a match pattern.
- Updated Android version code to 34 and version name to 0.33.1.


## v0.37.0 — Room entry and sniper scene correction

- Corrected the 3×3 room tap map to match the visible room positions and room identities in the approved hub illustration.
- All nine rooms now map directly to their own high-detail full-screen room artwork.
- Added a dedicated illustrated balcony-sniper background instead of reusing the bunker hub image in defense mode.
- Optical zoom now uses the balcony scene and keeps the aim point centered within the magnified crop.
- Expanded aim travel across the beach area and aligned animated zombie spawn positions to the new scene.
- Corrected the sniper ammunition defaults and saved-state bounds to 5 loaded + 25 reserve.

## v0.38.0 — девять обновлённых интерьерных сцен
- Полностью заменены девять интерьерных backplate PNG отдельными полноэкранными сценами 1536×864.
- Герой отображается в комнатах и на балконе; боезапас сохраняется после выстрела и перезарядки.
- Усилен статический валидатор: проверка разрешения и уникальности всех девяти интерьерных изображений.
- Godot runtime и Android APK export в текущем окружении не запускались.
