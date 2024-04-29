
enum Type {ProjectData, TodoData}

var _factory :Factory
var _project_data:ProjectData

#---------------------------------------------------------------------------------------------------
func _init() -> void:
	_register()
	_project_data = new_project_data()


#---------------------------------------------------------------------------------------------------
func _to_string():
	return "ProjectDataContoller#"

#---------------------------------------------------------------------------------------------------
func initialize():
	send_message(ProjectMessage.Initialize.new([_project_data]))

#---------------------------------------------------------------------------------------------------
func create(type:Type) -> BaseData:
	var model = _factory.create(type)
	return model

#---------------------------------------------------------------------------------------------------
func delet(item:BaseData):
	item.get_parent().remove_child(item)
	send_message(ProjectMessage.Delete.new([item.get_id()]))
	
#---------------------------------------------------------------------------------------------------
func new_project_data()  -> ProjectData:
	return create(Type.ProjectData)

#---------------------------------------------------------------------------------------------------
func get_project_data() -> ProjectData:
	return _project_data

#---------------------------------------------------------------------------------------------------
func set_project_data(value:ProjectData):
	_project_data = value
	
#---------------------------------------------------------------------------------------------------
func get_item_by_id(value:String) -> BaseData:
	if not value:
		return null
	return instance_from_id(int(value))

#---------------------------------------------------------------------------------------------------
func change_property(item:BaseData, property:String, value):
	if item.get(property) == null:
		push_error("not existing property '%s' in '%s'"%[property, item])
	if not item or item.get(property) == value:
		return 
	item.set(property, value)
	send_message(ProjectMessage.ChangeProperty.new([item.get_id(), property, value]))

#---------------------------------------------------------------------------------------------------
func handle_message(msg:BaseMessage):
	if msg is ProjectMessage:
		handle_project_message(msg)
		
#---------------------------------------------------------------------------------------------------
func handle_project_message(msg:ProjectMessage):
	if not msg.is_request():
		return 
		
	if msg is ProjectMessage.ChangeProperty:
		change_property(get_item_by_id(msg.id), msg.property, msg.value)
		
	elif msg is ProjectMessage.Delete:
		delet(get_item_by_id(msg.id))
		
	elif msg is ProjectMessage.ChangeHierarchy:
		var drag = get_item_by_id(msg.drag_id)
		var drop = get_item_by_id(msg.drop_id)
		if not drag or not drop:
			return 
		if drag.drag_to(drop, msg.mode) == OK:
			send_message(ProjectMessage.ChangeHierarchy.new([msg.drag_id, msg.drop_id, msg.mode]))

#---------------------------------------------------------------------------------------------------
func send_message(msg:BaseMessage):
	message_sended.emit(msg)


