extends Control

@onready var tree = %Tree
@onready var button_add_item = %ButtonAddItem
@onready var button_add_project = %ButtonAddProject
@onready var button_delet_project = %ButtonDeletProject
@onready var option_button_project = %OptionButtonProject

var pdc = ProjectDataContoller.new()
var project_paths := []
var project_index :int = 0

func _ready() -> void:
	connect_message_handler(pdc, tree)
	connect_message_handler(tree, pdc)
	
	button_add_item.pressed.connect(func():
		var project_data = pdc.get_project_data()
		var todo = project_data.new_todo_data("Todo")
		pdc.send_message(ProjectMessage.New.new([todo]))	
	)
	
	button_add_project.pressed.connect(func():
		_save_file(project_paths[project_index])
		var path = AssetUtils.get_root_path().path_join("test3.json")
		_save_file(path)
		reload_projects()
		project_index = project_paths.size()-1
		_load_file()
	
	)
	
	option_button_project.item_selected.connect(func(index:int):
		_save_file(project_paths[project_index])
		project_index = index
		_load_file()
	)
	
	AssetUtils.init_paths()
	reload_projects()
	_load_file()
	
func _notification(what):
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			quit()

func reload_projects():
	project_index = 0
	project_paths = AssetUtils.get_all_project_paths()
	option_button_project.clear()
	for project_path:String in project_paths:
		option_button_project.add_item(project_path.get_basename().get_file())
	

func _load_file():
	var path = project_paths[project_index]
	var project_data = pdc.get_project_data()
	if FileAccess.file_exists(path):
		var data = JsonHelper.load_meta(path)
		pdc.deserialization(data)
		project_data = pdc.get_project_data()
	pdc.initialize()

func _save_file(path:String):
	var data = pdc.serialization()
	JsonHelper.save_meta(path, data)

func connect_message_handler(sender, handler):
	assert(handler.has_method("handle_message"))
	sender.message_sended.connect(func(msg):
		prints(sender, "[Send]:", msg, "[To]:", handler)
		handler.handle_message(msg)
	)

func quit():
	_save_file(project_paths[project_index])
	get_tree().quit()

