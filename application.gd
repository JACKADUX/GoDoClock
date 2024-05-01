extends Control

@onready var main_menu = %MainMenu
@onready var tree = %Tree
@onready var hbc_pin = %HBC_Pin

var project_ctr = ProjectContoller.new()

#--------------------------------------------------------------------------------------------------
func _ready() -> void:
	main_menu.project_changed.connect(func(project):
		project_ctr.set_project(project)
	)
	connect_message_handler(project_ctr, tree)
	connect_message_handler(tree, project_ctr)
	connect_message_handler(project_ctr, hbc_pin)
	connect_message_handler(hbc_pin, project_ctr)
	
	AssetUtils.init_paths()
	main_menu.project_ctr = project_ctr
	main_menu.quick_open()
	
#--------------------------------------------------------------------------------------------------
func _notification(what):
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			quit()

#--------------------------------------------------------------------------------------------------
func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return 
	if not event.is_pressed():
		return 
	event = event as InputEventKey
	
	if Input.is_action_just_pressed("undo"):
		if project_ctr.undoredo.has_undo():
			print("undo:",project_ctr.undoredo.get_current_action_name())
			project_ctr.undoredo.undo()
	elif Input.is_action_just_pressed("redo"):
		if project_ctr.undoredo.has_redo():
			print("redo",project_ctr.undoredo.get_current_action_name())
			project_ctr.undoredo.redo()

#--------------------------------------------------------------------------------------------------
func connect_message_handler(sender, handler):
	assert(handler.has_method("handle_message"))
	sender.message_sended.connect(func(msg):
		prints(sender, "[Send]:", msg, "[To]:", handler)
		handler.handle_message(msg)
	)

#--------------------------------------------------------------------------------------------------
func quit():
	main_menu.save_current()
	get_tree().quit()
	

			







