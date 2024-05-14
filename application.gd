extends Control

@onready var main_menu = %MainMenu
@onready var tree = %Tree
@onready var hbc_pin = %HBC_Pin
@onready var button_clock = %ButtonClock
@onready var clock = %Clock

var project_ctr = ProjectContoller.new()

#--------------------------------------------------------------------------------------------------
func _ready() -> void:
	button_clock.pressed.connect(func():
		clock.visible = button_clock.button_pressed
		button_clock.modulate = Color.WHITE if button_clock.button_pressed else Color.DIM_GRAY
	)
	main_menu.project_changed.connect(func(project):
		project_ctr.set_project(project)
	)
	main_menu.quit_request.connect(func():
		quit()
	)
	
	connect_message_handler(project_ctr, tree)
	connect_message_handler(tree, project_ctr)
	connect_message_handler(project_ctr, hbc_pin)
	connect_message_handler(hbc_pin, project_ctr)
	
	DisplayServer.window_set_size(AssetUtils.get_configs(AssetUtils.S_SETTINGS, AssetUtils.K_WINDOW_SIZE, Vector2i(400,600)))
	DisplayServer.window_set_position(AssetUtils.get_configs(AssetUtils.S_SETTINGS, AssetUtils.K_WINDOW_POSITION, DisplayServer.window_get_position()))
	theme.default_font_size = AssetUtils.get_configs(AssetUtils.S_SETTINGS, AssetUtils.K_FONT_SIZE, 20)
	
	AssetUtils.init_paths()
	main_menu.project_ctr = project_ctr
	main_menu.quick_open()
	
#--------------------------------------------------------------------------------------------------
func _notification(what):
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			quit()

#--------------------------------------------------------------------------------------------------
func _unhandled_key_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("undo"):
		if project_ctr.undoredo.has_undo():
			print("undo:",project_ctr.undoredo.get_current_action_name())
			project_ctr.undoredo.undo()
	elif Input.is_action_just_pressed("redo"):
		if project_ctr.undoredo.has_redo():
			print("redo",project_ctr.undoredo.get_current_action_name())
			project_ctr.undoredo.redo()
			
	elif Input.is_action_just_pressed("scale_up_font"):
		theme.default_font_size += 4
		theme.default_font_size = min(theme.default_font_size, 36)
		AssetUtils.save_configs(AssetUtils.S_SETTINGS, AssetUtils.K_FONT_SIZE, theme.default_font_size)
		
	elif Input.is_action_just_pressed("scale_down_font"):
		theme.default_font_size -= 4
		theme.default_font_size = max(theme.default_font_size, 16)
		AssetUtils.save_configs(AssetUtils.S_SETTINGS, AssetUtils.K_FONT_SIZE, theme.default_font_size)

#--------------------------------------------------------------------------------------------------
func connect_message_handler(sender, handler):
	assert(handler.has_method("handle_message"))
	sender.message_sended.connect(func(msg):
		prints(sender, "[Send]:", msg, "[To]:", handler)
		handler.handle_message(msg)
	)

#--------------------------------------------------------------------------------------------------
func quit():
	AssetUtils.save_configs(AssetUtils.S_SETTINGS, AssetUtils.K_WINDOW_SIZE, DisplayServer.window_get_size(0))
	AssetUtils.save_configs(AssetUtils.S_SETTINGS, AssetUtils.K_WINDOW_POSITION, DisplayServer.window_get_position(0))
	if await main_menu.save_current():
		get_tree().quit()
	

			







