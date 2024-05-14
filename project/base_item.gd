class_name BaseItem extends UniformData

var title:String=""
var datetime:String = ""

func _init():
	update_current_datetime()
	title = datetime

#---------------------------------------------------------------------------------------------------
func set_title(value:String):
	title = value
	
#---------------------------------------------------------------------------------------------------
func get_title():
	return title

#---------------------------------------------------------------------------------------------------
func remove():
	get_parent().remove_child(self)

#---------------------------------------------------------------------------------------------------
func deserialization(value:Dictionary):
	set_title(value.get("title", ""))
	datetime = value.get("datetime","")

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
		"datetime":datetime,
	}
	
#---------------------------------------------------------------------------------------------------
func update_current_datetime():	
	# Time.get_datetime_dict_from_datetime_string()
	datetime = Time.get_datetime_string_from_datetime_dict(Time.get_datetime_dict_from_system(), true)

#---------------------------------------------------------------------------------------------------
func get_datetime():
	return datetime
		
#===================================================================================================
class GroupItem extends BaseItem:pass

#---------------------------------------------------------------------------------------------------
class ProjectItem extends BaseItem:
	var path := ""
	
	func get_path():
		return path
	
	func set_path(value:String):
		path = value
		
	func deserialization(value:Dictionary):
		super(value)
		path = value.get("path", "")
		
	func serialization() -> Dictionary:
		var data = super()
		data["path"] = get_path()
		return data
	
#---------------------------------------------------------------------------------------------------
class TodoItem extends BaseItem:
	
	var state:= false
		
	func get_state():
		return state
	
	func deserialization(value:Dictionary):
		super(value)
		state = value.get("state", false)
		
	func serialization() -> Dictionary:
		var data = super()
		data["state"] = get_state()
		return data

