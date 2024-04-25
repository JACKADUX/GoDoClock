class_name ProjectDataContoller

signal message_sended(msg:BaseMessage)

enum Type {ProjectData, TodoData}

var _factory :Factory
var _project_data:ProjectData

#---------------------------------------------------------------------------------------------------
func _init() -> void:
	_register()
	_project_data = new_project_data()

#---------------------------------------------------------------------------------------------------
func _register():
	_factory = Factory.new()
	var _regc := func(object:Object, type:Type, type_string:String):
		"""register_create"""
		var instance = object.new()
		instance._type = type
		instance._type_string = type_string
		return instance 
	_factory.register(Type.ProjectData, _regc.bind(ProjectData, Type.ProjectData, "ProjectData"))
	_factory.register(Type.TodoData, _regc.bind(TodoData, Type.TodoData, "TodoData"))
	
	BaseData.Type = Type
	BaseData.create_fn = create

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

#---------------------------------------------------------------------------------------------------
func serialization():
	var all_data = []
	for item in get_project_data().iterate():
		var data = item.get_data()
		all_data.append(data)
	return all_data

#---------------------------------------------------------------------------------------------------
func deserialization(data):
	var temp_map = {}
	var project_data
	for item_data in data:
		var model = create(item_data.type)
		temp_map[item_data.id] = model
		if not project_data:
			project_data = model
		var parent = temp_map.get(item_data.parent)
		if parent:
			parent.add_child(model)
		model.set_data(item_data)
	_project_data = project_data
	
	

#region Sub Classes
#---------------------------------------------------------------------------------------------------
class BaseData extends UniformData:
	static var Type
	static var create_fn:Callable
	
	@export var title:String=""
	
	func set_title(value:String):
		title = value
		
	func get_title():
		return title
	
	func set_data(value:Dictionary):
		set_title(value.get("title", ""))
	
	func get_data() -> Dictionary:
		var pid = null
		if get_parent():
			pid = get_parent().get_id()
			
		return {
			"id":get_id(),
			"type":get_type(),
			"parent":pid,
			"title":title,
		}
	
#---------------------------------------------------------------------------------------------------
class ProjectData extends BaseData:
	
	func new_todo_data(title:String=""):
		var data = create_fn.call(Type.TodoData)
		data.set_title(title)
		data.update_current_datetime()
		add_child(data)
		return data

#---------------------------------------------------------------------------------------------------
class TodoData extends BaseData:
	
	@export var state:= false
	@export var todo_meta:= {"datetime":""}
	
	func update_current_datetime():	
		# Time.get_datetime_dict_from_datetime_string()
		todo_meta.datetime = Time.get_datetime_string_from_datetime_dict(Time.get_datetime_dict_from_system(), true)
	
	func get_datetime():
		return todo_meta.get("datetime", "")
	
	func get_todo_meta():
		return todo_meta
	
	func get_state():
		return state
	
	func set_data(value:Dictionary):
		super(value)
		state = value.get("state", false)
		todo_meta = value.get("todo_meta", {})
		
	func get_data() -> Dictionary:
		var data = super()
		data["state"] = get_state()
		data["todo_meta"] = get_todo_meta()
		return data
	
#endregion
