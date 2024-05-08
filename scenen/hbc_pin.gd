class_name PinHeader extends HBoxContainer

signal message_sended(msg:BaseMessage)

@onready var label_pin = %LabelPin
@onready var line_edit_title = %LineEditTitle

var path_list := []

var _edit_active := false

func _ready():
	line_edit_title.text_submitted.connect(func(v):
		finish_edit_title()
	)
	
func _input(event):
	if _edit_active:
		if event is InputEventMouseButton and event.is_pressed():
			if not line_edit_title.get_global_rect().has_point(get_global_mouse_position()):
				finish_edit_title()

func _gui_input(event):
	if Input.is_action_just_released("mouse_right"):
		if path_list.size() > 1:
			create_context_menu()
	if event is InputEventMouseButton and event.double_click:
		start_edit_title()
		
		
			
#---------------------------------------------------------------------------------------------------
func create_context_menu():
	var popup = PopupMenu.new()
	add_child(popup)
	var _path_list = path_list.duplicate()
	_path_list.pop_back()
	for list in _path_list:
		popup.add_item(list[1])
	popup.index_pressed.connect(func(index:int):
		var id = _path_list[index][0]
		send_message(ProjectActionMessage.PinAction.new([id]))
		popup.queue_free()
	)
	popup.close_requested.connect(func():
		popup.queue_free()
	)
	popup.position = Vector2(DisplayServer.window_get_position(0)) + get_global_mouse_position()
	popup.size = Vector2(100,0)
	popup.show()
	return popup

#---------------------------------------------------------------------------------------------------
func handle_message(msg:BaseMessage):
	if msg is ProjectUpdateMessage.Initialize:
		path_list = [[msg.project.get_id(), msg.project.get_title()]]
		update_title()
	
	elif msg is ProjectUpdateMessage.PinUpdated:
		var item = msg.pin as BaseItem
		var path_to_parent = item.path_to_root(true, true)
		path_list = []
		for _item in path_to_parent:
			var title :String = _item.get_title()
			path_list.append([_item.get_id(), title])
		update_title()
		
#---------------------------------------------------------------------------------------------------
func update_title():
	var first_name = path_list[0][1]
	var last_name = path_list[-1][1]
	if path_list.size()==1:
		label_pin.text = first_name
	elif path_list.size()==2:
		label_pin.text = "%s / %s"%[first_name, last_name]
	elif path_list.size()>2:
		label_pin.text = "%s /%s/ %s"%[first_name,".".repeat(path_list.size()-2) ,last_name]
			
#---------------------------------------------------------------------------------------------------
func send_message(msg:BaseMessage):
	message_sended.emit(msg)

#---------------------------------------------------------------------------------------------------
func start_edit_title():
	_edit_active = true
	label_pin.hide()
	line_edit_title.show()
	line_edit_title.grab_focus()
	line_edit_title.text = path_list[0][1]
	line_edit_title.select_all()
	
func finish_edit_title():
	_edit_active = false
	label_pin.show()
	line_edit_title.hide()
	var id = path_list[0][0]
	path_list[0][1] = line_edit_title.text
	send_message(ProjectActionMessage.ChangePropertyAction.create_base_title(id, line_edit_title.text))
	update_title()
