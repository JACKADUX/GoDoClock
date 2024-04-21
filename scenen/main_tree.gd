extends Tree

signal message_sended(msg:BaseMessage)

enum Column {
	CHECKED,
	TITLE,
}

var id_map := {}

#---------------------------------------------------------------------------------------------------
func _ready():	
	item_edited.connect(func():
		var item = get_edited()
		send_property_changed(item, ProjectMessage.P_TODO_STATE, item.is_checked(Column.CHECKED))
		send_property_changed(item, ProjectMessage.P_DATA_TITLE, get_item_title(item))
	)
	item_activated.connect(func():
		var item = get_selected()
		if not item:
			return
		edit_selected(true)
	)
	
	hide_root = true
	column_titles_visible = false
	columns = Column.size()
	set_column_expand(Column.CHECKED, false)
	
#---------------------------------------------------------------------------------------------------
func _unhandled_key_input(event):
	if event.is_action_pressed("ui_graph_delete"):
		var item = get_selected()
		if not item:
			return
		send_message(ProjectMessage.RequestDeleteMessage.new([get_item_id(item)]))
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("tree_move_up"):
		var item = get_selected()
		if not item:
			return 
		var drop = item.get_prev()
		if not drop:
			return 
		send_message(ProjectMessage.RequestChangeHierarchyMessage.new([get_item_id(item), get_item_id(drop), -1]))
		get_viewport().set_input_as_handled()
		
	elif event.is_action_pressed("tree_move_down"):
		var item = get_selected()
		if not item:
			return 
		var drop = item.get_next()
		if not drop:
			return 
		send_message(ProjectMessage.RequestChangeHierarchyMessage.new([get_item_id(item), get_item_id(drop), 1]))
		get_viewport().set_input_as_handled()
	
#---------------------------------------------------------------------------------------------------
func get_item_id(item:TreeItem) -> String:
	if not item:
		return ""
	return item.get_meta("id")

#---------------------------------------------------------------------------------------------------
func get_item_by_id(id:String) -> TreeItem:
	if id_map.has(id):
		return instance_from_id(id_map[id])
	return null
	
#---------------------------------------------------------------------------------------------------
func init_with(project:ProjectDataContoller.ProjectData):
	clear()
	id_map = {}
	create_item()
	if not project:
		return 
	for child in project.get_children():
		new_item(child)

#---------------------------------------------------------------------------------------------------
func delet_item(item:TreeItem):
	item.get_parent().remove_child(item)
	item.free()

#---------------------------------------------------------------------------------------------------
func new_item(data:ProjectDataContoller.BaseData):
	if data is ProjectDataContoller.TodoData:
		new_todo_item(data.get_id(), data.get_title(), data.get_state(), data.get_datetime())

#---------------------------------------------------------------------------------------------------
func new_todo_item(id:String, title:String="Default", check:=false, tooltips="") -> TreeItem:
	var item = get_root().create_child()
	item.set_cell_mode(Column.CHECKED, TreeItem.CELL_MODE_CHECK)
	item.set_editable(Column.CHECKED, true)
	item.set_selectable(Column.CHECKED, false)
	item.set_meta("id", id)
	item.set_tooltip_text(Column.TITLE, tooltips)
	id_map[id] = item.get_instance_id()
	
	set_item_title(item, title)
	set_item_checked(item, check)
	return item

#---------------------------------------------------------------------------------------------------
func get_item_title(item:TreeItem):
	return item.get_text(Column.TITLE)
				
#---------------------------------------------------------------------------------------------------
func set_item_title(item:TreeItem, value:String):
	item.set_text(Column.TITLE, value)
	
#---------------------------------------------------------------------------------------------------
func handle_message(msg:BaseMessage):
	if msg is ProjectMessage.ChangePropertyMessage:
		var item = get_item_by_id(msg.id)
		if not item:
			return 
		match msg.property:
			ProjectMessage.P_TODO_STATE:
				set_item_checked(item, msg.value)
			ProjectMessage.P_DATA_TITLE:
				set_item_title(item, msg.value)
				
	elif msg is ProjectMessage.NewMessage:
		new_item(msg.model)
		
	elif msg is ProjectMessage.DeletedMessage:
		delet_item(get_item_by_id(msg.id))
		
	elif msg is ProjectMessage.ChangeHierarchyMessage:
		var drag = get_item_by_id(msg.drag_id)
		var drop = get_item_by_id(msg.drop_id)
		match msg.mode:
			-1:
				drag.move_before(drop)
			0:	
				drag.get_parent().remove_child(drag)
				drop.add_child(drag)
			1:
				drag.move_after(drop)
			_:
				push_error("not valid mod %d"%msg.mode)

		
#---------------------------------------------------------------------------------------------------
func set_item_checked(item:TreeItem, value:bool):
	item.set_checked(Column.CHECKED, value)

#---------------------------------------------------------------------------------------------------
func send_message(msg:BaseMessage):
	message_sended.emit(msg)

#---------------------------------------------------------------------------------------------------
func send_property_changed(item:TreeItem, property:String, value):
	send_message(ProjectMessage.RequestChangePropertyMessage.new([get_item_id(item), property, value]))
	
#---------------------------------------------------------------------------------------------------






















