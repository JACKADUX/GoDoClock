extends Control

@onready var main_menu = %MainMenu
@onready var tree = %Tree
@onready var label_pin = %LabelPin


var project_ctr = ProjectContoller.new()

#--------------------------------------------------------------------------------------------------
func _ready() -> void:
	main_menu.project_changed.connect(func(project):
		label_pin.text = project.get_title()
		project_ctr.set_project(project)
	)
	connect_message_handler(project_ctr, tree)
	connect_message_handler(tree, project_ctr)
		
	AssetUtils.init_paths()
	main_menu.project_ctr = project_ctr
	main_menu.quick_open()
	
#--------------------------------------------------------------------------------------------------
func _notification(what):
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			quit()

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
	

			







