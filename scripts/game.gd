extends Node2D

# Last Shelter v0.34 — full-screen rooms, story activities, and live turret defense.
const PLAYER_SPEED := 210.0
const ROOM_W := 250.0
const ROOM_H := 150.0
const DAY_MINUTES := 24 * 60
const SAVE_PATH := "user://last_shelter_save.cfg"

const LEVELS := [
	{"name":"НИЖНИЙ ЭТАЖ — СКЛАД И ТЕХНИЧЕСКИЙ БЛОК", "rooms":[
		{"id":"storage","name":"СКЛАД","pos":Vector2(-270,0),"color":Color("786044")},
		{"id":"greenhouse","name":"ТЕПЛИЦА","pos":Vector2(0,0),"color":Color("667344")},
		{"id":"techblock","name":"ТЕХБЛОК","pos":Vector2(270,0),"color":Color("536b75")}], "links":[[0,1],[1,2]]},
	{"name":"СРЕДНИЙ ЭТАЖ — МАСТЕРСКАЯ И КУХНЯ", "rooms":[
		{"id":"workshop","name":"МАСТЕРСКАЯ","pos":Vector2(-270,0),"color":Color("776044")},
		{"id":"arsenal","name":"ОРУЖЕЙНАЯ","pos":Vector2(0,0),"color":Color("70513d")},
		{"id":"kitchen","name":"КУХНЯ","pos":Vector2(270,0),"color":Color("806b48")}], "links":[[0,1],[1,2]]},
	{"name":"ВЕРХНИЙ ЭТАЖ — ЖИЛОЙ И СМОТРОВАЯ", "rooms":[
		{"id":"bedroom","name":"СПАЛЬНЯ","pos":Vector2(-270,0),"color":Color("80634b")},
		{"id":"living","name":"ГОСТИНАЯ","pos":Vector2(0,0),"color":Color("8a6045")},
		{"id":"lookout","name":"СМОТРОВАЯ","pos":Vector2(270,0),"color":Color("66727a")}], "links":[[0,1],[1,2]]}
]

# Every room has its own continuing story thread and practical activity.
const ROOM_STORIES := {
	"bedroom": {"subtitle":"Личное пространство хозяина убежища", "story":"В старом дневнике остались записи о первых днях после катастрофы. Порядок в комнате помогает герою восстановить силы.", "action":"Перечитать дневник", "objective":"Восстановить силы и отметить важную запись"},
	"living": {"subtitle":"Тихое сердце убежища", "story":"У камина герой слушает старые радиозаписи и вспоминает, ради чего стоит продолжать борьбу.", "action":"Провести время у камина", "objective":"Поддержать моральный дух"},
	"kitchen": {"subtitle":"Запасы и приготовление пищи", "story":"Каждая банка и каждая порция на счету. Нужно следить за запасами и готовить еду заранее.", "action":"Приготовить еду", "objective":"Пополнить запас готовой еды"},
	"workshop": {"subtitle":"Ремонт и изготовление оборудования", "story":"Здесь чинят инструменты, укрепляют двери и собирают полезные приспособления из найденного металлолома.", "action":"Поработать в мастерской", "objective":"Поддерживать инструменты и оборудование"},
	"storage": {"subtitle":"Склад долгосрочных запасов", "story":"Склад нужно регулярно проверять: сортировать припасы, отмечать недостачу и готовить наборы для вылазок.", "action":"Проверить запасы", "objective":"Провести учёт припасов"},
	"arsenal": {"subtitle":"Оружейная и подготовка обороны", "story":"Оружие должно быть исправно, а защитное снаряжение — готово к внезапной тревоге.", "action":"Проверить оружие", "objective":"Подготовить оборону убежища"},
	"greenhouse": {"subtitle":"Теплица и автономное питание", "story":"Растения дают свежую пищу, но требуют воды, семян и ежедневного ухода.", "action":"Ухаживать за растениями", "objective":"Поддерживать урожай"},
	"techblock": {"subtitle":"Вода, энергия и системы жизнеобеспечения", "story":"Фильтры и насосы удерживают убежище автономным. Любая неисправность может стать серьёзной проблемой.", "action":"Обслужить фильтр", "objective":"Обеспечить чистую воду"},
	"lookout": {"subtitle":"Наблюдение за лагуной и побережьем", "story":"С берега иногда доносятся сигналы и шум прибоя. Здесь можно заметить угрозу раньше, чем она достигнет скалы.", "action":"Осмотреть побережье", "objective":"Проверить береговую линию"}
}

const ROOM_STORY_STEPS := {
	"bedroom": ["В первой записи герой вспоминает, как обустраивал убежище.", "В ящике обнаруживается старая фотография и короткая записка.", "Личная история героя получает новую главу: он решает сохранить память о прошлом."],
	"living": ["В старом радиоприёмнике находится запись довоенной музыкальной передачи.", "После настройки частоты среди помех слышится повторяющийся сигнал.", "Герой записывает сигнал в дневник: возможно, на острове есть другие выжившие."],
	"kitchen": ["Проверка полок показывает, какие продукты нужно использовать в первую очередь.", "В старой тетради найден рецепт простого сытного блюда.", "Герой составляет меню на несколько дней и сокращает потери припасов."],
	"workshop": ["Осмотр верстака выявляет изношенную деталь насосной системы.", "Среди металлолома удаётся подобрать подходящую заготовку.", "Инструмент восстановлен; мастерская готова к более сложному ремонту."],
	"storage": ["В учёте обнаруживается расхождение между записями и фактическими запасами.", "За ящиками найден небольшой тайник с забытыми припасами.", "Склад рассортирован, тайник внесён в журнал, экспедиционные наборы подготовлены."],
	"arsenal": ["Проверка выявляет износ нескольких деталей оружия.", "После обслуживания оружие снова работает надёжно.", "Оборона готова; герой отмечает, что боезапас пулемёта в смотровой бесконечный."],
	"greenhouse": ["На грядках появляются первые здоровые ростки.", "Герой восстанавливает полив и распределяет семена по грядкам.", "Созревает первый небольшой урожай, повышая автономность убежища."],
	"techblock": ["Фильтр воды работает с перебоями и требует обслуживания.", "Насос очищен, а картридж промыт и установлен обратно.", "Система жизнеобеспечения снова подаёт чистую воду."],
	"lookout": ["На горизонте замечен слабый отблеск у скрытой яхты.", "При наблюдении становится ясно: движение в воде приближается к берегу.", "Подана тревога. Герой занимает пулемёт и защищает побережье."]
}

var current_floor := 2
var player_pos := Vector2(640, 220)
var target_pos := Vector2.ZERO
var moving := false
var day := 1
var minute_of_day := 7 * 60
var health := 100.0
var hunger := 85.0
var thirst := 80.0
var energy := 90.0
var wood := 8
var food := 5
var water := 4
var scrap := 3
var traps := 0
var medkits := 1
var zombies := 0
var shelter_integrity := 100.0
var status_label: Label
var clock_label: Label
var inventory_label: Label
var message_label: Label
var threat_label: Label
var floor_label: Label
var action_panel: VBoxContainer
var room_rects: Array[Rect2] = []
var action_cooldown := 0.0
var time_fraction := 0.0
var stair_up_button: Button
var stair_down_button: Button
var selected_room_id := "living"
var selected_room_name := "ГОСТИНАЯ"
var pending_interaction_room := ""
var selected_room_label: Label
var room_interact_button: Button
var needs_bars: Dictionary = {}
var interaction_hint := "Подойдите к винтовой лестнице и нажмите E или кнопку перехода."
var last_message := "Добро пожаловать домой. Проверь запасы и осмотри убежище."
var game_over := false
# On-screen virtual joystick for Android. Drag in the lower-left control zone.
var virtual_axis := Vector2.ZERO
var joystick_touch_index := -1
var joystick_center := Vector2(112.0, 600.0)
var joystick_radius := 72.0
# Illustrated room backplates and a 4-direction / 4-frame survivor sprite sheet.
var room_textures: Dictionary = {}
var approved_ui_texture: Texture2D
var balcony_ui_texture: Texture2D
var room_mode := false
var room_player_x := 768.0
var room_move_axis := 0.0
var room_controls: Array[Control] = []
var room_title_label: Label
var room_story_label: Label
var room_action_button: Button
var room_left_button: Button
var room_right_button: Button
var room_stairs_button: Button
var room_shelter_button: Button
var aim_touch_index := -1
var casing_particles: Array[Dictionary] = []
var turret_recoil := 0.0
var turret_angle := 0.0
const TURRET_PIVOT := Vector2(768.0, 785.0)
# Balcony defense mode: real-time turret combat state.
var defense_mode := false
var defense_wave := 1
var defense_wave_counts := [8, 12, 16, 20]
var defense_total_remaining := 8
var defense_spawned := 0
var defense_active_targets := 0
var defense_kills := 0
var defense_spawn_clock := 0.0
var defense_breach_clock := 0.0
var defense_shot_clock := 0.0
var defense_wave_break := 0.0
var ammo_loaded := 120
var ammo_reserve := 300
var fire_held := false
var aim_position := Vector2(820, 440)
var defense_hit_flash := 0.0
var muzzle_flash_timer := 0.0
var defense_targets: Array[Dictionary] = []
var defense_target_spawn_points: Array[Vector2] = [
	Vector2(420, 385), Vector2(560, 365), Vector2(700, 380), Vector2(850, 370),
	Vector2(1000, 385), Vector2(1160, 400), Vector2(650, 430), Vector2(930, 425)
]
var aim_mode := false
var zoom_mode := false
var defense_status_label: Label
var defense_ammo_label: Label
var defense_controls: Array[Control] = []
var main_hotspots: Array[Control] = []
var dynamic_counters: Dictionary = {}
var hub_overlay_controls: Array[Control] = []
var survivor_texture: Texture2D
var animation_clock := 0.0
var animation_frame := 0
var facing_row := 0 # 0 down, 1 left, 2 right, 3 up
var pending_stair_floor := -1
# Smooth stair traversal: the survivor follows visible switchback waypoints
# instead of teleporting between floors.
var stair_transition_active := false
var stair_path_points: Array[Vector2] = []
var stair_path_index := 0
var stair_transition_from := 1
var stair_transition_progress := 0.0
var stair_step_bob := 0.0
const STAIR_LANDINGS := [Vector2(275.0, 625.0), Vector2(275.0, 485.0), Vector2(275.0, 295.0)]
const FLOOR_CENTERS_Y := [620.0, 420.0, 220.0]
# v0.21: ten additional survival systems.
var weather := "ЯСНО"
var noise_level := 0.0
var backpack_capacity := 30
var carried_weight := 0
var purified_water := 0
var fish := 0
var morale := 75.0
var barricade_level := 1
var journal_step := 0
var explored_cache := false
var last_weather_day := 1
# v0.22: ten additional island-survival systems.
var island_location := "ПЛЯЖ"
var explored_locations: Dictionary = {"ПЛЯЖ": true}
var berries := 0
var medicine_herbs := 0
var garden_level := 0
var garden_progress := 0.0
var spear_durability := 0
var weapon_durability := 100.0
var radio_battery := 0
var radio_signal_sent := false
var rescued_supplies := 0
var shelter_upgrades := 0
var quest_flags: Dictionary = {}
var injury := 0.0
var temperature := 20.0
# v0.23 mobile lifecycle and periodic save support.
var autosave_elapsed := 0.0
const AUTOSAVE_INTERVAL := 60.0

func _ready() -> void:
	randomize()
	_load_art_assets()
	_validate_room_connectivity()
	_build_ui()
	_load_game()
	_walkable_rectangles()
	_update_ui()
	queue_redraw()

func _exit_tree() -> void:
	_save_game_silent()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		virtual_axis = Vector2.ZERO
		joystick_touch_index = -1
		fire_held = false
		_save_game_silent()
	if what == NOTIFICATION_APPLICATION_RESUMED:
		_set_message("С возвращением. Прогресс сохранён автоматически.")


func _validate_room_connectivity() -> void:
	# Validate that every room on every floor belongs to one connected
	# corridor network. This catches accidental isolated rooms during layout edits.
	for floor_index in range(LEVELS.size()):
		var floor_data: Dictionary = LEVELS[floor_index]
		var rooms: Array = floor_data["rooms"]
		var links: Array = floor_data["links"]
		var visited: Dictionary = {0: true}
		var queue: Array[int] = [0]
		while not queue.is_empty():
			var current: int = queue.pop_front()
			for link in links:
				var next_room := -1
				if int(link[0]) == current:
					next_room = int(link[1])
				elif int(link[1]) == current:
					next_room = int(link[0])
				if next_room >= 0 and not visited.has(next_room):
					visited[next_room] = true
					queue.append(next_room)
		if visited.size() != rooms.size():
			push_error("Изолированное помещение на этаже %d: доступно %d из %d" % [floor_index + 1, visited.size(), rooms.size()])
		else:
			print("Этаж %d: все %d помещений соединены коридорами." % [floor_index + 1, rooms.size()])

func _build_ui() -> void:
	# v0.30 — the approved full-screen artwork is the actual game presentation.
	# Invisible hit areas make the artwork's illustrated controls interactive.
	var layer := CanvasLayer.new()
	layer.name = "GameHUD"
	add_child(layer)

	# Hidden data labels preserve the existing survival/save systems without
	# introducing a second visual UI over the approved artwork.
	floor_label = Label.new()
	status_label = Label.new()
	clock_label = Label.new()
	inventory_label = Label.new()
	message_label = Label.new()
	threat_label = Label.new()
	selected_room_label = Label.new()
	room_interact_button = Button.new()
	for node in [floor_label, status_label, clock_label, inventory_label, message_label, threat_label, selected_room_label, room_interact_button]:
		node.visible = false
		layer.add_child(node)

	# Dynamic counters cover only the numeric portions of the approved header art.
	_add_dynamic_counter(layer, "day", Rect2(385, 5, 78, 40), 15)
	_add_dynamic_counter(layer, "health", Rect2(615, 8, 72, 30), 15)
	_add_dynamic_counter(layer, "energy", Rect2(765, 8, 76, 30), 15)
	_add_dynamic_counter(layer, "hunger", Rect2(915, 8, 72, 30), 15)
	_add_dynamic_counter(layer, "thirst", Rect2(1050, 8, 72, 30), 15)
	_add_dynamic_counter(layer, "ammo", Rect2(1175, 8, 42, 30), 15)
	_add_dynamic_counter(layer, "wood", Rect2(1270, 8, 48, 30), 15)
	_add_dynamic_counter(layer, "metal", Rect2(1380, 8, 42, 30), 15)
	_add_dynamic_counter(layer, "medkits", Rect2(1480, 8, 42, 30), 15)
	# Left navigation — hit areas match the approved image, not generic buttons.
	_add_hotspot(layer, Rect2(4, 80, 164, 100), "Убежище", func(): _set_message("Ты находишься в убежище."))
	_add_hotspot(layer, Rect2(4, 181, 164, 55), "Крафт", _craft_trap)
	_add_hotspot(layer, Rect2(4, 238, 164, 55), "Инвентарь", func(): _set_message("Запасы: дерево %d, еда %d, вода %d, металл %d, аптечки %d." % [wood, food, water, scrap, medkits]))
	_add_hotspot(layer, Rect2(4, 295, 164, 55), "Радио", _use_radio)
	_add_hotspot(layer, Rect2(4, 352, 164, 55), "Карта", _explore_island)
	_add_hotspot(layer, Rect2(4, 409, 164, 55), "Задачи", _journal_update)
	_add_hotspot(layer, Rect2(4, 466, 164, 55), "Дневник", _journal_update)
	_add_hotspot(layer, Rect2(4, 523, 164, 60), "Развитие", _upgrade_workshop)

	# Main room hotspots. The image remains intact; taps invoke real game logic.

	# Right-side objectives and threat panel.
	_add_hotspot(layer, Rect2(1215, 470, 315, 165), "Текущие задачи", _journal_update)
	_add_hotspot(layer, Rect2(1215, 640, 315, 75), "Уровень угрозы", _defend_shelter)

	# Bottom action tiles: exact clickable bounds of the six illustrated buttons.
	_add_hotspot(layer, Rect2(395, 728, 175, 132), "Собрать ресурсы", _gather_wood)
	_add_hotspot(layer, Rect2(575, 728, 175, 132), "Разведка", _scout_shore)
	_add_hotspot(layer, Rect2(755, 728, 190, 132), "Улучшения", _upgrade_barricades)
	_add_hotspot(layer, Rect2(950, 728, 195, 132), "Исследования", _upgrade_workshop)
	_add_hotspot(layer, Rect2(1150, 728, 190, 132), "Оборона", _enter_balcony_defense)
	_add_hotspot(layer, Rect2(1345, 728, 185, 132), "Отдых", _rest)
	_add_hotspot(layer, Rect2(1480, 0, 56, 62), "Настройки", _toggle_action_panel)

	# Balcony defense: one left-side aiming zone and one right-side hold-to-fire control.
	_add_defense_hotspot(layer, Rect2(14, 105, 205, 78), "В УБЕЖИЩЕ", _leave_balcony_defense)
	var fire_button := _add_defense_hotspot(layer, Rect2(1300, 650, 210, 190), "ОГОНЬ", _fire_machinegun)
	fire_button.button_down.connect(_start_firing)
	fire_button.button_up.connect(_stop_firing)
	defense_status_label = Label.new()
	defense_status_label.position = Vector2(1270, 90)
	defense_status_label.size = Vector2(250, 120)
	defense_status_label.add_theme_font_size_override("font_size", 18)
	defense_status_label.add_theme_color_override("font_color", Color("fff0d2"))
	defense_status_label.add_theme_color_override("font_shadow_color", Color("160d08"))
	defense_status_label.add_theme_constant_override("shadow_offset_x", 2)
	defense_status_label.add_theme_constant_override("shadow_offset_y", 2)
	defense_status_label.visible = false
	layer.add_child(defense_status_label)
	defense_ammo_label = Label.new()
	defense_ammo_label.position = Vector2(28, 205)
	defense_ammo_label.size = Vector2(280, 42)
	defense_ammo_label.add_theme_font_size_override("font_size", 20)
	defense_ammo_label.add_theme_color_override("font_color", Color("ffe18b"))
	defense_ammo_label.visible = false
	layer.add_child(defense_ammo_label)
	_set_defense_controls_visible(false)

	# Full-screen room controls. These stay visually separate from the approved bunker hub.
	room_shelter_button = _add_room_control(layer, Rect2(18, 92, 205, 76), "УБЕЖИЩЕ", _leave_room_view)
	room_shelter_button.add_theme_color_override("font_color", Color("24170a"))
	room_shelter_button.add_theme_stylebox_override("normal", _ui_panel_style(Color("e0ad24"), Color("ffe28a")))
	room_shelter_button.add_theme_stylebox_override("hover", _ui_panel_style(Color("f4c63f"), Color("fff0b5")))
	room_left_button = _add_room_control(layer, Rect2(36, 720, 132, 112), "◀", func(): _set_room_move(0.0))
	room_right_button = _add_room_control(layer, Rect2(182, 720, 132, 112), "▶", func(): _set_room_move(0.0))
	room_action_button = _add_room_control(layer, Rect2(1035, 735, 270, 94), "ДЕЙСТВИЕ", _run_room_story_action)
	room_stairs_button = _add_room_control(layer, Rect2(1315, 735, 190, 94), "К ЛЕСТНИЦЕ", _leave_room_to_stairs)
	room_left_button.button_down.connect(func(): _set_room_move(-1.0))
	room_left_button.button_up.connect(func(): _set_room_move(0.0))
	room_right_button.button_down.connect(func(): _set_room_move(1.0))
	room_right_button.button_up.connect(func(): _set_room_move(0.0))
	room_title_label = Label.new()
	room_title_label.position = Vector2(470, 24)
	room_title_label.size = Vector2(600, 62)
	room_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	room_title_label.add_theme_font_size_override("font_size", 30)
	room_title_label.add_theme_color_override("font_color", Color("ffe0a0"))
	room_title_label.add_theme_color_override("font_outline_color", Color("1b1009"))
	room_title_label.add_theme_constant_override("outline_size", 5)
	room_title_label.visible = false
	layer.add_child(room_title_label)
	room_story_label = Label.new()
	room_story_label.position = Vector2(360, 95)
	room_story_label.size = Vector2(810, 90)
	room_story_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	room_story_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	room_story_label.add_theme_font_size_override("font_size", 19)
	room_story_label.add_theme_color_override("font_color", Color("fff0d3"))
	room_story_label.add_theme_color_override("font_shadow_color", Color("160d08"))
	room_story_label.add_theme_constant_override("shadow_offset_x", 2)
	room_story_label.add_theme_constant_override("shadow_offset_y", 2)
	room_story_label.visible = false
	layer.add_child(room_story_label)

	# The stair controls appear only when the survivor reaches the stair landing.
	stair_up_button = _make_ui_button("▲  ВВЕРХ", _use_stairs_up)
	stair_up_button.position = Vector2(350, 300)
	stair_up_button.size = Vector2(145, 58)
	stair_up_button.visible = false
	layer.add_child(stair_up_button)
	stair_down_button = _make_ui_button("▼  ВНИЗ", _use_stairs_down)
	stair_down_button.position = Vector2(350, 365)
	stair_down_button.size = Vector2(145, 58)
	stair_down_button.visible = false
	layer.add_child(stair_down_button)

	# Secondary action drawer, opened from the settings/overflow hotspot.
	var action_frame := PanelContainer.new()
	action_frame.name = "AllActionsPanel"
	action_frame.position = Vector2(1080, 90)
	action_frame.size = Vector2(420, 620)
	action_frame.visible = false
	action_frame.add_theme_stylebox_override("panel", _ui_panel_style(Color("17130f", 0.97), Color("a98551")))
	layer.add_child(action_frame)
	hub_overlay_controls.append(action_frame)
	var scroll := ScrollContainer.new()
	action_frame.add_child(scroll)
	action_panel = VBoxContainer.new()
	action_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(action_panel)
	_add_action_button("Поесть", _eat)
	_add_action_button("Выпить воды", _drink)
	_add_action_button("Отдохнуть 2 часа", _rest)
	_add_action_button("Поработать 1 час", _work)
	_add_action_button("Заготовить дрова", _gather_wood)
	_add_action_button("Набрать воду", _collect_water)
	_add_action_button("Приготовить еду", _cook_meal)
	_add_action_button("Изготовить ловушку", _craft_trap)
	_add_action_button("Собрать аптечку", _craft_medkit)
	_add_action_button("Использовать аптечку", _use_medkit)
	_add_action_button("Проверить берег", _scout_shore)
	_add_action_button("Рыбачить у берега", _fish)
	_add_action_button("Поискать припасы", _scavenge)
	_add_action_button("Очистить воду", _purify_water)
	_add_action_button("Улучшить баррикады", _upgrade_barricades)
	_add_action_button("Исследовать остров", _explore_island)
	_add_action_button("Записать в журнал", _journal_update)
	_add_action_button("Собрать ягоды и травы", _forage)
	_add_action_button("Ухаживать за огородом", _tend_garden)
	_add_action_button("Изготовить копьё", _craft_spear)
	_add_action_button("Охотиться на мелкую дичь", _hunt)
	_add_action_button("Собрать дождевую воду", _collect_rainwater)
	_add_action_button("Проверить радиомаяк", _use_radio)
	_add_action_button("Улучшить мастерскую", _upgrade_workshop)
	_add_action_button("Проверить медицинское состояние", _treat_injury)
	_add_action_button("Разобрать найденные припасы", _process_salvage)
	_add_action_button("Отбиться от зомби", _defend_shelter)
	_add_action_button("Починить укрепления", _repair_shelter)
	_add_action_button("Сохранить игру", _save_game)
	_add_action_button("Начать заново", _new_game)

	for meter_name in ["Здоровье", "Голод", "Жажда", "Энергия", "Прочность"]:
		var meter := ProgressBar.new()
		meter.custom_minimum_size = Vector2(1, 8)
		meter.max_value = 100.0
		meter.show_percentage = false
		meter.visible = false
		needs_bars[meter_name] = meter
		layer.add_child(meter)

func _add_dynamic_counter(parent: CanvasLayer, key: String, rect: Rect2, font_size: int) -> void:
	var backing := ColorRect.new()
	backing.position = rect.position
	backing.size = rect.size
	backing.color = Color(0.035, 0.025, 0.018, 0.88)
	backing.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(backing)
	hub_overlay_controls.append(backing)
	var label := Label.new()
	label.position = rect.position + Vector2(2, 1)
	label.size = rect.size - Vector2(4, 2)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("fff0d0"))
	label.add_theme_color_override("font_outline_color", Color("120d08"))
	label.add_theme_constant_override("outline_size", 2)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	hub_overlay_controls.append(label)
	dynamic_counters[key] = label

func _add_hotspot(parent: CanvasLayer, rect: Rect2, caption: String, callback: Callable) -> Button:
	var button := Button.new()
	button.name = "Hit_" + caption.replace(" ", "_")
	button.position = rect.position
	button.size = rect.size
	button.text = ""
	button.tooltip_text = caption
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0, 0, 0, 0)
	normal.border_color = Color(0, 0, 0, 0)
	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(1.0, 0.72, 0.25, 0.10)
	hover.border_color = Color(1.0, 0.78, 0.36, 0.45)
	hover.set_border_width_all(2)
	var pressed := StyleBoxFlat.new()
	pressed.bg_color = Color(1.0, 0.72, 0.25, 0.18)
	pressed.border_color = Color(1.0, 0.78, 0.36, 0.7)
	pressed.set_border_width_all(2)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", normal)
	button.pressed.connect(callback)
	parent.add_child(button)
	main_hotspots.append(button)
	return button

func _add_room_control(parent: CanvasLayer, rect: Rect2, caption: String, callback: Callable) -> Button:
	var button := Button.new()
	button.position = rect.position
	button.size = rect.size
	button.text = caption
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 23 if caption in ["◀", "▶"] else 17)
	button.add_theme_color_override("font_color", Color("ffe7b6"))
	button.add_theme_stylebox_override("normal", _ui_panel_style(Color("21170f", 0.94), Color("b98b45")))
	button.add_theme_stylebox_override("hover", _ui_panel_style(Color("59401f", 0.97), Color("f0c45d")))
	button.add_theme_stylebox_override("pressed", _ui_panel_style(Color("76551f", 0.98), Color("ffe08a")))
	button.pressed.connect(callback)
	button.visible = false
	parent.add_child(button)
	room_controls.append(button)
	return button

func _add_defense_hotspot(parent: CanvasLayer, rect: Rect2, caption: String, callback: Callable) -> Button:
	var button := Button.new()
	button.name = "Defense_" + caption.replace(" ", "_")
	button.position = rect.position
	button.size = rect.size
	button.text = ""
	button.tooltip_text = caption
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var clear := StyleBoxFlat.new()
	clear.bg_color = Color(0, 0, 0, 0)
	clear.border_color = Color(0, 0, 0, 0)
	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(1.0, 0.70, 0.20, 0.12)
	hover.border_color = Color(1.0, 0.78, 0.35, 0.55)
	hover.set_border_width_all(2)
	button.add_theme_stylebox_override("normal", clear)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
	button.add_theme_stylebox_override("focus", clear)
	button.pressed.connect(callback)
	button.visible = false
	parent.add_child(button)
	defense_controls.append(button)
	return button

func _set_defense_controls_visible(show_controls: bool) -> void:
	for control in defense_controls:
		control.visible = show_controls
	for control in main_hotspots:
		control.visible = not show_controls and not room_mode
	for control in hub_overlay_controls:
		control.visible = not room_mode
	for control in room_controls:
		control.visible = room_mode and not show_controls
	if is_instance_valid(defense_status_label):
		defense_status_label.visible = show_controls
	if is_instance_valid(defense_ammo_label):
		defense_ammo_label.visible = show_controls
	if is_instance_valid(room_title_label):
		room_title_label.visible = room_mode and not show_controls
	if is_instance_valid(room_story_label):
		room_story_label.visible = room_mode and not show_controls
	if is_instance_valid(stair_up_button) and room_mode:
		stair_up_button.visible = false
	if is_instance_valid(stair_down_button) and room_mode:
		stair_down_button.visible = false

func _enter_balcony_defense() -> void:
	if defense_mode:
		return
	defense_mode = true
	defense_wave = 1
	defense_total_remaining = int(defense_wave_counts[0])
	defense_spawned = 0
	defense_active_targets = 0
	defense_targets.clear()
	defense_kills = 0
	defense_spawn_clock = 3.2
	defense_breach_clock = 0.0
	defense_shot_clock = 0.0
	defense_wave_break = 0.0
	fire_held = false
	room_mode = false
	room_move_axis = 0.0
	if is_instance_valid(stair_up_button):
		stair_up_button.visible = false
	if is_instance_valid(stair_down_button):
		stair_down_button.visible = false
	ammo_loaded = 120
	ammo_reserve = 0
	casing_particles.clear()
	turret_recoil = 0.0
	_set_defense_controls_visible(true)
	_set_message("Побережье пока пусто. Первые заражённые появятся из воды.")
	_update_defense_hud()
	queue_redraw()

func _leave_balcony_defense() -> void:
	if not defense_mode:
		return
	defense_mode = false
	fire_held = false
	_set_defense_controls_visible(false)
	_save_game_silent()
	_set_message("Ты вернулся в убежище. Уничтожено зомби: %d." % defense_kills)
	_update_ui()
	queue_redraw()

func _start_firing() -> void:
	fire_held = true

func _stop_firing() -> void:
	fire_held = false

func _fire_machinegun() -> void:
	if not defense_mode:
		return
	# The belt is endless: firing never consumes ammunition and never requires reloading.
	defense_shot_clock = 0.10
	muzzle_flash_timer = 0.085
	turret_recoil = 1.0
	var muzzle := _get_turret_muzzle_position()
	var shot_end := aim_position
	var hit_index := -1
	var hit_distance := INF
	for i in range(defense_targets.size()):
		var target: Dictionary = defense_targets[i]
		var center: Vector2 = target["pos"] + Vector2(0, -22.0 * float(target["scale"]))
		var distance := _distance_to_segment(center, muzzle, shot_end)
		var radius := 24.0 * float(target["scale"])
		if distance <= radius and distance < hit_distance:
			hit_index = i
			hit_distance = distance
	if hit_index >= 0:
		var target: Dictionary = defense_targets[hit_index]
		var hp := int(target["hp"]) - 1
		if hp <= 0:
			defense_targets.remove_at(hit_index)
			defense_total_remaining = maxi(0, defense_total_remaining - 1)
			defense_kills += 1
			defense_hit_flash = 0.18
			_set_message("Попадание! Уничтожено заражённых: %d." % defense_kills)
		else:
			target["hp"] = hp
			defense_targets[hit_index] = target
			defense_hit_flash = 0.08
	else:
		_set_message("Очередь ушла в сторону. Скорректируй наведение.")
	var eject_direction := (aim_position - TURRET_PIVOT).normalized()
	var turret_rotation := Vector2.UP.angle_to(eject_direction)
	var eject_position := TURRET_PIVOT + Vector2(62, -86).rotated(turret_rotation)
	var eject_velocity := Vector2(145.0, -95.0).rotated(turret_rotation * 0.45)
	casing_particles.append({"pos": eject_position, "vel": eject_velocity, "life": 0.85, "spin": randf_range(-9.0, 9.0)})
	if casing_particles.size() > 36:
		casing_particles.pop_front()
	defense_active_targets = defense_targets.size()
	if defense_total_remaining == 0 and defense_active_targets == 0 and defense_spawned >= int(defense_wave_counts[defense_wave - 1]):
		_complete_defense_wave()
	_update_defense_hud()
	queue_redraw()

func _distance_to_segment(point: Vector2, start: Vector2, finish: Vector2) -> float:
	var segment := finish - start
	var length_sq := segment.length_squared()
	if length_sq <= 0.001:
		return point.distance_to(start)
	var t := clampf((point - start).dot(segment) / length_sq, 0.0, 1.0)
	return point.distance_to(start + segment * t)

func _get_turret_muzzle_position() -> Vector2:
	var direction := (aim_position - TURRET_PIVOT).normalized()
	return TURRET_PIVOT + direction * 210.0

func _reload_machinegun() -> void:
	# Kept for compatibility with older saves; the balcony gun is permanently belt-fed.
	ammo_loaded = 120
	ammo_reserve = 0
	_set_message("Пулемёт с бесконечной лентой. Перезарядка не требуется.")
	_update_defense_hud()

func _toggle_aim_mode() -> void:
	aim_mode = not aim_mode
	_set_message("Точный прицел включён." if aim_mode else "Точный прицел выключен.")
	queue_redraw()

func _toggle_zoom() -> void:
	zoom_mode = not zoom_mode
	_set_message("Оптическое увеличение включено." if zoom_mode else "Обычный обзор восстановлен.")
	queue_redraw()

func _complete_defense_wave() -> void:
	if defense_wave >= 4:
		wood += 3
		scrap += 5
		morale = minf(100.0, morale + 8.0)
		_set_message("Все четыре волны отражены! Получены припасы и боевой дух.")
		_leave_balcony_defense()
		return
	defense_wave_break = 4.0
	_set_message("Волна %d отражена. Готовься к следующей." % defense_wave)

func _process_defense(delta: float) -> void:
	if defense_hit_flash > 0.0:
		defense_hit_flash = maxf(0.0, defense_hit_flash - delta)
	if muzzle_flash_timer > 0.0:
		muzzle_flash_timer = maxf(0.0, muzzle_flash_timer - delta)
	turret_recoil = move_toward(turret_recoil, 0.0, delta * 5.5)
	for casing_index in range(casing_particles.size() - 1, -1, -1):
		var casing: Dictionary = casing_particles[casing_index]
		var casing_pos: Vector2 = casing["pos"]
		var casing_vel: Vector2 = casing["vel"]
		casing_vel.y += 320.0 * delta
		casing_pos += casing_vel * delta
		casing["pos"] = casing_pos
		casing["vel"] = casing_vel
		casing["life"] = float(casing["life"]) - delta
		if float(casing["life"]) <= 0.0:
			casing_particles.remove_at(casing_index)
		else:
			casing_particles[casing_index] = casing
	if defense_wave_break > 0.0:
		defense_wave_break -= delta
		if defense_wave_break <= 0.0:
			defense_wave += 1
			defense_total_remaining = int(defense_wave_counts[defense_wave - 1])
			defense_spawned = 0
			defense_targets.clear()
			defense_active_targets = 0
			defense_spawn_clock = 0.5
			_set_message("Началась волна %d/4!" % defense_wave)
	if fire_held:
		defense_shot_clock -= delta
		if defense_shot_clock <= 0.0:
			_fire_machinegun()
			if not defense_mode:
				return
			defense_shot_clock = 0.10
	if defense_total_remaining > 0 and defense_spawned < int(defense_wave_counts[defense_wave - 1]):
		defense_spawn_clock -= delta
		if defense_spawn_clock <= 0.0:
			var spawn_index := randi_range(0, defense_target_spawn_points.size() - 1)
			var spawn_pos: Vector2 = defense_target_spawn_points[spawn_index]
			var target_scale := randf_range(0.26, 0.38)
			# Store the surf line and initial size so perspective scale is derived
			# from actual beach progress, not elapsed time.
			defense_targets.append({"pos": spawn_pos, "spawn_y": spawn_pos.y, "start_scale": target_scale, "hp": 1 if defense_wave < 3 else 2, "scale": target_scale, "speed": 30.0 + float(defense_wave) * 5.0})
			defense_spawned += 1
			defense_active_targets = defense_targets.size()
			defense_spawn_clock = maxf(0.85, 2.1 - float(defense_wave) * 0.22)
	# Each attacker advances from the surf toward the barricade; escaped enemies
	# damage the shelter and are removed from the active wave.
	for i in range(defense_targets.size() - 1, -1, -1):
		var target: Dictionary = defense_targets[i]
		var pos: Vector2 = target["pos"]
		pos.y += float(target["speed"]) * delta
		target["pos"] = pos
		# Perspective is tied directly to distance travelled from the surf to
		# the balcony line: far-away zombies stay small, then grow smoothly as
		# they approach the foreground. This is frame-rate independent.
		var spawn_y: float = float(target.get("spawn_y", 385.0))
		var start_scale: float = float(target.get("start_scale", 0.30))
		var approach_progress := clampf(inverse_lerp(spawn_y, 640.0, pos.y), 0.0, 1.0)
		var perspective_progress := approach_progress * approach_progress * (3.0 - 2.0 * approach_progress)
		target["scale"] = lerpf(start_scale, 1.55, perspective_progress)
		if pos.y >= 640.0:
			shelter_integrity = maxf(0.0, shelter_integrity - (5.0 + float(defense_wave)))
			defense_total_remaining = maxi(0, defense_total_remaining - 1)
			defense_targets.remove_at(i)
			_set_message("Зомби прорвался к укреплениям! Прочность: %d%%." % int(shelter_integrity))
		else:
			defense_targets[i] = target
	defense_active_targets = defense_targets.size()
	if defense_total_remaining == 0 and defense_active_targets == 0 and defense_spawned >= int(defense_wave_counts[defense_wave - 1]) and defense_wave_break <= 0.0:
		_complete_defense_wave()
	_update_defense_hud()

func _update_defense_hud() -> void:
	if dynamic_counters.has("ammo"):
		dynamic_counters["ammo"].text = "∞" if defense_mode else str(ammo_loaded)
	if is_instance_valid(defense_status_label):
		defense_status_label.text = "ВОЛНА %d/4\nЗОМБИ: %d\nУБЕЖИЩЕ: %d%%" % [defense_wave, defense_total_remaining, int(shelter_integrity)]
	if is_instance_valid(defense_ammo_label):
		defense_ammo_label.text = "БОЕЗАПАС\nБЕСКОНЕЧНЫЙ"

func _add_room_story_text() -> void:
	var story: Dictionary = ROOM_STORIES.get(selected_room_id, ROOM_STORIES["living"])
	if is_instance_valid(room_title_label):
		room_title_label.text = selected_room_name
	if is_instance_valid(room_story_label):
		var progress := int(quest_flags.get("room_story_" + selected_room_id, 0))
		var objective := str(story["objective"])
		room_story_label.text = str(story["subtitle"]) + "\n" + str(story["story"]) + "\nЭтап: %d  •  %s" % [progress, objective]
	if is_instance_valid(room_action_button):
		room_action_button.text = str(story["action"])

func _enter_room_view(room_id: String, room_name: String) -> void:
	if defense_mode or room_mode:
		return
	selected_room_id = room_id
	selected_room_name = room_name
	room_mode = true
	room_player_x = 768.0
	room_move_axis = 0.0
	virtual_axis = Vector2.ZERO
	moving = false
	pending_interaction_room = ""
	_add_room_story_text()
	_set_defense_controls_visible(false)
	_set_message("Ты вошёл в помещение: %s." % selected_room_name)
	queue_redraw()

func _leave_room_view() -> void:
	if not room_mode:
		return
	room_mode = false
	room_move_axis = 0.0
	_set_defense_controls_visible(false)
	_set_message("Ты вернулся к общему плану убежища.")
	_update_ui()
	queue_redraw()

func _leave_room_to_stairs() -> void:
	if not room_mode:
		return
	room_mode = false
	room_move_axis = 0.0
	player_pos = STAIR_LANDINGS[current_floor]
	moving = false
	_walkable_rectangles()
	_set_defense_controls_visible(false)
	_set_message("Ты вышел в коридор к винтовой лестнице.")
	_update_ui()
	queue_redraw()

func _set_room_move(axis: float) -> void:
	room_move_axis = axis

func _run_room_story_action() -> void:
	if not room_mode:
		return
	var progress_key := "room_story_" + selected_room_id
	var step := int(quest_flags.get(progress_key, 0))
	var story_steps: Array = ROOM_STORY_STEPS.get(selected_room_id, [])
	quest_flags[progress_key] = mini(step + 1, story_steps.size()) if not story_steps.is_empty() else step + 1
	match selected_room_id:
		"bedroom":
			energy = minf(100.0, energy + 14.0)
			morale = minf(100.0, morale + 2.0)
			_advance_time(10)
			_set_message("Запись в дневнике прочитана. Герой немного отдохнул.")
		"living":
			_advance_time(20)
			morale = minf(100.0, morale + 5.0)
			_set_message("Тихий вечер у камина помог восстановить моральный дух.")
		"kitchen":
			_cook_meal()
		"workshop":
			_work()
		"storage":
			_set_message("Учёт склада: дерево %d, еда %d, вода %d, металл %d." % [wood, food, water, scrap])
		"arsenal":
			weapon_durability = minf(100.0, weapon_durability + 8.0)
			_set_message("Оружие осмотрено и обслужено. Исправность: %d%%." % int(weapon_durability))
		"greenhouse":
			_tend_garden()
		"techblock":
			_purify_water()
		"lookout":
			if step < story_steps.size():
				_set_message(last_message + " " + str(story_steps[step]))
			_save_game_silent()
			_enter_balcony_defense()
			return
	if step < story_steps.size():
		_set_message(last_message + " " + str(story_steps[step]))
	else:
		_set_message(last_message + " История этой комнаты завершена; можно продолжать ежедневные дела.")
	_save_game_silent()
	_add_room_story_text()
	_update_ui()

func _process_room_mode(delta: float) -> void:
	var axis := Input.get_axis("ui_left", "ui_right")
	if absf(room_move_axis) > 0.05:
		axis = room_move_axis
	elif absf(virtual_axis.x) > 0.08:
		axis = virtual_axis.x
	if absf(axis) > 0.08:
		room_player_x = clampf(room_player_x + axis * PLAYER_SPEED * 1.35 * delta, 145.0, 1390.0)
		_update_facing(Vector2(axis, 0.0))
		animation_clock += delta
		if animation_clock >= 0.12:
			animation_clock = 0.0
			animation_frame = (animation_frame + 1) % 4
	else:
		animation_frame = 0
	time_fraction += delta * 2.0
	var elapsed_minutes := int(time_fraction)
	if elapsed_minutes > 0:
		time_fraction -= float(elapsed_minutes)
		_advance_time(elapsed_minutes)
	if health <= 0.0 and not game_over:
		game_over = true
		_set_message("Ты погиб. Загрузи последнее сохранение или начни заново.")
	_update_ui()
	queue_redraw()

func _draw_room_view() -> void:
	var texture: Texture2D = room_textures.get(selected_room_id, null)
	if texture != null:
		draw_texture_rect(texture, Rect2(0, 0, 1536, 864), false)
	else:
		_draw_procedural_room(selected_room_id)
	# Darken the upper/lower edges so room controls read clearly without covering the room.
	draw_rect(Rect2(0, 0, 1536, 78), Color(0.035, 0.025, 0.018, 0.80), true)
	draw_rect(Rect2(0, 690, 1536, 174), Color(0.035, 0.025, 0.018, 0.36), true)
	if survivor_texture != null:
		var source := Rect2(float(animation_frame) * 128.0, float(facing_row) * 160.0, 128.0, 160.0)
		var destination := Rect2(room_player_x - 68.0, 475.0, 136.0, 190.0)
		draw_texture_rect_region(survivor_texture, destination, source)
	draw_string(ThemeDB.fallback_font, Vector2(40, 205), "←  ПЕРЕМЕЩЕНИЕ ПО ПОЛУ  →", HORIZONTAL_ALIGNMENT_LEFT, 420, 18, Color("f4d7a7"))
	draw_string(ThemeDB.fallback_font, Vector2(1120, 700), "ДЕЙСТВИЕ В ПОМЕЩЕНИИ", HORIZONTAL_ALIGNMENT_CENTER, 330, 17, Color("f4d7a7"))

func _draw_procedural_room(room_id: String) -> void:
	var wall := Color("49372a")
	var floor := Color("76553b")
	if room_id == "greenhouse":
		wall = Color("34463a")
		floor = Color("6a5739")
	elif room_id == "techblock":
		wall = Color("35434a")
		floor = Color("4d514a")
	elif room_id == "lookout":
		wall = Color("39434b")
		floor = Color("6b5845")
	draw_rect(Rect2(0, 0, 1536, 590), wall, true)
	draw_rect(Rect2(0, 590, 1536, 274), floor, true)
	for beam_x in range(0, 1536, 190):
		draw_rect(Rect2(beam_x, 0, 16, 590), Color("241c17"), true)
		draw_rect(Rect2(beam_x + 16, 0, 5, 590), Color("a47a4b"), true)
	for seam in range(0, 1536, 90):
		draw_line(Vector2(seam, 595), Vector2(seam, 864), Color("3a291e"), 3.0)
	if room_id == "greenhouse":
		for row in range(3):
			var y := 300.0 + float(row) * 125.0
			draw_rect(Rect2(150, y, 1230, 28), Color("4a3021"), true)
			for plant in range(12):
				var x := 185.0 + float(plant) * 98.0
				draw_rect(Rect2(x, y - 52, 54, 52), Color("46372a"), true)
				draw_line(Vector2(x + 27, y - 4), Vector2(x + 27, y - 48), Color("7fa35b"), 7.0)
				draw_line(Vector2(x + 27, y - 25), Vector2(x + 8, y - 39), Color("9abd65"), 6.0)
				draw_line(Vector2(x + 27, y - 30), Vector2(x + 46, y - 44), Color("9abd65"), 6.0)
	elif room_id == "techblock":
		for i in range(4):
			var x := 180.0 + float(i) * 330.0
			draw_rect(Rect2(x, 235, 180, 350), Color("69777a"), true)
			draw_rect(Rect2(x + 16, 250, 148, 320), Color("26343a"), true)
			draw_circle(Vector2(x + 90, 340), 42, Color("75a6a3"))
			draw_circle(Vector2(x + 90, 340), 30, Color("263e43"))
			draw_line(Vector2(x + 90, 382), Vector2(x + 90, 500), Color("c39a5c"), 8.0)
	else:
		draw_rect(Rect2(120, 170, 1290, 410), Color("1d282f"), true)
		if room_id == "lookout":
			# Wide reinforced observation window over the lagoon and distant ruined city.
			for band in range(12):
				var sky_color := Color("3b4d62").lerp(Color("e59a62"), float(band) / 11.0)
				draw_rect(Rect2(145, 190 + band * 17, 1240, 18), sky_color, true)
			draw_circle(Vector2(1160, 280), 45, Color("ffd38a"))
			draw_rect(Rect2(145, 385, 1240, 165), Color("315968"), true)
			for building in range(18):
				var bx := 180.0 + float(building) * 67.0
				var bh := 45.0 + float((building * 37) % 115)
				draw_rect(Rect2(bx, 385.0 - bh, 42.0, bh), Color("34343a"), true)
			for wave in range(18):
				var wy := 400.0 + float(wave) * 8.0
				draw_line(Vector2(160 + wave * 11, wy), Vector2(1370, wy - 2), Color(0.78, 0.88, 0.85, 0.24), 2.0)
			draw_rect(Rect2(145, 190, 1240, 360), Color("d3b17b"), false, 12.0)
			for x in range(170, 1380, 310):
				draw_line(Vector2(x, 190), Vector2(x, 550), Color("d3b17b"), 9.0)
			draw_line(Vector2(145, 370), Vector2(1385, 370), Color("d3b17b"), 8.0)
		else:
			draw_rect(Rect2(145, 190, 1240, 360), Color("8b9a91"), true)
			draw_rect(Rect2(145, 190, 1240, 360), Color("334b59", 0.35), true)
			for x in range(170, 1380, 150):
				draw_line(Vector2(x, 190), Vector2(x, 550), Color("d3b17b"), 8.0)
			draw_line(Vector2(145, 370), Vector2(1385, 370), Color("d3b17b"), 8.0)
		draw_rect(Rect2(540, 570, 470, 40), Color("493525"), true)
		draw_rect(Rect2(560, 550, 430, 20), Color("b18a58"), true)

func _select_and_run_room(room_id: String, room_name: String, callback: Callable) -> void:
	selected_room_id = room_id
	selected_room_name = room_name
	callback.call()
	_update_ui()

func _interact_with_living_room() -> void:
	_advance_time(30)
	energy = minf(100.0, energy + 8.0)
	_set_message("Ты устроился у камина. В гостиной стало немного теплее.")


func _ui_panel_style(fill: Color, edge: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = edge
	style.set_border_width_all(2)
	style.set_corner_radius_all(7)
	style.content_margin_left = 9
	style.content_margin_right = 9
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	return style

func _make_ui_button(caption: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = caption
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size = Vector2(0, 30)
	button.add_theme_font_size_override("font_size", 12)
	button.add_theme_color_override("font_color", Color("f0d9b5"))
	button.add_theme_stylebox_override("normal", _ui_panel_style(Color("35271a"), Color("80603b")))
	button.add_theme_stylebox_override("hover", _ui_panel_style(Color("574027"), Color("d2a34f")))
	button.pressed.connect(callback)
	return button

func _add_nav_button(parent: VBoxContainer, caption: String, callback: Callable, selected: bool = false) -> void:
	var button := _make_ui_button(caption, callback)
	button.custom_minimum_size = Vector2(0, 42)
	button.add_theme_stylebox_override("normal", _ui_panel_style(Color("73521c") if selected else Color("292018"), Color("d6a83f") if selected else Color("80603b")))
	parent.add_child(button)

func _add_action_tile(parent: HBoxContainer, caption: String, callback: Callable) -> void:
	var button := _make_ui_button(caption, callback)
	button.custom_minimum_size = Vector2(0, 60)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 12)
	parent.add_child(button)

func _toggle_action_panel() -> void:
	var panel := get_node_or_null("GameHUD/AllActionsPanel")
	if panel != null:
		panel.visible = not panel.visible

func _add_action_button(caption: String, callback: Callable) -> void:
	var b := Button.new()
	b.text = caption
	b.pressed.connect(callback)
	action_panel.add_child(b)

func _set_floor(index: int) -> void:
	# Debug/navigation shortcut retained for testing; normal play uses the stairwell.
	stair_transition_active = false
	stair_path_points.clear()
	pending_stair_floor = -1
	pending_interaction_room = ""
	current_floor = clampi(index, 0, 2)
	_walkable_rectangles()
	var first_room: Dictionary = LEVELS[current_floor]["rooms"][0]
	selected_room_id = str(first_room["id"])
	selected_room_name = str(first_room["name"])
	player_pos = STAIR_LANDINGS[current_floor]
	moving = false
	_update_ui()
	queue_redraw()

func _use_stairs_up() -> void:
	if player_pos.distance_to(STAIR_LANDINGS[current_floor]) > 135.0:
		_set_message("Подойди к винтовой лестнице слева.")
		return
	if current_floor >= 2:
		_set_message("Это самый верхний этаж. Выше лестницы нет.")
		return
	_begin_stair_transition(current_floor + 1)

func _use_stairs_down() -> void:
	if player_pos.distance_to(STAIR_LANDINGS[current_floor]) > 135.0:
		_set_message("Подойди к винтовой лестнице слева.")
		return
	if current_floor <= 0:
		_set_message("Это нижний этаж. Ниже лестницы нет.")
		return
	_begin_stair_transition(current_floor - 1)

func _begin_stair_transition(destination: int) -> void:
	if stair_transition_active or destination < 0 or destination > 2 or destination == current_floor:
		return
	pending_stair_floor = destination
	stair_transition_from = current_floor
	stair_path_points.clear()
	var start: Vector2 = STAIR_LANDINGS[current_floor]
	var finish: Vector2 = STAIR_LANDINGS[destination]
	# A short switchback path follows the spiral staircase visible at the left
	# edge of the approved bunker artwork. Descending uses the same path reversed.
	var low_y := minf(start.y, finish.y)
	var high_y := maxf(start.y, finish.y)
	var middle_y := (low_y + high_y) * 0.5
	var climb_points: Array[Vector2] = [
		Vector2(275.0, high_y), Vector2(315.0, high_y - 34.0),
		Vector2(315.0, middle_y + 22.0), Vector2(265.0, middle_y),
		Vector2(235.0, middle_y - 28.0), Vector2(235.0, low_y + 34.0),
		Vector2(275.0, low_y)
	]
	if destination > current_floor:
		stair_path_points = climb_points
	else:
		climb_points.reverse()
		stair_path_points = climb_points
	stair_path_index = 1
	stair_transition_progress = 0.0
	stair_step_bob = 0.0
	player_pos = stair_path_points[0]
	moving = false
	target_pos = Vector2.ZERO
	stair_transition_active = true
	_set_message("Ты спокойно поднимаешься по лестнице…" if destination > current_floor else "Ты спокойно спускаешься по лестнице…")
	_update_ui()
	queue_redraw()

func _finish_stair_transition() -> void:
	var was_ascending := pending_stair_floor > current_floor
	current_floor = clampi(pending_stair_floor, 0, 2)
	_walkable_rectangles()
	pending_stair_floor = -1
	pending_interaction_room = ""
	stair_transition_active = false
	stair_path_points.clear()
	stair_path_index = 0
	var first_room: Dictionary = LEVELS[current_floor]["rooms"][0]
	selected_room_id = str(first_room["id"])
	selected_room_name = str(first_room["name"])
	player_pos = STAIR_LANDINGS[current_floor]
	animation_frame = 0
	_set_message("Ты поднялся на этаж." if was_ascending else "Ты спустился на этаж.")
	_update_ui()
	queue_redraw()

func _input(event: InputEvent) -> void:
	# The approved screen uses direct room/action hotspots. Do not capture the
	# left navigation area for a virtual joystick; it would block the artwork UI.
	pass

func _update_virtual_joystick(touch_position: Vector2) -> void:
	var offset := touch_position - joystick_center
	if offset.length() > joystick_radius:
		offset = offset.normalized() * joystick_radius
	virtual_axis = offset / joystick_radius
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if room_mode:
		if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
			_leave_room_view()
			get_viewport().set_input_as_handled()
		return
	if defense_mode:
		if event is InputEventKey:
			if event.keycode == KEY_SPACE:
				fire_held = event.pressed
				if event.pressed and not event.echo:
					_fire_machinegun()
				get_viewport().set_input_as_handled()
				return
			if event.pressed and not event.echo and event.keycode == KEY_R:
				_set_message("Бесконечная лента: перезарядка не нужна.")
				get_viewport().set_input_as_handled()
				return
			if event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
				_leave_balcony_defense()
				get_viewport().set_input_as_handled()
				return
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			aim_position = Vector2(clampf(event.position.x, 250.0, 1300.0), clampf(event.position.y, 250.0, 650.0))
			queue_redraw()
		elif event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			aim_position = Vector2(clampf(event.position.x, 250.0, 1300.0), clampf(event.position.y, 250.0, 650.0))
			queue_redraw()
		elif event is InputEventScreenTouch and event.pressed:
			if event.position.x < 470.0 and event.position.y > 350.0:
				aim_touch_index = event.index
				get_viewport().set_input_as_handled()
		elif event is InputEventScreenTouch and not event.pressed and event.index == aim_touch_index:
			aim_touch_index = -1
		elif event is InputEventScreenDrag and event.index == aim_touch_index:
			aim_position.x = clampf(aim_position.x + event.relative.x * 1.8, 280.0, 1280.0)
			aim_position.y = clampf(aim_position.y + event.relative.y * 1.5, 300.0, 630.0)
			queue_redraw()
		return
	# Touch joystick lives in the lower-left gap between navigation and profile panels.
	if event is InputEventScreenTouch:
		if event.pressed and event.position.distance_to(joystick_center) <= joystick_radius * 1.45:
			joystick_touch_index = event.index
			_update_virtual_joystick(event.position)
			get_viewport().set_input_as_handled()
			return
		elif not event.pressed and event.index == joystick_touch_index:
			joystick_touch_index = -1
			virtual_axis = Vector2.ZERO
			get_viewport().set_input_as_handled()
			return
	elif event is InputEventScreenDrag and event.index == joystick_touch_index:
		_update_virtual_joystick(event.position)
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E:
			if current_floor < 2:
				_use_stairs_up()
			else:
				_use_stairs_down()
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if _is_walkable_screen_point(event.position):
			if _try_stair_navigation(event.position):
				get_viewport().set_input_as_handled()
				return
			if _try_enter_room_at(event.position):
				get_viewport().set_input_as_handled()
				return
			pending_interaction_room = ""
			pending_stair_floor = -1
			_select_room_at(event.position)
			target_pos = _clamp_walkable_point(event.position)
			moving = true
	elif event is InputEventScreenTouch and event.pressed:
		if _is_walkable_screen_point(event.position):
			if _try_stair_navigation(event.position):
				get_viewport().set_input_as_handled()
				return
			if _try_enter_room_at(event.position):
				get_viewport().set_input_as_handled()
				return
			pending_interaction_room = ""
			pending_stair_floor = -1
			_select_room_at(event.position)
			target_pos = _clamp_walkable_point(event.position)
			moving = true

func _is_walkable_screen_point(point: Vector2) -> bool:
	# The bunker illustration spans three distinct horizontal walkable levels.
	return point.y >= 145.0 and point.y <= 710.0 and point.x >= 175.0 and point.x <= 1210.0

func _walkable_rectangles() -> Array[Rect2]:
	var areas: Array[Rect2] = []
	var rooms: Array = LEVELS[current_floor]["rooms"]
	var center := Vector2(640.0, FLOOR_CENTERS_Y[current_floor])
	var rects: Array[Rect2] = []
	room_rects.clear()
	for room in rooms:
		var r := Rect2(center + room["pos"] - Vector2(ROOM_W / 2.0, ROOM_H / 2.0), Vector2(ROOM_W, ROOM_H))
		rects.append(r)
		room_rects.append(r)
		areas.append(r)
	for link in LEVELS[current_floor]["links"]:
		var a: Rect2 = rects[int(link[0])]
		var b: Rect2 = rects[int(link[1])]
		areas.append(Rect2(a.end.x - 2.0, a.get_center().y - 22.0, b.position.x - a.end.x + 4.0, 44.0))
	# Stairwell and landing connect the three floors.
	areas.append(Rect2(205.0, 160.0, 145.0, 545.0))
	var floor_y: float = float(FLOOR_CENTERS_Y[current_floor])
	areas.append(Rect2(320.0, floor_y - 25.0, 115.0, 50.0))
	return areas

func _can_stand_at(point: Vector2) -> bool:
	for area in _walkable_rectangles():
		if area.grow(8.0).has_point(point):
			return true
	return false

func _clamp_walkable_point(point: Vector2) -> Vector2:
	var bounded := Vector2(clampf(point.x, 175.0, 1210.0), clampf(point.y, 145.0, 710.0))
	if _can_stand_at(bounded):
		return bounded
	var best := player_pos
	var best_distance := INF
	for area in _walkable_rectangles():
		var candidate := Vector2(clampf(bounded.x, area.position.x + 5.0, area.end.x - 5.0), clampf(bounded.y, area.position.y + 5.0, area.end.y - 5.0))
		var distance := candidate.distance_squared_to(bounded)
		if distance < best_distance:
			best_distance = distance
			best = candidate
	return best



func _try_stair_navigation(point: Vector2) -> bool:
	# The survivor first walks to the stair landing. Only then do the up/down controls appear.
	if not Rect2(205.0, 260.0, 110.0, 445.0).has_point(point):
		return false
	pending_interaction_room = ""
	pending_stair_floor = -1
	if stair_transition_active:
		return true
	target_pos = STAIR_LANDINGS[current_floor]
	moving = player_pos.distance_to(target_pos) > 5.0
	if not moving:
		_set_message("Ты на лестнице. Выбери направление подъёма или спуска.")
	else:
		_set_message("Ты направился к винтовой лестнице…")
	return true

func _try_furniture_interaction(point: Vector2) -> bool:
	for i in range(room_rects.size()):
		var rect: Rect2 = room_rects[i]
		if not rect.has_point(point):
			continue
		var room: Dictionary = LEVELS[current_floor]["rooms"][i]
		var room_id := str(room["id"])
		var local := (point - rect.position) / rect.size
		# Hotspots correspond to the large, readable furniture silhouettes
		# painted into each room illustration. Tapping elsewhere selects/moves.
		var hotspot := false
		match room_id:
			"bedroom", "guest1", "guest2": hotspot = local.x < 0.53 and local.y > 0.30 and local.y < 0.88
			"living": hotspot = (local.x < 0.48 and local.y > 0.38) or (local.x > 0.72 and local.y < 0.72)
			"kitchen": hotspot = local.x > 0.48 and local.y > 0.42
			"workshop": hotspot = local.y > 0.52 and local.x < 0.78
			"storage": hotspot = local.x < 0.78 and local.y > 0.18
			"arsenal": hotspot = local.x < 0.72 and local.y > 0.20
			"greenhouse": hotspot = local.y > 0.30
			"techblock": hotspot = local.x > 0.25 and local.y > 0.25
			"lookout": hotspot = local.x > 0.35 and local.y < 0.85
		if hotspot:
			pending_stair_floor = -1
			selected_room_id = room_id
			selected_room_name = str(room["name"])
			pending_interaction_room = room_id
			target_pos = _clamp_walkable_point(point)
			moving = player_pos.distance_to(target_pos) > 5.0
			if not moving:
				pending_interaction_room = ""
				_interact_with_furniture(room_id)
			_update_ui()
			queue_redraw()
			return true
	return false

func _interact_with_furniture(room_id: String) -> void:
	match room_id:
		"bedroom", "guest1", "guest2":
			_rest()
			_set_message("Ты прилёг на кровать и восстановил силы.")
		"living":
			_advance_time(30)
			energy = minf(100.0, energy + 8.0)
			_set_message("Ты устроился у камина. В гостиной стало немного теплее.")
		"kitchen":
			_cook_meal()
		"workshop":
			_work()
		"storage":
			_set_message("Ты перебрал ящики и проверил запасы: дерево %d, еда %d, вода %d, металл %d." % [wood, food, water, scrap])
		"arsenal":
			_scout_shore()
		"greenhouse":
			_tend_garden()
		"techblock":
			_purify_water()
		"lookout":
			_enter_balcony_defense()

func _try_enter_room_at(point: Vector2) -> bool:
	for i in range(room_rects.size()):
		if room_rects[i].has_point(point):
			var room: Dictionary = LEVELS[current_floor]["rooms"][i]
			_enter_room_view(str(room["id"]), str(room["name"]))
			return true
	return false

func _select_room_at(point: Vector2) -> void:
	for i in range(room_rects.size()):
		if room_rects[i].has_point(point):
			var room: Dictionary = LEVELS[current_floor]["rooms"][i]
			selected_room_id = str(room["id"])
			selected_room_name = str(room["name"])
			_set_message("Выбрано помещение: %s" % selected_room_name)
			_update_ui()
			queue_redraw()
			return

func _interact_with_room() -> void:
	match selected_room_id:
		"bedroom", "guest1", "guest2":
			_rest()
			_set_message("Ты отдохнул в комнате. Силы восстановлены.")
		"living":
			_advance_time(30)
			energy = minf(100.0, energy + 8.0)
			_set_message("Ты спокойно провёл полчаса в гостиной.")
		"kitchen":
			_cook_meal()
		"workshop":
			_work()
		"storage":
			_set_message("Ты проверил полки склада: древесина %d, еда %d, вода %d, металл %d." % [wood, food, water, scrap])
		"arsenal":
			_scout_shore()
		"greenhouse":
			_tend_garden()
		"techblock":
			_purify_water()
		"lookout":
			_enter_balcony_defense()
	_update_ui()

func _process(delta: float) -> void:
	autosave_elapsed += delta
	if autosave_elapsed >= AUTOSAVE_INTERVAL:
		autosave_elapsed = 0.0
		_save_game_silent()
	if game_over:
		return
	if defense_mode:
		_process_defense(delta)
		queue_redraw()
		return
	if room_mode:
		_process_room_mode(delta)
		return
	var axis := Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
	if virtual_axis.length() > 0.08:
		axis = virtual_axis
	if stair_transition_active:
		_process_stair_transition(delta)
	elif axis.length() > 0.1:
		pending_interaction_room = ""
		pending_stair_floor = -1
		var axis_candidate := player_pos + axis.normalized() * PLAYER_SPEED * delta
		if _can_stand_at(axis_candidate):
			player_pos = axis_candidate
		moving = false
		_update_facing(axis)
		animation_clock += delta
		if animation_clock >= 0.12:
			animation_clock = 0.0
			animation_frame = (animation_frame + 1) % 4
	elif moving:
		var diff := target_pos - player_pos
		if diff.length() < 5.0:
			moving = false
			if pending_stair_floor >= 0:
				_begin_stair_transition(pending_stair_floor)
			elif not pending_interaction_room.is_empty():
				var interaction_room := pending_interaction_room
				pending_interaction_room = ""
				_interact_with_furniture(interaction_room)
				_update_ui()
		else:
			var move_dir := diff.normalized()
			var target_candidate := player_pos + move_dir * PLAYER_SPEED * delta
			if _can_stand_at(target_candidate):
				player_pos = target_candidate
			else:
				moving = false
			_update_facing(move_dir)
			animation_clock += delta
			if animation_clock >= 0.12:
				animation_clock = 0.0
				animation_frame = (animation_frame + 1) % 4
	if axis.length() <= 0.1 and not moving and not stair_transition_active:
		animation_frame = 0
	player_pos = _clamp_walkable_point(player_pos)
	# Advance the clock with a fractional accumulator so sub-minute frame
	# increments are not discarded (the old int(delta * 2) never advanced).
	time_fraction += delta * 2.0
	var elapsed_minutes := int(time_fraction)
	if elapsed_minutes > 0:
		time_fraction -= float(elapsed_minutes)
		_advance_time(elapsed_minutes)
	# _advance_time() applies needs exactly once for every whole in-game
	# minute accumulated above. Do not apply delta a second time here: doing
	# so would double the hunger/thirst/energy drain during real-time play.
	if health <= 0 and not game_over:
		game_over = true
		_set_message("Ты погиб. Загрузи последнее сохранение или начни заново.")
	var near_stairs := player_pos.distance_to(STAIR_LANDINGS[current_floor]) <= 85.0
	if is_instance_valid(stair_up_button):
		stair_up_button.disabled = current_floor >= 2
		stair_up_button.visible = near_stairs and not room_mode and not defense_mode
	if is_instance_valid(stair_down_button):
		stair_down_button.disabled = current_floor <= 0
		stair_down_button.visible = near_stairs and not room_mode and not defense_mode
	_update_ui()
	queue_redraw()

func _process_stair_transition(delta: float) -> void:
	if stair_path_points.size() < 2 or stair_path_index >= stair_path_points.size():
		_finish_stair_transition()
		return
	var waypoint: Vector2 = stair_path_points[stair_path_index]
	var offset := waypoint - player_pos
	var step := PLAYER_SPEED * 0.72 * delta
	if offset.length() <= step:
		player_pos = waypoint
		stair_path_index += 1
		stair_transition_progress = 0.0
	else:
		var direction := offset.normalized()
		player_pos += direction * step
		_update_facing(direction)
		stair_transition_progress += delta
	stair_step_bob += delta * 9.0
	animation_clock += delta
	if animation_clock >= 0.16:
		animation_clock = 0.0
		animation_frame = (animation_frame + 1) % 4
	if stair_path_index >= stair_path_points.size():
		_finish_stair_transition()

func _eat() -> void:
	if food <= 0:
		_set_message("Еды нет. Нужно пополнить запасы.")
		return
	food -= 1
	hunger = minf(100, hunger + 35)
	_advance_time(20)
	_set_message("Ты поел. Потрачено 20 минут.")
	_update_ui()

func _drink() -> void:
	if purified_water > 0:
		purified_water -= 1
	elif water > 0:
		water -= 1
	else:
		_set_message("Запас воды пуст. Нужно набрать и очистить воду.")
		return
	thirst = minf(100, thirst + 45)
	_advance_time(10)
	_set_message("Ты выпил воды. Потрачено 10 минут.")
	_update_ui()

func _rest() -> void:
	energy = minf(100, energy + 55)
	hunger = maxf(0, hunger - 4)
	thirst = maxf(0, thirst - 6)
	_advance_time(120)
	_set_message("Два часа отдыха. Силы восстановлены.")
	_update_ui()

func _work() -> void:
	if energy < 15:
		_set_message("Слишком мало сил для работы. Отдохни.")
		return
	if wood < 2:
		_set_message("Не хватает древесины для простого ремонта.")
		return
	wood -= 2
	scrap += 1
	energy = maxf(0, energy - 18)
	hunger = maxf(0, hunger - 3)
	_advance_time(60)
	_set_message("Ремонт завершён: -2 древесины, +1 металл.")
	_update_ui()


func _apply_needs(elapsed_minutes: float) -> void:
	var elapsed := maxf(elapsed_minutes, 0.0)
	hunger = maxf(0.0, hunger - elapsed * 0.012)
	thirst = maxf(0.0, thirst - elapsed * 0.020)
	energy = maxf(0.0, energy - elapsed * 0.004)
	if hunger <= 0.0 or thirst <= 0.0:
		health = maxf(0.0, health - elapsed * 0.08)

func _fish() -> void:
	if energy < 8.0:
		_set_message("Ты слишком устал для рыбалки.")
		return
	energy -= 8.0
	_advance_time(50)
	var catch := randi_range(0, 2 if weather == "ДОЖДЬ" else 3)
	fish += catch
	food += catch
	noise_level = minf(100.0, noise_level + 3.0)
	_set_message("Рыбалка завершена. Улов: %d. Погода: %s." % [catch, weather])
	_update_ui()

func _scavenge() -> void:
	if energy < 15.0:
		_set_message("Для поиска припасов нужно больше сил.")
		return
	energy -= 15.0
	_advance_time(75)
	var found := randi_range(1, 3)
	var metal_found := randi_range(0, 1)
	wood += found
	scrap += metal_found
	noise_level = minf(100.0, noise_level + 18.0)
	if noise_level > 55.0:
		zombies += 1
		_set_message("Найдено древесины: %d, металла: %d. Шум привлёк зомби!" % [found, metal_found])
	else:
		_set_message("Найдено древесины: %d, металла: %d." % [found, metal_found])
	_update_ui()

func _purify_water() -> void:
	if water < 1:
		_set_message("Нет сырой воды для очистки.")
		return
	water -= 1
	purified_water += 1
	_advance_time(20)
	_set_message("Одна порция воды очищена. Чистая вода: %d." % purified_water)
	_update_ui()

func _upgrade_barricades() -> void:
	if wood < 6 or scrap < 3 or energy < 20.0:
		_set_message("Улучшение требует 6 древесины, 3 металла и 20 энергии.")
		return
	wood -= 6
	scrap -= 3
	energy -= 20.0
	barricade_level = mini(barricade_level + 1, 5)
	shelter_integrity = minf(100.0, shelter_integrity + 12.0)
	_advance_time(120)
	_set_message("Баррикады улучшены до уровня %d." % barricade_level)
	_update_ui()

func _journal_update() -> void:
	journal_step = mini(journal_step + 1, 5)
	morale = minf(100.0, morale + 4.0)
	_advance_time(10)
	_set_message("Запись в дневнике сделана. Этап истории: %d/5. Боевой дух: %d%%." % [journal_step, int(morale)])
	_update_ui()


# v0.22 — stage 1: island exploration with location unlocks and travel cost.
func _explore_island() -> void:
	var destinations := ["ПЛЯЖ", "ЛЕС", "ЛАГУНА", "СКАЛЬНЫЙ ПЕРЕВАЛ", "СТАРЫЙ ПИРС"]
	var next_location: String = str(destinations[randi_range(0, destinations.size() - 1)])
	if energy < 12.0:
		_set_message("Сил не хватает для выхода на остров.")
		return
	energy -= 12.0
	island_location = next_location
	explored_locations[next_location] = true
	_advance_time(45)
	_set_message("Исследован район: %s. Известных мест: %d/5." % [island_location, explored_locations.size()])
	_update_ui()

# v0.22 — stage 2: forage with location/weather-dependent yields.
func _forage() -> void:
	if not explored_locations.has("ЛЕС") and island_location != "ЛЕС":
		_set_message("Сначала найди лес во время исследования острова.")
		return
	var berry_gain := randi_range(1, 3)
	var herb_gain := randi_range(0, 2)
	berries += berry_gain
	medicine_herbs += herb_gain
	energy = maxf(0.0, energy - 7.0)
	_advance_time(30)
	_set_message("Собрано ягод: %d, лекарственных трав: %d." % [berry_gain, herb_gain])
	_update_ui()

# v0.22 — stage 3: garden progression provides renewable food.
func _tend_garden() -> void:
	if garden_level == 0:
		if wood < 4 or scrap < 1:
			_set_message("Для грядки нужны 4 древесины и 1 металл.")
			return
		wood -= 4
		scrap -= 1
		garden_level = 1
		_set_message("Первая грядка устроена. Теперь ухаживай за ней ежедневно.")
	else:
		garden_progress += 1.0
		if garden_progress >= 3.0:
			garden_progress = 0.0
			food += 2
			_set_message("Урожай собран: +2 еды.")
		else:
			_set_message("Грядка ухожена. До урожая осталось %d дня ухода." % int(3.0 - garden_progress))
	_advance_time(25)
	_update_ui()

# v0.22 — stage 4: craft a reusable melee tool.
func _craft_spear() -> void:
	if wood < 3 or scrap < 2:
		_set_message("Для копья нужны 3 древесины и 2 металла.")
		return
	wood -= 3
	scrap -= 2
	spear_durability = mini(spear_durability + 40, 100)
	noise_level = minf(100.0, noise_level + 4.0)
	_advance_time(40)
	_set_message("Копьё изготовлено. Прочность: %d%%." % spear_durability)
	_update_ui()

# v0.22 — stage 5: hunting converts weapon durability into food.
func _hunt() -> void:
	if spear_durability <= 0:
		_set_message("Нужно изготовить копьё в мастерской.")
		return
	if energy < 10.0:
		_set_message("Слишком мало сил для охоты.")
		return
	spear_durability = maxi(0, spear_durability - randi_range(8, 18))
	energy -= 10.0
	var catch := randi_range(0, 2)
	food += catch
	_advance_time(60)
	_set_message("Охота завершена. Добыча: %d еды. Прочность копья: %d%%." % [catch, spear_durability])
	_update_ui()

# v0.22 — stage 6: rainwater collection is weather-gated.
func _collect_rainwater() -> void:
	if weather != "ДОЖДЬ":
		_set_message("Собирать дождевую воду можно только во время дождя.")
		return
	var amount := randi_range(1, 3)
	water += amount
	_advance_time(15)
	_set_message("Собрано дождевой воды: %d порции." % amount)
	_update_ui()

# v0.22 — stage 7: radio beacon consumes batteries and can trigger a supply drop.
func _use_radio() -> void:
	if radio_battery < 1:
		_set_message("Для радиомаяка нужна батарея. Найди её среди припасов.")
		return
	radio_battery -= 1
	radio_signal_sent = true
	_advance_time(20)
	if randi_range(1, 100) <= 35:
		rescued_supplies += 1
		food += 2
		water += 1
		_set_message("Сигнал принят! На берегу обнаружен пакет помощи: +2 еды, +1 воды.")
	else:
		_set_message("Сигнал отправлен. Ответа пока нет.")
	_update_ui()

# v0.22 — stage 8: workshop upgrades improve future salvage yields.
func _upgrade_workshop() -> void:
	if wood < 5 or scrap < 4 or shelter_upgrades >= 3:
		_set_message("Улучшение требует 5 древесины и 4 металла. Максимум — 3 уровня.")
		return
	wood -= 5
	scrap -= 4
	shelter_upgrades += 1
	_advance_time(90)
	_set_message("Мастерская улучшена: уровень %d/3." % shelter_upgrades)
	_update_ui()

# v0.22 — stage 9: injury care consumes herbs before health can recover.
func _treat_injury() -> void:
	if injury <= 0.0:
		_set_message("Серьёзных ранений нет. Здоровье: %d%%." % int(health))
		return
	if medicine_herbs < 2:
		_set_message("Для обработки ран нужны 2 лекарственные травы.")
		return
	medicine_herbs -= 2
	injury = maxf(0.0, injury - 35.0)
	health = minf(100.0, health + 12.0)
	_advance_time(30)
	_set_message("Раны обработаны. Травма: %d%%." % int(injury))
	_update_ui()

# v0.22 — stage 10: salvage sorting yields different resources.
func _process_salvage() -> void:
	if rescued_supplies <= 0 and scrap < 2:
		_set_message("Нет найденных пакетов или металлолома для разбора.")
		return
	if rescued_supplies > 0:
		rescued_supplies -= 1
		wood += 2
		radio_battery += 1
	else:
		scrap -= 2
		wood += 1
		medicine_herbs += 1
	_advance_time(20)
	_set_message("Припасы разобраны и отсортированы. Батареи: %d." % radio_battery)
	_update_ui()

func _advance_time(minutes: int) -> void:
	# Explicit actions advance the same survival clock as movement/waiting.
	var elapsed := float(maxi(minutes, 0))
	_apply_needs(elapsed)
	minute_of_day += minutes
	while minute_of_day >= DAY_MINUTES:
		minute_of_day -= DAY_MINUTES
		day += 1
		noise_level = maxf(0.0, noise_level - 25.0)
		morale = maxf(0.0, morale - 1.0)
		var weather_roll := randi_range(0, 3)
		weather = ["ЯСНО", "ТУМАН", "ДОЖДЬ", "ВЕТЕР"][weather_roll]
		# Small shoreline arrivals keep pressure on the shelter without spawning
		# a large horde every night. Traps may reduce the incoming group.
		var incoming := randi_range(1, 3)
		var caught := mini(traps, incoming)
		traps -= caught
		zombies += incoming - caught
		if zombies > 0:
			var raid_damage := maxf(1.0, float(zombies) * (2.0 - float(barricade_level - 1) * 0.18))
			shelter_integrity = maxf(0.0, shelter_integrity - raid_damage)
			if shelter_integrity <= 0.0:
				health = maxf(0.0, health - float(zombies) * 3.0)
				_set_message("ПРОРЫВ! Зомби проникли в убежище. Здоровье под угрозой.")
			else:
				_set_message("День %d. Прибыло %d зомби; ловушки остановили %d. Урон укреплениям: %d." % [day, incoming, caught, int(raid_damage)])
		else:
			_set_message("День %d. Берег чист: ловушки остановили всю группу." % day)
		_save_game_silent()

func _gather_wood() -> void:
	if energy < 12:
		_set_message("Слишком мало сил. Сначала отдохни.")
		return
	wood += 3
	energy = maxf(0, energy - 12)
	hunger = maxf(0, hunger - 2)
	_advance_time(45)
	_set_message("Заготовлено 3 единицы древесины. Потрачено 45 минут.")
	_update_ui()

func _collect_water() -> void:
	if energy < 5:
		_set_message("Не хватает сил поднять ведро с водой.")
		return
	water += 2
	energy = maxf(0, energy - 5)
	_advance_time(20)
	_set_message("Набрано 2 единицы воды через лебёдку.")
	_update_ui()

func _cook_meal() -> void:
	if food < 2:
		_set_message("Для приготовления блюда нужны 2 единицы продуктов.")
		return
	food -= 2
	hunger = minf(100, hunger + 55)
	_advance_time(35)
	_set_message("Приготовлена горячая еда. Потрачено 35 минут.")
	_update_ui()

func _craft_trap() -> void:
	if wood < 4 or scrap < 2:
		_set_message("Для ловушки нужны 4 древесины и 2 металла.")
		return
	if energy < 18:
		_set_message("Слишком мало сил для изготовления ловушки.")
		return
	wood -= 4
	scrap -= 2
	energy -= 18
	traps += 1
	_advance_time(90)
	_set_message("Изготовлена и установлена ловушка у подхода к убежищу.")
	_update_ui()

func _craft_medkit() -> void:
	if scrap < 2 or food < 1:
		_set_message("Для аптечки нужны 2 металла и 1 единица чистых материалов.")
		return
	if energy < 12.0:
		_set_message("Не хватает сил собрать аптечку.")
		return
	scrap -= 2
	food -= 1
	energy -= 12.0
	medkits += 1
	_advance_time(50)
	_set_message("Аптечка собрана. В запасе: %d." % medkits)
	_update_ui()

func _use_medkit() -> void:
	if medkits <= 0:
		_set_message("Аптечек нет. Собери новую в мастерской.")
		return
	if health >= 100.0:
		_set_message("Здоровье уже полностью восстановлено.")
		return
	medkits -= 1
	health = minf(100.0, health + 40.0)
	_advance_time(10)
	_set_message("Использована аптечка. Здоровье восстановлено до %d%%." % int(health))
	_update_ui()

func _scout_shore() -> void:
	_advance_time(25)
	if zombies == 0:
		_set_message("Берег пока чист. Можно заняться хозяйством.")
	else:
		_set_message("На подходах замечено зомби: %d. Подготовь оборону." % zombies)
	_update_ui()

func _defend_shelter() -> void:
	_enter_balcony_defense()

func _repair_shelter() -> void:
	if wood < 2 or energy < 10:
		_set_message("Для ремонта нужны 2 древесины и 10 энергии.")
		return
	wood -= 2
	energy -= 10
	shelter_integrity = minf(100.0, shelter_integrity + 20.0)
	_advance_time(45)
	_set_message("Укрепления отремонтированы. Прочность: %d%%." % int(shelter_integrity))
	_update_ui()

func _new_game() -> void:
	current_floor = 1
	selected_room_id = "living"
	selected_room_name = "ГОСТИНАЯ"
	player_pos = Vector2(640, 420)
	target_pos = Vector2.ZERO
	moving = false
	day = 1
	minute_of_day = 7 * 60
	health = 100.0
	hunger = 85.0
	thirst = 80.0
	energy = 90.0
	wood = 8
	food = 5
	water = 4
	scrap = 3
	traps = 0
	medkits = 1
	zombies = 0
	shelter_integrity = 100.0
	game_over = false
	defense_mode = false
	ammo_loaded = 120
	ammo_reserve = 300
	defense_kills = 0
	time_fraction = 0.0
	weather = "ЯСНО"
	noise_level = 0.0
	island_location = "ПЛЯЖ"
	explored_locations = {"ПЛЯЖ": true}
	berries = 0
	medicine_herbs = 0
	garden_level = 0
	garden_progress = 0.0
	spear_durability = 0
	radio_battery = 0
	radio_signal_sent = false
	rescued_supplies = 0
	shelter_upgrades = 0
	injury = 0.0
	purified_water = 0
	fish = 0
	morale = 75.0
	barricade_level = 1
	journal_step = 0
	explored_cache = false
	_set_message("Новая жизнь начинается. Береги запасы.")
	_update_ui()
	_save_game()
	queue_redraw()

func _advance_day_if_needed() -> void:
	while minute_of_day >= DAY_MINUTES:
		minute_of_day -= DAY_MINUTES
		day += 1
		noise_level = maxf(0.0, noise_level - 25.0)
		morale = maxf(0.0, morale - 1.0)
		var weather_roll := randi_range(0, 3)
		weather = ["ЯСНО", "ТУМАН", "ДОЖДЬ", "ВЕТЕР"][weather_roll]

func _set_message(text: String) -> void:
	last_message = text
	if is_instance_valid(message_label):
		message_label.text = text

func _update_ui() -> void:
	if not is_instance_valid(floor_label): return
	floor_label.text = LEVELS[current_floor]["name"]
	if is_instance_valid(stair_up_button):
		stair_up_button.disabled = current_floor >= 2 or player_pos.distance_to(STAIR_LANDINGS[current_floor]) > 135.0
	if is_instance_valid(stair_down_button):
		stair_down_button.disabled = current_floor <= 0 or player_pos.distance_to(STAIR_LANDINGS[current_floor]) > 135.0
	clock_label.text = "ДЕНЬ %d  •  %02d:%02d" % [day, int(minute_of_day / 60), minute_of_day % 60]
	status_label.text = "Здоровье %d  |  Голод %d  |  Жажда %d  |  Энергия %d" % [int(health), int(hunger), int(thirst), int(energy)]
	inventory_label.text = "Дерево %d | Еда %d | Вода %d+%d | Металл %d | Ловушки %d | Аптечки %d | Ягоды %d | Травы %d | Копьё %d%%" % [wood, food, water, purified_water, scrap, traps, medkits, berries, medicine_herbs, spear_durability]
	clock_label.text += "  •  %s" % weather
	var meter_values := {"Здоровье": health, "Голод": hunger, "Жажда": thirst, "Энергия": energy, "Прочность": shelter_integrity}
	for meter_name in needs_bars:
		var meter: ProgressBar = needs_bars[meter_name]
		meter.value = clampf(float(meter_values[meter_name]), 0.0, 100.0)
		meter.tooltip_text = "%s: %d%%" % [meter_name, int(meter.value)]
	if is_instance_valid(selected_room_label):
		selected_room_label.text = "Комната: %s" % selected_room_name
	if is_instance_valid(room_interact_button):
		room_interact_button.text = "Действие: %s" % _room_action_caption()
	if is_instance_valid(threat_label):
		threat_label.text = "УГРОЗА: %d заражённых  •  Убежище: %d%%  •  Баррикады: %d" % [zombies, int(shelter_integrity), barricade_level]
	if zombies > 0:
		message_label.text = "%s\nУГРОЗА: %d зомби | Убежище: %d%% | Шум: %d | Баррикады: %d" % [last_message, zombies, int(shelter_integrity), int(noise_level), barricade_level]
	else:
		message_label.text = last_message
	if dynamic_counters.size() > 0:
		dynamic_counters["day"].text = "День %d" % day
		dynamic_counters["health"].text = "%d/100" % int(health)
		dynamic_counters["energy"].text = "%d/100" % int(energy)
		dynamic_counters["hunger"].text = "%d/100" % int(hunger)
		dynamic_counters["thirst"].text = "%d/100" % int(thirst)
		dynamic_counters["ammo"].text = str(ammo_loaded)
		dynamic_counters["wood"].text = str(wood)
		dynamic_counters["metal"].text = str(scrap)
		dynamic_counters["medkits"].text = str(medkits)

func _room_action_caption() -> String:
	var story: Dictionary = ROOM_STORIES.get(selected_room_id, ROOM_STORIES["living"])
	return str(story["action"])

func _save_game() -> void:
	_save_game_silent()
	_set_message("Игра сохранена.")

func _save_game_silent() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("player", "floor", current_floor)
	cfg.set_value("player", "selected_room_id", selected_room_id)
	cfg.set_value("player", "selected_room_name", selected_room_name)
	cfg.set_value("player", "day", day)
	cfg.set_value("player", "minute", minute_of_day)
	cfg.set_value("player", "health", health)
	cfg.set_value("player", "hunger", hunger)
	cfg.set_value("player", "thirst", thirst)
	cfg.set_value("player", "energy", energy)
	cfg.set_value("player", "x", player_pos.x)
	cfg.set_value("player", "y", player_pos.y)
	cfg.set_value("inventory", "wood", wood)
	cfg.set_value("inventory", "food", food)
	cfg.set_value("inventory", "water", water)
	cfg.set_value("inventory", "scrap", scrap)
	cfg.set_value("inventory", "traps", traps)
	cfg.set_value("inventory", "medkits", medkits)
	cfg.set_value("inventory", "purified_water", purified_water)
	cfg.set_value("inventory", "fish", fish)
	cfg.set_value("world", "weather", weather)
	cfg.set_value("world", "noise_level", noise_level)
	cfg.set_value("world", "morale", morale)
	cfg.set_value("world", "barricade_level", barricade_level)
	cfg.set_value("defense", "ammo_loaded", ammo_loaded)
	cfg.set_value("defense", "ammo_reserve", ammo_reserve)
	cfg.set_value("defense", "kills", defense_kills)
	cfg.set_value("world", "journal_step", journal_step)
	cfg.set_value("world", "explored_cache", explored_cache)
	cfg.set_value("world", "zombies", zombies)
	cfg.set_value("world", "shelter_integrity", shelter_integrity)
	cfg.set_value("world", "quest_flags", quest_flags)
	cfg.set_value("world", "version", 10)
	cfg.set_value("island", "location", island_location)
	cfg.set_value("island", "explored_locations", explored_locations)
	cfg.set_value("island", "berries", berries)
	cfg.set_value("island", "medicine_herbs", medicine_herbs)
	cfg.set_value("island", "garden_level", garden_level)
	cfg.set_value("island", "garden_progress", garden_progress)
	cfg.set_value("island", "spear_durability", spear_durability)
	cfg.set_value("island", "radio_battery", radio_battery)
	cfg.set_value("island", "radio_signal_sent", radio_signal_sent)
	cfg.set_value("island", "rescued_supplies", rescued_supplies)
	cfg.set_value("island", "shelter_upgrades", shelter_upgrades)
	cfg.set_value("island", "injury", injury)
	cfg.set_value("world", "time_fraction", time_fraction)
	cfg.set_value("world", "game_over", game_over)
	cfg.set_value("world", "last_message", last_message)
	var err := cfg.save(SAVE_PATH)
	if err != OK:
		_set_message("Ошибка сохранения: %s" % err)

func _load_game() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK: return
	current_floor = int(cfg.get_value("player", "floor", 2))
	selected_room_id = str(cfg.get_value("player", "selected_room_id", "living"))
	selected_room_name = str(cfg.get_value("player", "selected_room_name", "ГОСТИНАЯ"))
	day = int(cfg.get_value("player", "day", 1))
	minute_of_day = int(cfg.get_value("player", "minute", 420))
	time_fraction = float(cfg.get_value("world", "time_fraction", 0.0))
	health = float(cfg.get_value("player", "health", 100.0))
	hunger = float(cfg.get_value("player", "hunger", 85.0))
	thirst = float(cfg.get_value("player", "thirst", 80.0))
	energy = float(cfg.get_value("player", "energy", 90.0))
	player_pos = Vector2(float(cfg.get_value("player", "x", 640.0)), float(cfg.get_value("player", "y", 220.0)))
	current_floor = clampi(current_floor, 0, 2)
	wood = int(cfg.get_value("inventory", "wood", 8))
	food = int(cfg.get_value("inventory", "food", 5))
	water = int(cfg.get_value("inventory", "water", 4))
	scrap = int(cfg.get_value("inventory", "scrap", 3))
	traps = int(cfg.get_value("inventory", "traps", 0))
	medkits = int(cfg.get_value("inventory", "medkits", 1))
	zombies = int(cfg.get_value("world", "zombies", 0))
	shelter_integrity = float(cfg.get_value("world", "shelter_integrity", 100.0))
	game_over = bool(cfg.get_value("world", "game_over", false))
	quest_flags = cfg.get_value("world", "quest_flags", {})
	last_message = str(cfg.get_value("world", "last_message", "Сохранение загружено."))
	# Sanitize values from older or damaged save files before they reach gameplay/UI.
	day = maxi(day, 1)
	minute_of_day = clampi(minute_of_day, 0, DAY_MINUTES - 1)
	health = clampf(health, 0.0, 100.0)
	hunger = clampf(hunger, 0.0, 100.0)
	thirst = clampf(thirst, 0.0, 100.0)
	energy = clampf(energy, 0.0, 100.0)
	shelter_integrity = clampf(shelter_integrity, 0.0, 100.0)
	wood = maxi(wood, 0)
	food = maxi(food, 0)
	water = maxi(water, 0)
	scrap = maxi(scrap, 0)
	traps = maxi(traps, 0)
	medkits = maxi(medkits, 0)
	purified_water = maxi(int(cfg.get_value("inventory", "purified_water", 0)), 0)
	fish = maxi(int(cfg.get_value("inventory", "fish", 0)), 0)
	weather = str(cfg.get_value("world", "weather", "ЯСНО"))
	island_location = str(cfg.get_value("island", "location", "ПЛЯЖ"))
	explored_locations = cfg.get_value("island", "explored_locations", {"ПЛЯЖ": true})
	berries = maxi(int(cfg.get_value("island", "berries", 0)), 0)
	medicine_herbs = maxi(int(cfg.get_value("island", "medicine_herbs", 0)), 0)
	garden_level = clampi(int(cfg.get_value("island", "garden_level", 0)), 0, 1)
	garden_progress = clampf(float(cfg.get_value("island", "garden_progress", 0.0)), 0.0, 2.99)
	spear_durability = clampi(int(cfg.get_value("island", "spear_durability", 0)), 0, 100)
	radio_battery = maxi(int(cfg.get_value("island", "radio_battery", 0)), 0)
	radio_signal_sent = bool(cfg.get_value("island", "radio_signal_sent", false))
	rescued_supplies = maxi(int(cfg.get_value("island", "rescued_supplies", 0)), 0)
	shelter_upgrades = clampi(int(cfg.get_value("island", "shelter_upgrades", 0)), 0, 3)
	injury = clampf(float(cfg.get_value("island", "injury", 0.0)), 0.0, 100.0)
	noise_level = clampf(float(cfg.get_value("world", "noise_level", 0.0)), 0.0, 100.0)
	morale = clampf(float(cfg.get_value("world", "morale", 75.0)), 0.0, 100.0)
	barricade_level = clampi(int(cfg.get_value("world", "barricade_level", 1)), 1, 5)
	ammo_loaded = clampi(int(cfg.get_value("defense", "ammo_loaded", 120)), 0, 120)
	ammo_reserve = clampi(int(cfg.get_value("defense", "ammo_reserve", 300)), 0, 3000)
	defense_kills = maxi(int(cfg.get_value("defense", "kills", 0)), 0)
	journal_step = clampi(int(cfg.get_value("world", "journal_step", 0)), 0, 5)
	explored_cache = bool(cfg.get_value("world", "explored_cache", false))
	zombies = maxi(zombies, 0)
	player_pos = _clamp_walkable_point(player_pos)

func _load_art_assets() -> void:
	var approved_path := "res://art/ui/approved_fullscreen.png"
	if ResourceLoader.exists(approved_path):
		approved_ui_texture = load(approved_path)
	var balcony_path := "res://art/ui/approved_balcony.png"
	if ResourceLoader.exists(balcony_path):
		balcony_ui_texture = load(balcony_path)
	var ids := ["bedroom", "living", "kitchen", "workshop", "storage", "arsenal", "guest1", "guest2"]
	for room_id in ids:
		var path := "res://art/rooms/%s.png" % room_id
		if ResourceLoader.exists(path):
			room_textures[room_id] = load(path)
	var character_path := "res://art/characters/survivor_sheet.png"
	if ResourceLoader.exists(character_path):
		survivor_texture = load(character_path)

func _update_facing(direction: Vector2) -> void:
	if absf(direction.x) > absf(direction.y):
		facing_row = 2 if direction.x > 0.0 else 1
	else:
		facing_row = 0 if direction.y > 0.0 else 3

func _draw() -> void:
	if room_mode:
		_draw_room_view()
		return
	var active_texture: Texture2D = balcony_ui_texture if defense_mode else approved_ui_texture
	if active_texture != null:
		draw_texture_rect(active_texture, Rect2(Vector2.ZERO, Vector2(1536, 864)), false)
	else:
		draw_rect(Rect2(Vector2.ZERO, Vector2(1536, 864)), Color("211a14"), true)
	if defense_mode:
		_draw_clean_balcony_panorama()
		_draw_machinegun_turret()
		# Large, progressively growing infected silhouettes enter only from the water.
		for target in defense_targets:
			_draw_zombie_target(target)
		# Spent brass ejects from the right side of the receiver and falls away.
		for casing in casing_particles:
			var casing_pos: Vector2 = casing["pos"]
			var life_ratio := clampf(float(casing["life"]) / 0.85, 0.0, 1.0)
			draw_set_transform(casing_pos, float(casing["spin"]) * (1.0 - life_ratio), Vector2.ONE)
			draw_rect(Rect2(-8, -3, 17, 6), Color("b77b2e"), true)
			draw_rect(Rect2(-6, -2, 12, 2), Color("f2c36b"), true)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		var reticle_color := Color("ff4030") if defense_hit_flash > 0.0 else Color("ffe5b2")
		var reticle_radius := 14.0 if zoom_mode else (19.0 if aim_mode else 24.0)
		draw_arc(aim_position, reticle_radius, 0.0, TAU, 36, reticle_color, 2.5)
		draw_line(aim_position + Vector2(-38, 0), aim_position + Vector2(-12, 0), reticle_color, 2.0)
		draw_line(aim_position + Vector2(12, 0), aim_position + Vector2(38, 0), reticle_color, 2.0)
		draw_line(aim_position + Vector2(0, -38), aim_position + Vector2(0, -12), reticle_color, 2.0)
		draw_line(aim_position + Vector2(0, 12), aim_position + Vector2(0, 38), reticle_color, 2.0)
		draw_circle(Vector2(160, 735), 94.0, Color(0.035, 0.025, 0.018, 0.66))
		draw_arc(Vector2(160, 735), 94.0, 0.0, TAU, 48, Color("d1ad73"), 4.0)
		draw_circle(Vector2(160, 735), 34.0, Color("96724a", 0.92))
		draw_arc(Vector2(160, 735), 34.0, 0.0, TAU, 32, Color("f0d2a0"), 3.0)
		draw_string(ThemeDB.fallback_font, Vector2(42, 850), "НАВЕДЕНИЕ", HORIZONTAL_ALIGNMENT_LEFT, 220, 16, Color("ffe2a4"))
		draw_circle(Vector2(1405, 745), 90.0, Color("5a1c12", 0.90))
		draw_arc(Vector2(1405, 745), 90.0, 0.0, TAU, 48, Color("e6a04d"), 5.0)
		draw_string(ThemeDB.fallback_font, Vector2(1310, 850), "ОГОНЬ", HORIZONTAL_ALIGNMENT_CENTER, 190, 18, Color("ffe2a4"))
	else:
		if survivor_texture != null:
			var source := Rect2(float(animation_frame) * 128.0, float(facing_row) * 160.0, 128.0, 160.0)
			var stair_bob := sin(stair_step_bob) * 1.5 if stair_transition_active else 0.0
			var destination := Rect2(player_pos.x - 36.0, player_pos.y - 82.0 + stair_bob, 72.0, 90.0)
			draw_texture_rect_region(survivor_texture, destination, source)
		_draw_virtual_joystick()

func _draw_clean_balcony_panorama() -> void:
	# The approved balcony plate contains baked-in attackers and a legacy reload panel.
	# Repaint the sea/beach and lower control strip; live enemies and controls are drawn later.
	draw_rect(Rect2(0, 710, 1536, 154), Color(0.075, 0.052, 0.034, 0.96), true)
	draw_rect(Rect2(0, 710, 1536, 154), Color("a98551"), false, 3.0)
	draw_rect(Rect2(285, 310, 1251, 235), Color("31596a"), true)
	for band in range(15):
		var y := 315.0 + float(band) * 15.0
		var c := Color("456f7a").lerp(Color("244653"), float(band) / 14.0)
		draw_rect(Rect2(285, y, 1251, 16), c, true)
	for wave in range(28):
		var y := 330.0 + float((wave * 17) % 205)
		var x := 300.0 + float((wave * 83) % 1160)
		draw_line(Vector2(x, y), Vector2(x + 70.0 + float(wave % 4) * 12.0, y - 3.0), Color(0.78, 0.88, 0.84, 0.28), 2.0)
		draw_line(Vector2(x + 20, y + 5), Vector2(x + 52, y + 4), Color(0.95, 0.86, 0.72, 0.20), 1.0)
	draw_polygon(PackedVector2Array([Vector2(285, 520), Vector2(1536, 500), Vector2(1536, 650), Vector2(285, 650)]), PackedColorArray([Color("9b805d"), Color("c2a178"), Color("907451"), Color("705b43")]))
	for rock in range(25):
		var x := 300.0 + float((rock * 71) % 1200)
		var y := 535.0 + float((rock * 29) % 100)
		draw_circle(Vector2(x + 8.0, y + 5.0), 5.0 + float(rock % 3) * 2.0, Color("554c40"))
	# A small yacht remains in the lagoon as a landmark.
	draw_polygon(PackedVector2Array([Vector2(370, 415), Vector2(490, 415), Vector2(470, 438), Vector2(390, 438)]), PackedColorArray([Color("202a30"), Color("202a30"), Color("10191f"), Color("10191f")]))
	draw_rect(Rect2(408, 392, 38, 23), Color("d8d0bd"), true)
	draw_line(Vector2(427, 392), Vector2(427, 365), Color("292c2e"), 3.0)
	draw_line(Vector2(427, 367), Vector2(455, 390), Color("e0d7c5"), 2.0)

func _draw_machinegun_turret() -> void:
	var direction := (aim_position - TURRET_PIVOT).normalized()
	turret_angle = Vector2.UP.angle_to(direction)
	var recoil_offset := turret_recoil * 9.0
	draw_set_transform(TURRET_PIVOT + direction * recoil_offset, turret_angle, Vector2.ONE)
	# Mount and traversing ring.
	draw_rect(Rect2(-112, -18, 224, 42), Color("252522"), true)
	draw_rect(Rect2(-92, -25, 184, 12), Color("8c6b3f"), true)
	draw_rect(Rect2(-28, -206, 56, 190), Color("242a2b"), true)
	draw_rect(Rect2(-20, -202, 40, 174), Color("536064"), true)
	draw_rect(Rect2(-11, -205, 22, 182), Color("a5a69a"), true)
	draw_rect(Rect2(-35, -184, 70, 38), Color("343b3b"), true)
	draw_rect(Rect2(-24, -230, 48, 35), Color("1b2223"), true)
	draw_rect(Rect2(-18, -246, 36, 25), Color("9b7a43"), true)
	draw_rect(Rect2(-9, -262, 18, 20), Color("202525"), true)
	draw_rect(Rect2(-74, -95, 46, 30), Color("3b403d"), true)
	draw_rect(Rect2(28, -95, 46, 30), Color("3b403d"), true)
	draw_rect(Rect2(-112, -12, 224, 12), Color("b18a4f"), true)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if muzzle_flash_timer > 0.0:
		var muzzle := _get_turret_muzzle_position()
		draw_line(muzzle, aim_position, Color(1.0, 0.78, 0.34, 0.55), 3.0)
		draw_set_transform(muzzle, turret_angle, Vector2.ONE)
		draw_circle(Vector2.ZERO, 36.0, Color(1.0, 0.56, 0.12, 0.24))
		draw_circle(Vector2.ZERO, 21.0, Color(1.0, 0.78, 0.28, 0.62))
		draw_polygon(PackedVector2Array([Vector2(-13, 0), Vector2(-5, -32), Vector2(0, -10), Vector2(13, -28), Vector2(8, 0), Vector2(25, 10), Vector2(2, 11), Vector2(-10, 25)]), PackedColorArray([Color("ff8a1f"), Color("fff0a0"), Color("ff9a23"), Color("fff0a0"), Color("ffb12d"), Color("fff0a0"), Color("ff8b1e"), Color("ffcf59")]))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_zombie_target(target: Dictionary) -> void:
	var pos: Vector2 = target["pos"]
	var scale_factor := float(target["scale"])
	var skin := Color("777b68")
	var clothes := Color("403d36") if int(target["hp"]) <= 1 else Color("4a5149")
	var head := pos + Vector2(0, -43.0 * scale_factor)
	draw_rect(Rect2(pos.x - 19.0 * scale_factor, pos.y - 15.0 * scale_factor, 38.0 * scale_factor, 62.0 * scale_factor), clothes, true)
	draw_line(pos + Vector2(-9, 8) * scale_factor, pos + Vector2(-17, 48) * scale_factor, clothes.darkened(0.2), 10.0 * scale_factor)
	draw_line(pos + Vector2(9, 8) * scale_factor, pos + Vector2(18, 48) * scale_factor, clothes.darkened(0.2), 10.0 * scale_factor)
	draw_line(pos + Vector2(-13, -5) * scale_factor, pos + Vector2(-34, 22) * scale_factor, skin, 9.0 * scale_factor)
	draw_line(pos + Vector2(13, -5) * scale_factor, pos + Vector2(34, 18) * scale_factor, skin, 9.0 * scale_factor)
	draw_circle(head, 15.0 * scale_factor, skin)
	draw_circle(head + Vector2(-5, -2) * scale_factor, 2.8 * scale_factor, Color("b63b2e"))
	draw_circle(head + Vector2(5, -2) * scale_factor, 2.8 * scale_factor, Color("b63b2e"))
	draw_line(head + Vector2(-5, 8) * scale_factor, head + Vector2(6, 9) * scale_factor, Color("2a211d"), 3.0 * scale_factor)
	if int(target["hp"]) > 1:
		draw_rect(Rect2(pos.x - 21.0 * scale_factor, pos.y - 80.0 * scale_factor, 42.0 * scale_factor, 5.0 * scale_factor), Color("241512"), true)
		draw_rect(Rect2(pos.x - 21.0 * scale_factor, pos.y - 80.0 * scale_factor, 21.0 * scale_factor, 5.0 * scale_factor), Color("df3429"), true)

func _draw_coastline_environment() -> void:
	# v0.27: richer illustrated island panorama framing the playable bunker.
	var sky := Rect2(1018.0, 78.0, 262.0, 565.0)
	for band in range(32):
		var t := float(band) / 31.0
		var c := Color("202b42").lerp(Color("f29a58"), t)
		draw_rect(Rect2(sky.position.x, sky.position.y + t * sky.size.y, sky.size.x, sky.size.y / 31.0 + 2.0), c, true)
	# Sunset disc and distant cloud banks.
	draw_circle(Vector2(1192, 278), 30, Color("ffd27b", 0.95))
	draw_circle(Vector2(1192, 278), 39, Color("ffc06b", 0.16))
	for cloud in range(5):
		var cx := 1040.0 + float(cloud) * 53.0
		var cy := 160.0 + float((cloud * 23) % 55)
		draw_line(Vector2(cx, cy), Vector2(cx + 38, cy - 5), Color("f6c19a", 0.20), 7.0)
	# Ruined skyline with broken rooflines and smoke columns.
	var skyline := [Vector2(1040, 330), Vector2(1060, 278), Vector2(1080, 312), Vector2(1104, 238), Vector2(1128, 296), Vector2(1152, 258), Vector2(1178, 300), Vector2(1200, 220), Vector2(1225, 286), Vector2(1250, 250)]
	for i in range(skyline.size()):
		var q: Vector2 = skyline[i]
		draw_rect(Rect2(q.x, q.y, 19.0, 360.0 - q.y), Color("30313a"), true)
		draw_polygon(PackedVector2Array([Vector2(q.x, q.y + 7), Vector2(q.x + 7, q.y - 5), Vector2(q.x + 19, q.y + 4)]), PackedColorArray([Color("292b34"), Color("292b34"), Color("292b34")]))
		for wy in range(4):
			draw_rect(Rect2(q.x + 4 + (wy % 2) * 7, q.y + 13.0 + wy * 19.0, 3, 6), Color(0.95, 0.62, 0.31, 0.48), true)
	# Smoke drifting above the damaged city.
	for puff in range(4):
		var smoke_pos := Vector2(1109.0 + puff * 3.0, 220.0 - puff * 22.0)
		draw_circle(smoke_pos, 10.0 + puff * 2.0, Color(0.24, 0.25, 0.29, 0.30 - puff * 0.045))
	# Sea, layered waves and foam.
	draw_rect(Rect2(1018, 360, 262, 190), Color("345b68"), true)
	for wave in range(15):
		var yy := 370.0 + wave * 12.0
		var xx := 1025.0 + float((wave * 37) % 75)
		draw_line(Vector2(xx, yy), Vector2(1270, yy - 4.0), Color(0.72, 0.82, 0.80, 0.30), 2.0)
		draw_line(Vector2(xx + 35, yy + 4), Vector2(xx + 75, yy + 2), Color(0.92, 0.83, 0.68, 0.22), 1.0)
	# Small stranded yacht, kept clear of the beach silhouettes.
	draw_polygon(PackedVector2Array([Vector2(1120, 424), Vector2(1215, 424), Vector2(1200, 443), Vector2(1134, 443)]), PackedColorArray([Color("202a30"), Color("202a30"), Color("10191f"), Color("10191f")]))
	draw_rect(Rect2(1150, 405, 34, 19), Color("d8d0bd"), true)
	draw_rect(Rect2(1158, 397, 17, 8), Color("b7c3c2"), true)
	draw_line(Vector2(1166, 397), Vector2(1166, 382), Color("292c2e"), 2.0)
	draw_line(Vector2(1166, 384), Vector2(1180, 394), Color("292c2e"), 2.0)
	# Narrow beach, rocks and scrub at the base of the cliff.
	draw_polygon(PackedVector2Array([Vector2(1018, 535), Vector2(1280, 510), Vector2(1280, 643), Vector2(1018, 643)]), PackedColorArray([Color("8b7659"), Color("b49a70"), Color("9a805e"), Color("75634d")]))
	for rock in range(9):
		var rx := 1025.0 + float(rock) * 31.0
		var ry := 535.0 + float((rock * 17) % 77)
		draw_circle(Vector2(rx, ry), 5.0 + float(rock % 3), Color("4b4840"))
	# Approaching infected silhouettes.
	for z in range(9):
		var zx := 1042.0 + float(z) * 27.0
		var zy := 560.0 + float((z * 19) % 65)
		draw_circle(Vector2(zx, zy - 8), 4.0, Color("252321"))
		draw_line(Vector2(zx, zy - 4), Vector2(zx - 2, zy + 9), Color("252321"), 4.0)
		draw_line(Vector2(zx - 1, zy + 2), Vector2(zx - 8, zy + 8), Color("252321"), 2.0)
		draw_line(Vector2(zx - 1, zy + 2), Vector2(zx + 6, zy + 8), Color("252321"), 2.0)
	draw_rect(sky, Color("d2b184"), false, 4.0)
	draw_string(ThemeDB.fallback_font, Vector2(1030, 105), "ПОБЕРЕЖЬЕ • ЗОНА УГРОЗЫ", HORIZONTAL_ALIGNMENT_LEFT, 240, 12, Color("fff0d1"))

func _draw_room_structure(r: Rect2, room_id: String) -> void:
	# Reinforced timber/steel framing makes each chamber read as a carved
	# architectural space instead of a flat picture tile.
	var beam := Color("59402e")
	var highlight := Color("b58a55")
	draw_line(r.position + Vector2(7, 31), Vector2(r.end.x - 7, r.position.y + 31), beam, 5.0)
	draw_line(r.position + Vector2(7, 34), Vector2(r.end.x - 7, r.position.y + 34), highlight, 1.0)
	draw_line(Vector2(r.position.x + 8, r.position.y + 8), Vector2(r.position.x + 8, r.end.y - 8), beam, 5.0)
	draw_line(Vector2(r.end.x - 8, r.position.y + 8), Vector2(r.end.x - 8, r.end.y - 8), beam, 5.0)
	# Rivets at the frame corners and a low utility conduit.
	for corner in [r.position + Vector2(9, 10), r.position + Vector2(ROOM_W - 9, 10), r.position + Vector2(9, ROOM_H - 10), r.position + Vector2(ROOM_W - 9, ROOM_H - 10)]:
		draw_circle(corner, 2.5, Color("d0ad79"))
	if room_id in ["workshop", "storage", "arsenal"]:
		draw_line(Vector2(r.position.x + 18, r.end.y - 17), Vector2(r.end.x - 18, r.end.y - 17), Color("77766b"), 3.0)
		draw_circle(Vector2(r.position.x + 24, r.end.y - 17), 3.0, Color("d4b77e"))

func _draw_room_badge(r: Rect2, caption: String, selected: bool) -> void:
	var badge_width := minf(150.0, maxf(92.0, caption.length() * 7.2 + 20.0))
	var badge_rect := Rect2(r.end.x - badge_width - 12.0, r.position.y + 9.0, badge_width, 23.0)
	draw_rect(badge_rect, Color("21170f", 0.94), true)
	draw_rect(badge_rect, Color("e3b85f") if selected else Color("9b7548"), false, 2.0)
	draw_string(ThemeDB.fallback_font, badge_rect.position + Vector2(7, 16), caption, HORIZONTAL_ALIGNMENT_LEFT, badge_width - 14, 11, Color("ffe2ad") if selected else Color("e5cfaa"))

func _draw_virtual_joystick() -> void:
	# Subtle parchment-style touch control, visible on phones and harmless on desktop.
	var knob_offset := virtual_axis * joystick_radius * 0.62
	draw_circle(joystick_center, joystick_radius, Color(0.08, 0.06, 0.04, 0.30))
	draw_arc(joystick_center, joystick_radius, 0.0, TAU, 48, Color("c5a77c"), 3.0)
	draw_circle(joystick_center + knob_offset, 27.0, Color("b18a60", 0.88))
	draw_arc(joystick_center + knob_offset, 27.0, 0.0, TAU, 32, Color("ead0a5"), 2.0)
	draw_string(ThemeDB.fallback_font, joystick_center + Vector2(-34, 5), "MOVE", HORIZONTAL_ALIGNMENT_CENTER, 68, 11, Color("f2dfbd"))

func _draw_furniture(r: Rect2, id: String) -> void:
	var c := r.get_center()
	# Hand-built, warm rustic furnishing silhouettes. The dark inset and
	# repeated floor seams make the rooms read as carved stone with timber floors.
	for row in range(5):
		var y := r.position.y + 38.0 + float(row) * 22.0
		draw_line(Vector2(r.position.x + 14, y), Vector2(r.end.x - 14, y), Color(0.18, 0.11, 0.07, 0.28), 1.0)
	# A woven rug anchors the central part of each room.
	draw_rect(Rect2(c.x - 48, c.y + 18, 96, 38), Color("76503b"), true)
	draw_rect(Rect2(c.x - 43, c.y + 22, 86, 30), Color("b18a60"), false, 2)
	match id:
		"bedroom", "guest1", "guest2":
			# Bed, pillows, bedside table and kerosene lamp.
			draw_rect(Rect2(c.x - 94, c.y - 43, 112, 65), Color("4a3024"), true)
			draw_rect(Rect2(c.x - 89, c.y - 39, 102, 55), Color("a77c59"), true)
			draw_rect(Rect2(c.x - 81, c.y - 33, 34, 20), Color("e1c9a4"), true)
			draw_rect(Rect2(c.x - 42, c.y - 33, 47, 20), Color("e1c9a4"), true)
			draw_rect(Rect2(c.x + 55, c.y - 35, 37, 34), Color("60402d"), true)
			draw_circle(Vector2(c.x + 73, c.y - 43), 7, Color("e7ad52"))
			draw_circle(Vector2(c.x + 73, c.y - 43), 13, Color(1.0, 0.62, 0.22, 0.13))
			draw_rect(Rect2(c.x - 102, c.y + 40, 35, 20), Color("61442f"), true)
		"living":
			# Sofa, coffee table, bookcase, fireplace and round concealed window.
			draw_rect(Rect2(c.x - 100, c.y - 37, 95, 43), Color("563629"), true)
			draw_rect(Rect2(c.x - 94, c.y - 32, 83, 31), Color("a24f38"), true)
			draw_rect(Rect2(c.x + 16, c.y - 12, 63, 38), Color("69452f"), true)
			draw_rect(Rect2(c.x + 22, c.y - 7, 51, 28), Color("bd9568"), true)
			draw_rect(Rect2(c.x - 110, c.y + 40, 90, 18), Color("5b3d2b"), true)
			for j in range(4):
				draw_line(Vector2(c.x - 103 + j * 20, c.y + 42), Vector2(c.x - 103 + j * 20, c.y + 55), Color("d0ad79"), 2)
			draw_rect(Rect2(c.x + 82, c.y - 48, 28, 58), Color("392a22"), true)
			draw_circle(Vector2(c.x + 96, c.y - 20), 12, Color("ed9c3e"))
			_draw_round_window(Vector2(c.x + 108, c.y - 59))
		"kitchen":
			# Worktop, sink, stove and hanging cookware.
			draw_rect(Rect2(c.x - 105, c.y - 48, 178, 27), Color("9b7048"), true)
			draw_rect(Rect2(c.x - 98, c.y - 43, 55, 17), Color("d2b58b"), true)
			draw_rect(Rect2(c.x - 28, c.y - 43, 42, 17), Color("54463b"), true)
			draw_rect(Rect2(c.x - 23, c.y - 39, 32, 9), Color("9b9a8a"), true)
			draw_rect(Rect2(c.x + 46, c.y + 4, 53, 49), Color("40312a"), true)
			draw_rect(Rect2(c.x + 52, c.y + 10, 41, 35), Color("b45d32"), true)
			draw_circle(Vector2(c.x + 72, c.y + 27), 10, Color("f0a13e"))
			draw_line(Vector2(c.x - 66, c.y - 62), Vector2(c.x - 66, c.y - 49), Color("c6a77b"), 3)
			draw_line(Vector2(c.x - 5, c.y - 62), Vector2(c.x - 5, c.y - 49), Color("c6a77b"), 3)
		"workshop":
			# Heavy workbench, pegboard, tools and research desk.
			draw_rect(Rect2(c.x - 105, c.y + 20, 190, 27), Color("64432d"), true)
			draw_rect(Rect2(c.x - 99, c.y + 16, 178, 8), Color("c0945f"), true)
			draw_rect(Rect2(c.x - 92, c.y - 55, 170, 35), Color("553a2a"), true)
			for j in range(6):
				draw_line(Vector2(c.x - 78 + j * 28, c.y - 48), Vector2(c.x - 78 + j * 28, c.y - 27), Color("d4b17b"), 3)
			draw_circle(Vector2(c.x + 50, c.y + 4), 15, Color("8e9690"))
			draw_circle(Vector2(c.x + 50, c.y + 4), 8, Color("343b38"))
		"storage":
			# Shelving, crates, sacks and labeled supply boxes.
			for j in range(4):
				var sx := c.x - 104 + float(j) * 54.0
				draw_rect(Rect2(sx, c.y - 49, 43, 92), Color("5b3c2b"), true)
				draw_rect(Rect2(sx + 4, c.y - 44, 35, 18), Color("bd9562"), true)
				draw_rect(Rect2(sx + 4, c.y - 19, 35, 24), Color("8d6847"), true)
				draw_rect(Rect2(sx + 4, c.y + 10, 35, 27), Color("b18a59"), true)
		"arsenal":
			# Weapon rack and locked ammunition chest.
			draw_rect(Rect2(c.x - 105, c.y - 48, 160, 17), Color("4a3024"), true)
			for j in range(5):
				draw_line(Vector2(c.x - 92 + j * 29, c.y - 43), Vector2(c.x - 75 + j * 29, c.y - 5), Color("d1b68d"), 5)
			draw_rect(Rect2(c.x - 32, c.y + 24, 91, 34), Color("65432c"), true)
			draw_rect(Rect2(c.x - 28, c.y + 28, 83, 8), Color("b18a59"), true)
	# Every room gets a warm practical light source.
	var lamp_pos := Vector2(r.end.x - 25, r.position.y + 27)
	draw_circle(lamp_pos, 12, Color(1.0, 0.58, 0.18, 0.10))
	draw_circle(lamp_pos, 5, Color("efb45d"))

func _draw_round_window(center: Vector2) -> void:
	# The circular aperture is visible from inside; exterior camouflage is
	# represented by the thick rock wall around the room.
	draw_circle(center, 19, Color("332820"))
	draw_circle(center, 14, Color("8d9a83"))
	draw_circle(center, 10, Color("526b70"))
	draw_line(center + Vector2(-12, 0), center + Vector2(12, 0), Color("d0b78d"), 2)
	draw_line(center + Vector2(0, -12), center + Vector2(0, 12), Color("d0b78d"), 2)

