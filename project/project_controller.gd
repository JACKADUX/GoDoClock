class_name ProjectContoller

signal message_sended(msg:BaseMessage)

const P_TODO_STATE:="state"
const P_BASE_TITLE:="title"

var project :BaseItem.ProjectItem
var pin:BaseItem

var undoredo:=UndoRedo.new()

#---------------------------------------------------------------------------------------------------
func _init():
	undoredo.max_steps = 50
	project = ItemFactory.new_project()

#---------------------------------------------------------------------------------------------------
func get_project() -> BaseItem:
	return project

#---------------------------------------------------------------------------------------------------
func set_project(value:BaseItem):
	project = value
	initialize()

#---------------------------------------------------------------------------------------------------
func set_pin(value:BaseItem):
	pin = value
	if not pin:
		pin = project
	
#---------------------------------------------------------------------------------------------------
func get_pin():
	if not pin:
		pin = project
	return pin
	
#---------------------------------------------------------------------------------------------------
func _to_string():
	return "<ProjectContoller>"

func get_item(id:String) -> BaseItem:
	return instance_from_id(int(id))

#---------------------------------------------------------------------------------------------------
func handle_message(msg:BaseMessage):
	
	if msg is ProjectActionMessage.BundleAction:
		undoredo.create_action(msg.action_name)
		for _msg in msg.messages:
			handle_message(_msg)
		undoredo.commit_action()
	
	elif msg is ProjectActionMessage.NewAction:
		var item = ItemFactory.create(msg.type)
		var drop = get_item(msg.drop_id)
		var parent
		match msg.section:
			0, 2: parent = drop
			-1, 1: parent = drop.get_parent()
				
		undoredo.create_action(str(msg))
		BaseHierarchy.undoredo_add(undoredo, item, parent, action_add, action_remove)
		BaseHierarchy.undoredo_drag(undoredo, 
									[item],  
									drop, 
									msg.section, # section,
									action_change_hierarchy  # CallBack
									)
		undoredo.commit_action()
		
	elif msg is ProjectActionMessage.DeletAction:
		var item := get_item(msg.id)
		var drop = item.get_prev()
		var section = 1
		if not drop:
			drop = item.get_parent()
			section = 2
		undoredo.create_action(str(msg))
		BaseHierarchy.undoredo_remove(undoredo, item, action_add, action_remove)
		undoredo.add_undo_method(action_change_hierarchy.bind(item, drop, section))
		undoredo.commit_action()
		
	elif msg is ProjectActionMessage.ChangePropertyAction:
		var item = get_item(msg.id)
		undoredo.create_action(str(msg))
		var pre_value = item.get(msg.key)
		undoredo.add_undo_method(action_change_property.bind(item, msg.key, pre_value))
		undoredo.add_do_method(action_change_property.bind(item, msg.key, msg.value))
		undoredo.commit_action()
		dirty_action_property_changed.call_deferred(item)
	
	elif msg is ProjectActionMessage.ChangeHierarchyAction:
		undoredo.create_action(str(msg))
		var drags = msg.drags.map(func(id): return get_item(id))
		var drop = get_item(msg.drop_id)
		BaseHierarchy.undoredo_drag(undoredo, 
									drags,  
									drop, 
									msg.section, # section,
									action_change_hierarchy  # CallBack
									)
		undoredo.commit_action()
	elif msg is ProjectActionMessage.PinAction:
		var item = get_item(msg.id)
		if msg._backward:
			item = item.get_parent()
		undoredo.create_action(str(msg))
		var prev = get_pin()
		undoredo.add_undo_method(action_change_pin.bind(prev))
		undoredo.add_do_method(action_change_pin.bind(item))
		undoredo.commit_action()
		
#---------------------------------------------------------------------------------------------------
func send_message(msg:BaseMessage):
	message_sended.emit(msg)

##==================================================================================================
func initialize():
	send_message(ProjectUpdateMessage.Initialize.new([project]))

#---------------------------------------------------------------------------------------------------
func action_add(item:BaseItem, parent:BaseItem):
	parent.add_child(item)
	send_message(ProjectUpdateMessage.Add.new([item, parent.get_id()]))
	
#---------------------------------------------------------------------------------------------------
func action_remove(item:BaseItem):
	item.remove()
	send_message(ProjectUpdateMessage.Remove.new([item.get_id()]))

#---------------------------------------------------------------------------------------------------
func action_change_property(item:BaseItem, key:String, value) -> bool:
	if not item:
		return false
	if item.get(key) == value:
		return false
	item.set(key, value)
	send_message(ProjectUpdateMessage.PropertyUpdated.new([item.get_id(), key, value]))
	return true
	
#---------------------------------------------------------------------------------------------------
func action_change_hierarchy(drag:BaseItem, drop:BaseItem, section:BaseHierarchy.DragDrop):
	if not drag or not drop:
		return 
	if drag.drag_to(drop, section) == OK:
		send_message(ProjectUpdateMessage.HierarchyUpdated.new([drag.get_id(), drop.get_id(), section]))

#---------------------------------------------------------------------------------------------------
func action_change_pin(item:BaseItem):
	set_pin(item)
	send_message(ProjectUpdateMessage.PinUpdated.new([get_pin()]))

#---------------------------------------------------------------------------------------------------
func dirty_action_property_changed(item:BaseItem):
	var parent = item.get_parent()
	if parent is BaseItem.TodoItem:
		var check = true
		for child in parent.get_children():
			if child is BaseItem.TodoItem and not child.get_state():
				check = false
				break
		if action_change_property(parent, P_TODO_STATE, check):
			dirty_action_property_changed(parent)




