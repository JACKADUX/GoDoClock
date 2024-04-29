class_name BaseItem extends UniformData

var _debug_value :int = 0
var title:String=""

#---------------------------------------------------------------------------------------------------
func set_title(value:String):
	title = value
	
#---------------------------------------------------------------------------------------------------
func get_title():
	return title

#---------------------------------------------------------------------------------------------------
func deserialization(value:Dictionary):
	set_title(value.get("title", ""))

#---------------------------------------------------------------------------------------------------
func serialization() -> Dictionary:
	var pid = null
	if get_parent():
		pid = get_parent().get_id()
		
	return {
		"id":get_id(),
		"type":get_type(),
		"pid":pid,
		"title":title,
	}
	


#===================================================================================================
class GroupItem extends BaseItem:pass

#---------------------------------------------------------------------------------------------------
class TodoItem extends BaseItem:
	
	var state:= false
	var todo_meta:= {"datetime":""}
	
	func update_current_datetime():	
		# Time.get_datetime_dict_from_datetime_string()
		todo_meta.datetime = Time.get_datetime_string_from_datetime_dict(Time.get_datetime_dict_from_system(), true)
	
	func get_datetime():
		return todo_meta.get("datetime", "")
	
	func get_todo_meta():
		return todo_meta
	
	func get_state():
		return state
	
	func deserialization(value:Dictionary):
		super(value)
		state = value.get("state", false)
		todo_meta = value.get("todo_meta", {})
		
	func serialization() -> Dictionary:
		var data = super()
		data["state"] = get_state()
		data["todo_meta"] = get_todo_meta()
		return data

