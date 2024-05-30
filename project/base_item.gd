class_name BaseItem extends UniformData

var title:String=""
var datetime:String = ""
var fold_state := false

func _init():
	update_current_datetime()
	title = datetime

#---------------------------------------------------------------------------------------------------
func get_fold_state():
	return fold_state

#---------------------------------------------------------------------------------------------------
func set_title(value:String):
	title = value
	
#---------------------------------------------------------------------------------------------------
func get_title():
	return title

#---------------------------------------------------------------------------------------------------
func update_current_datetime():	
	# Time.get_datetime_dict_from_datetime_string()
	datetime = Time.get_datetime_string_from_datetime_dict(Time.get_datetime_dict_from_system(), true)

#---------------------------------------------------------------------------------------------------
func get_datetime():
	return datetime
	
#---------------------------------------------------------------------------------------------------
func remove():
	get_parent().remove_child(self)

#---------------------------------------------------------------------------------------------------
func deserialization(value:Dictionary):
	set_title(value.get("title", ""))
	datetime = value.get("datetime","")
	fold_state = value.get("fold_state", false)
	
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
		"fold_state":fold_state
	}
	

		
#===================================================================================================
class GroupItem extends BaseItem:pass

#---------------------------------------------------------------------------------------------------
class ProjectItem extends BaseItem:
	var path := ""
	var pin:BaseItem
	
	func get_path():
		return path
	
	func set_path(value:String):
		path = value
		
	func set_pin(value:BaseItem):
		pin = value
	
	func get_pin(): 
		return pin
		
	func deserialization(value:Dictionary):
		super(value)
		path = value.get("path", "")
		# pin 需要在反序列化时获取
		
	func serialization() -> Dictionary:
		var data = super()
		data["path"] = get_path()
		if pin:
			data["pin_id"] = pin.get_id()
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

