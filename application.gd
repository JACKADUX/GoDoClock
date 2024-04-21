extends Control

@onready var tree = %Tree
var pdc = ProjectDataContoller.new()
@onready var button_add_item = %ButtonAddItem

func _ready() -> void:
	connect_message_handler(pdc, tree)
	connect_message_handler(tree, pdc)
	
	button_add_item.pressed.connect(func():
		var project_data = pdc.get_project_data()
		var todo = project_data.new_todo_data("Todo")
		pdc.send_message(ProjectMessage.NewMessage.new([todo]))	
	)
	
	AssetUtils.init_paths()
	var path = AssetUtils.get_root_path() +"/test.json"
	var project_data = pdc.get_project_data()
	if FileAccess.file_exists(path):
		var data = JsonHelper.load_meta(path)
		pdc.deserialization(data)
		project_data = pdc.get_project_data()
		#project_data = ResourceLoader.load(path,  "ProjectDataContoller.ProjectData")
		#print(project_data)
	tree.init_with(project_data)
	
func _notification(what):
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			quit()

func connect_message_handler(sender, handler):
	assert(handler.has_method("handle_message"))
	sender.message_sended.connect(func(msg):
		prints(sender, "[Send]:", msg, "[To]:", handler)
		handler.handle_message(msg)
	)

func quit():
	var path = AssetUtils.get_root_path() +"/test.json"
	var data = pdc.serialization()
	JsonHelper.save_meta(path, data)
	get_tree().quit()

