extends Tree

signal message_sended(msg:BaseMessage)

const ICON_CHECK_0 = preload("res://resource/icons/check_0.png")
const ICON_CHECK_1 = preload("res://resource/icons/check_1.png")
const ICON_CHECK_SIGN = preload("res://resource/icons/check_sign.png")
const ICON_PIN = preload("res://resource/icons/pin.png")
var ICON_EMPTY = ImageTexture.new()

var COLOR_CHECKED := Globals.MAIN_COLOR
const COLOR_HOVERED := Color("282828")

enum Column {
	TITLE,
}

var id_map := {}

enum PopupId {
	Pin,
	UnPin,
	Check,
	NewGroup,
	NewTodo,
	Delete,
	MoveToFirst,
	MoveUp,
	MoveDown,
	MoveToLast,
}

enum Buttons {
	PIN,
	CHECK,
}

const META_ID_KEY := "id"
const META_ID_CHECKED := "check"

var _mouse_clicked_inside := false
var _pin_root :TreeItem
var _hovered :TreeItem

#---------------------------------------------------------------------------------------------------
func _ready():	
	item_collapsed.connect(func(_item:TreeItem):
		send_message(ProjectActionMessage.ChangePropertyAction.create_base_fold_state(get_item_id(_item), _item.collapsed))
	)
	item_activated.connect(func():
		var selected = get_next_selected(null)
		if not selected:
			return
		edit_selected(true)
	)
	item_edited.connect(func():
		var item = get_edited()
		send_message(ProjectActionMessage.ChangePropertyAction.create_base_title(get_item_id(item), get_item_title(item)))	
	)
	button_clicked.connect(func(item: TreeItem, _column: int, id: int, _mouse_button_index: int):
		_mouse_clicked_inside = false # 取消右击
		match id:
			Buttons.CHECK:
				var selects = get_all_selected_items()
				if item not in selects:
					send_message(ProjectActionMessage.ChangePropertyAction.create_todo_state(get_item_id(item), not get_item_checked(item)))
				else:
					var check = not get_item_checked(item)
					var bundle_msg = ProjectActionMessage.BundleAction.empty("Check")
					for _item in selects:
						var msg = ProjectActionMessage.ChangePropertyAction.create_todo_state(get_item_id(_item), check)
						bundle_msg.add_action(msg)
					send_message(bundle_msg)
						
			Buttons.PIN:
				send_message(ProjectActionMessage.PinAction.new([get_item_id(item)]))
	)

	multi_selected.connect(func(item: TreeItem, _column: int, selected: bool):
		if selected and item == _hovered:
			item.clear_custom_bg_color(Column.TITLE)
	)
	empty_clicked.connect(func(_1, _2):
		deselect_all()
	)
	
	hide_root = true
	column_titles_visible = false
	columns = Column.size()
	allow_rmb_select = true
	allow_search = false
	select_mode = SELECT_MULTI

#---------------------------------------------------------------------------------------------------
func _gui_input(event):	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		_mouse_clicked_inside = true
		
	if event is InputEventMouseMotion:
		var item = get_item_at_position(get_local_mouse_position())
		if _hovered == item:
			return 
		if _hovered:
			set_hovered(_hovered, false)
		if item:
			set_hovered(item, true)
		_hovered = item
		
#---------------------------------------------------------------------------------------------------
func _process(_delta):
	# 选择treeitem会发生在gui_inpu结束后 Input.is_action_just_pressed 调用之前
	# 所以需要用这种奇怪的方法执行
	if Input.is_action_just_released("mouse_right") and _mouse_clicked_inside:
		_mouse_clicked_inside = false
		create_context_menu()
		
#---------------------------------------------------------------------------------------------------
func _unhandled_key_input(event):
	if event.is_action_pressed("ui_graph_delete"):
		_on_context_called(PopupId.Delete)
		get_viewport().set_input_as_handled()
	
	elif event.is_action_pressed("new_todo"):
		_on_context_called(PopupId.NewTodo)
		get_viewport().set_input_as_handled()
		
	elif event.is_action_pressed("pin_unpin"):
		var selects = get_all_selected_items()
		if selects.size() == 1:
			_on_context_called(PopupId.Pin)
		elif selects.size() == 0:
			_on_context_called(PopupId.UnPin)
		else:
			return 
		get_viewport().set_input_as_handled()
		
	elif event.is_action_pressed("check_uncheck"):
		_on_context_called(PopupId.Check)
		get_viewport().set_input_as_handled()
		
	elif event.is_action_pressed("move_to_first"):
		_on_context_called(PopupId.MoveToFirst)
		get_viewport().set_input_as_handled()

		
	elif event.is_action_pressed("move_to_last"):
		_on_context_called(PopupId.MoveToLast)
		get_viewport().set_input_as_handled()
	
			
	elif event.is_action_pressed("move_up"):
		_on_context_called(PopupId.MoveUp)
		get_viewport().set_input_as_handled()
		
	elif event.is_action_pressed("move_down"):
		_on_context_called(PopupId.MoveDown)
		get_viewport().set_input_as_handled()
		
#---------------------------------------------------------------------------------------------------
func create_context_menu():
	var selects = get_all_selected_items()
	var popup = PopupMenu.new()
	add_child(popup)
	popup.add_item("Create Todo", PopupId.NewTodo, KEY_T)
	if not selects and _pin_root:
		popup.add_separator()
		popup.add_item("UnPin", PopupId.UnPin, KEY_P)
	if selects:
		popup.add_separator()
		if selects.size() == 1:
			popup.add_item("Pin", PopupId.Pin, KEY_P)
		popup.add_item("Check", PopupId.Check, KEY_C)
		popup.add_separator()
		popup.add_item("Move to First", PopupId.MoveToFirst, KEY_MASK_CTRL | KEY_BRACKETLEFT)
		popup.add_item("Move Up", PopupId.MoveUp, KEY_BRACKETLEFT)
		popup.add_item("Move Down", PopupId.MoveDown, KEY_BRACKETRIGHT)
		popup.add_item("Move to Last", PopupId.MoveToLast, KEY_MASK_CTRL | KEY_BRACKETRIGHT)
		popup.add_separator()
		popup.add_item("Delete", PopupId.Delete, KEY_DELETE)
	popup.id_pressed.connect(func(id:int):
		_on_context_called(id)
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
func _on_context_called(id:int):
	var selects = get_all_selected_items()
	match id:
		PopupId.Pin:
			if selects.size() != 1:
				return 
			send_message(ProjectActionMessage.PinAction.new([get_item_id(selects[0])]))
			
		PopupId.UnPin:
			if selects.size() != 0:
				return 
			send_message(ProjectActionMessage.PinAction.new([get_item_id(get_root())]).as_backward())
			
		PopupId.NewTodo:
			var drop
			var section
			if not selects:
				drop = get_root()
				section = 2
			else:
				drop = selects[0]
				section = 1
				
			send_message(ProjectActionMessage.NewAction.new([ItemFactory.ItemType.Todo, get_item_id(drop), section]))

		PopupId.Delete:
			if not selects:
				return 
			var bundle_msg = ProjectActionMessage.BundleAction.empty("DeletAction")
			for _item in selects:
				var msg = ProjectActionMessage.DeletAction.new([get_item_id(_item)])
				bundle_msg.add_action(msg)
			send_message(bundle_msg)
			
		PopupId.Check:
			if not selects:
				return 
			var check = not get_item_checked(selects[0])
			var bundle_msg = ProjectActionMessage.BundleAction.empty("ChangePropertyAction")
			for _item in selects:
				var msg = ProjectActionMessage.ChangePropertyAction.create_todo_state(get_item_id(_item), check)
				bundle_msg.add_action(msg)
			send_message(bundle_msg)
		
		PopupId.MoveToFirst, PopupId.MoveToLast:
			if not selects:
				return 
			
			var drags :Array = []
			var drop_item = selects[0].get_parent()
			var section = 2 if id == PopupId.MoveToFirst else 0

			for drag in selects:
				if get_item_id(drag.get_parent()) in drags:
					continue
				drags.append(get_item_id(drag))
			
			var args = [drags, get_item_id(drop_item), section]
			send_message(ProjectActionMessage.ChangeHierarchyAction.new(args))
			
		PopupId.MoveUp: 
			if not selects:
				return 
			var drags :Array = []
			var drop_item = selects[0].get_prev()
			var section = -1
			if not drop_item:
				drop_item = selects.pop_front()
				section = 1
					
			for drag in selects:
				if get_item_id(drag.get_parent()) in drags:
					continue
				drags.append(get_item_id(drag))
			
			var args = [drags, get_item_id(drop_item), section]
			send_message(ProjectActionMessage.ChangeHierarchyAction.new(args))	
				
		PopupId.MoveDown: 
			if not selects:
				return 
			var drags :Array = []
			var drop_item = selects[0].get_next()
			var section = 1
			
			while drop_item:
				if drop_item not in selects:
					break
				drop_item = drop_item.get_next() 
			
			if not drop_item:
				drop_item = selects.pop_front()

			for drag in selects:
				if get_item_id(drag.get_parent()) in drags:
					continue
				drags.append(get_item_id(drag))
			
			var args = [drags, get_item_id(drop_item), section]
			send_message(ProjectActionMessage.ChangeHierarchyAction.new(args))	
				

#region Drag
#---------------------------------------------------------------------------------------------------
func _get_drag_data(at_position: Vector2):
	var item = get_item_at_position(at_position)
	if not item or not item.is_selected(Column.TITLE):
		return
	var items = get_all_selected_items()
	var data = {"drag_items":items}
	set_drag_preview(_make_drag_preview(items))
	return data
	
#---------------------------------------------------------------------------------------------------
func _can_drop_data(at_position, data):
	if not data:
		return
	data["can_drop"] = true
	var drop_item = get_item_at_position(at_position)
	if not drop_item:
		drop_mode_flags = DROP_MODE_DISABLED
		return true
		
	#var section = get_drop_section_at_position(at_position)
	#for drag_item in data.drag_items:
		#var args = [get_item_id(drag_item), get_item_id(drop_item), section]
		#send_message(ProjectUpdateMessage.CheckHierarchyAction.new(args))
	#
	drop_mode_flags = DROP_MODE_INBETWEEN | DROP_MODE_ON_ITEM
	for drag_item in data.drag_items:
		if drag_item == drop_item:
			drop_mode_flags = DROP_MODE_DISABLED	
			break
		elif _is_parent_child(drag_item, drop_item):
			drop_mode_flags = DROP_MODE_DISABLED	
			break
	
	if drop_mode_flags == DROP_MODE_DISABLED:
		data["can_drop"] = false
	data["drop_item"] = drop_item
	return true

#---------------------------------------------------------------------------------------------------
func _drop_data(at_position, data):
	if not data["can_drop"]:
		return 
	var section = get_drop_section_at_position(at_position)
	if section == -100:
		data.drop_item = get_root()
		section = 0
	var drags :Array = []
	for drag in data.drag_items:
		if get_item_id(drag.get_parent()) in drags:
			continue
		drags.append(get_item_id(drag))
	
	var args = [drags, get_item_id(data.drop_item), section]
	send_message(ProjectActionMessage.ChangeHierarchyAction.new(args))

#---------------------------------------------------------------------------------------------------
func _is_parent_child(parent_item, child_item):
	if child_item.get_parent() == parent_item:
		return true
	for child in parent_item.get_children():
		if _is_parent_child(child, child_item):
			return true
			
#---------------------------------------------------------------------------------------------------
func _make_drag_preview(items:Array):
	var panel_container = PanelContainer.new()
	panel_container.modulate.a = 0.4
	var margin_container := MarginContainer.new()
	panel_container.add_child(margin_container)
	margin_container.add_theme_constant_override("margin_left", 10)
	margin_container.add_theme_constant_override("margin_right", 10)
	margin_container.add_theme_constant_override("margin_top", 4)
	margin_container.add_theme_constant_override("margin_bottom", 4)
	var vbox = VBoxContainer.new()
	margin_container.add_child(vbox)
	var count = 0
	for item in items:
		count += 1
		var hbox = HBoxContainer.new()
		vbox.add_child(hbox)
		if count<= 5:
			var texture = TextureRect.new()
			texture.texture = item.get_icon(Column.TITLE)
			texture.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			var lable = Label.new()
			hbox.add_child(texture)
			hbox.add_child(lable)
			lable.text = item.get_text(Column.TITLE)
		else:
			var lable = Label.new()
			hbox.add_child(lable)
			lable.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lable.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			lable.text = "<<...%s...>>"%[len(items)]
			break
		
	return panel_container

#---------------------------------------------------------------------------------------------------
func drag_to(drag:TreeItem, drop:TreeItem, section:int):
	if not drop or not drag:
		return 
	if drop == drag:
		return 
	match section:
		-1:
			drag.move_before(drop)
		0: 
			if drag.get_parent():
				drag.get_parent().remove_child(drag)
			drop.add_child(drag)
			set_item_selected(drag, true)
		1:
			drag.move_after(drop)
		2: # UnderFirst
			if drag.get_parent():
				drag.get_parent().remove_child(drag)
			drop.add_child(drag)
			if drop.get_child_count() > 1:
				drag.move_before(drop.get_child(0))
			set_item_selected(drag, true)
		_:
			push_error("invalid section")

#endregion



#---------------------------------------------------------------------------------------------------
func get_item_id(item:TreeItem) -> String:
	return "" if not item else item.get_meta("id")

#---------------------------------------------------------------------------------------------------
func get_item(id:String) -> TreeItem:
	return null if not id_map.has(id) else instance_from_id(id_map[id])

#---------------------------------------------------------------------------------------------------
func delet_item(item:TreeItem):
	item.get_parent().remove_child(item)
	item.free()

#---------------------------------------------------------------------------------------------------
func init_tree(base_item:BaseItem):
	id_map = {}
	clear()
	if not base_item:
		return 
	var item = new_treeitem(base_item, null)
	# 必须要这样， 否则pin的时候会因为折叠而无法显示子部
	item.collapsed = false 
	# 任何一个不是项目根目录的对象都会有parent
	_pin_root = null if not base_item.get_parent() else item
		
#---------------------------------------------------------------------------------------------------
func new_treeitem(base_item:BaseItem, parent:TreeItem) -> TreeItem:
	var item = create_item(parent)
	# init data
	id_map[base_item.get_id()] = item.get_instance_id()
	item.set_meta(META_ID_KEY, base_item.get_id())
	item.collapsed = base_item.get_fold_state()
	if base_item is BaseItem.ProjectItem:
		init_project_item(item, base_item)
	elif base_item is BaseItem.TodoItem:
		init_todo_item(item, base_item)
	
	# iter
	for child:BaseItem in base_item.get_children():
		new_treeitem(child, item)
	return item

#---------------------------------------------------------------------------------------------------
func init_project_item(item:TreeItem, base_item:BaseItem.ProjectItem):
	item.set_icon(Column.TITLE, null)
	item.set_icon_modulate(Column.TITLE, COLOR_CHECKED)
	set_item_title(item, base_item.get_title())
	item.set_tooltip_text(Column.TITLE, base_item.get_title())

#---------------------------------------------------------------------------------------------------
func init_todo_item(item:TreeItem, base_item:BaseItem.TodoItem):
	item.set_icon(Column.TITLE, null)
	item.set_icon_modulate(Column.TITLE, COLOR_CHECKED)
	set_item_title(item, base_item.get_title())
	item.add_button(Column.TITLE, ICON_EMPTY, Buttons.PIN)
	item.add_button(Column.TITLE, ICON_CHECK_0, Buttons.CHECK)	
	set_item_checked(item, base_item.get_state())
	item.set_tooltip_text(Column.TITLE, base_item.get_title())
	
#---------------------------------------------------------------------------------------------------
func set_item_checked(item:TreeItem, value:bool):
	item.set_meta(META_ID_CHECKED, value)
	item.set_button(Column.TITLE, Buttons.CHECK, ICON_CHECK_0 if not value else ICON_CHECK_1 )
	item.set_button_color(Column.TITLE, Buttons.CHECK, Color.WHITE_SMOKE if not value else COLOR_CHECKED)
	item.set_icon(Column.TITLE, null if not value else ICON_CHECK_SIGN)
		
#---------------------------------------------------------------------------------------------------
func get_item_checked(item:TreeItem):
	return item.get_meta(META_ID_CHECKED)

#---------------------------------------------------------------------------------------------------
func get_item_title(item:TreeItem):
	return item.get_text(Column.TITLE)
				
#---------------------------------------------------------------------------------------------------
func set_item_title(item:TreeItem, value:String):
	item.set_text(Column.TITLE, value)
	
#---------------------------------------------------------------------------------------------------
func set_hovered(item:TreeItem, value:bool):
	if value:
		item.set_button(Column.TITLE, Buttons.PIN, ICON_PIN)
		if not item.is_selected(Column.TITLE):
			item.set_custom_bg_color(Column.TITLE, COLOR_HOVERED)
	else:
		item.clear_custom_bg_color(Column.TITLE)
		item.set_button(Column.TITLE, Buttons.PIN, ICON_EMPTY)
		
#---------------------------------------------------------------------------------------------------
func set_item_selected(item:TreeItem, value:bool):
	if value:
		item.select(Column.TITLE) 
	else:
		item.deselect(Column.TITLE)
	# NOTE:下面是为了关闭取消选择后对象的focus框
	# godot的多选永远都是从树的上面到下面的顺序执行
	var _selected = get_next_selected(null)
	if not _selected: 
		deselect_all()
	else:
		_selected.select(Column.TITLE)
		
#---------------------------------------------------------------------------------------------------
func get_all_selected_items() -> Array:
	var _items = []
	var selected = get_next_selected(null)
	while selected:
		_items.append(selected)
		selected = get_next_selected(selected)
	return _items	
	
#---------------------------------------------------------------------------------------------------
func send_message(msg:BaseMessage):
	message_sended.emit(msg)

	
#---------------------------------------------------------------------------------------------------
#---------------------------------------------------------------------------------------------------
func handle_message(msg:BaseMessage):
	if not msg is ProjectUpdateMessage:
		return
	
	if msg is ProjectUpdateMessage.Initialize:
		init_tree(msg.project)
	
	elif msg is ProjectUpdateMessage.PinUpdated:
		init_tree(msg.pin)
	
	elif msg is ProjectUpdateMessage.Add:
		var item := new_treeitem(msg.base_item, get_item(msg.parent_id))
			
	elif msg is ProjectUpdateMessage.Remove:
		var item := get_item(msg.id)
		delet_item(item)
	
	elif msg is ProjectUpdateMessage.PropertyUpdated:
		var item := get_item(msg.id)
		if not item:
			return 
		match msg.key:
			ProjectContoller.P_TODO_STATE:
				set_item_checked(item, msg.value)
			ProjectContoller.P_BASE_TITLE:
				set_item_title(item, msg.value)
			ProjectContoller.P_BASE_FOLD_STATE:
				item.collapsed = msg.value
				
	elif msg is ProjectUpdateMessage.HierarchyUpdated:
		var drag = get_item(msg.drag_id)
		var drop = get_item(msg.drop_id)
		drag_to(drag, drop, msg.section)




















