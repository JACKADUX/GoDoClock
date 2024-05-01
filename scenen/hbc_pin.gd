class_name PinHeader extends HBoxContainer

signal message_sended(msg:BaseMessage)

@onready var label_pin = %LabelPin

var path_list := []

func _gui_input(event):
	if Input.is_action_just_released("mouse_right"):
		if path_list.size() > 1:
			create_context_menu()
		
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
		send_message(ProjectAction.PinAction.new([id]))
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
	if msg is ProjectMessage.Initialize:
		path_list = [[msg.project.get_id(), msg.project.get_title().get_file()]]
		update_title()
	
	elif msg is ProjectMessage.PinUpdated:
		var item = msg.pin as BaseItem
		var path_to_parent = item.path_to_root(true, true)
		path_list = []
		for _item in path_to_parent:
			var title = _item.get_title()
			if not _item.get_parent():
				title = title.get_file()
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
