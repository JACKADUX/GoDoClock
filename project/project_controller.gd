class_name ProjectContoller

signal message_sended(msg:BaseMessage)

const P_TODO_STATE:="state"
const P_BASE_TITLE:="title"

var project :BaseItem
var pin:BaseItem

var undoredo:=UndoRedo.new()

#---------------------------------------------------------------------------------------------------
func _init():
	undoredo.max_steps = 50
	project = ItemFactory.new_group()

#---------------------------------------------------------------------------------------------------
func get_project() -> BaseItem:
	return project

#---------------------------------------------------------------------------------------------------
func set_project(value:BaseItem):
	project = value
	initialize()

#---------------------------------------------------------------------------------------------------
func set_pint(value:BaseItem):
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

func get_item(id:String):
	return instance_from_id(int(id))

#---------------------------------------------------------------------------------------------------
func handle_message(msg:BaseMessage):
	if msg is ProjectAction.NewAction:
		var item = ItemFactory.create(msg.type)
		var parent = get_item(msg.parent_id)
		undoredo.create_action(str(msg))
		BaseHierarchy.undoredo_add(undoredo, item, parent, action_add, action_remove)
		undoredo.commit_action()
		#BaseHierarchy.print_tree(project)
	elif msg is ProjectAction.DeletAction:
		var item = get_item(msg.id)
		undoredo.create_action(str(msg))
		BaseHierarchy.undoredo_remove(undoredo, item, action_add, action_remove)
		undoredo.commit_action()
		
	elif msg is ProjectAction.ChangePropertyAction:
		var item = get_item(msg.id)
		undoredo.create_action(str(msg))
		var pre_value = item.get(msg.key)
		undoredo.add_undo_method(action_change_property.bind(item, msg.key, pre_value))
		undoredo.add_do_method(action_change_property.bind(item, msg.key, msg.value))
		undoredo.commit_action()
	
	elif msg is ProjectAction.ChangeHierarchyAction:
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
	elif msg is ProjectAction.PinAction:
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
	send_message(ProjectMessage.Initialize.new([project]))

#---------------------------------------------------------------------------------------------------
func action_add(item:BaseItem, parent:BaseItem):
	parent.add_child(item)
	send_message(ProjectMessage.Add.new([item, parent.get_id()]))
	
#---------------------------------------------------------------------------------------------------
func action_remove(item:BaseItem):
	item.remove()
	send_message(ProjectMessage.Remove.new([item.get_id()]))

#---------------------------------------------------------------------------------------------------
func action_change_property(item:BaseItem, key:String, value):
	if not item:
		return 
	if item.get(key) == value:
		return 
	item.set(key, value)
	send_message(ProjectMessage.PropertyUpdated.new([item.get_id(), key, value]))

#---------------------------------------------------------------------------------------------------
func action_change_hierarchy(drag:BaseItem, drop:BaseItem, section:BaseHierarchy.DragDrop):
	if not drag or not drop:
		return 
	if drag.drag_to(drop, section) == OK:
		send_message(ProjectMessage.HierarchyUpdated.new([drag.get_id(), drop.get_id(), section]))

#---------------------------------------------------------------------------------------------------
func action_change_pin(item:BaseItem):
	set_pint(item)
	send_message(ProjectMessage.PinUpdated.new([get_pin()]))







