# 用于向下传递信息
class_name ProjectMessage extends BaseMessage.SimpleMessage


class Initialize extends ProjectMessage: 
	var project:BaseItem.GroupItem
	func _to_string():
		return "Initialize"


#
#const P_TODO_STATE:="state"
#const P_DATA_TITLE:="title"
#
#var _is_request:= false
#
##---------------------------------------------------------------------------------------------------
#func is_request():
	#return _is_request
#
##---------------------------------------------------------------------------------------------------
#func as_request(value:=true):
	#_is_request = value
	#return self
#
##---------------------------------------------------------------------------------------------------
#func _to_string():
	#var r = "[Request]" if is_request() else ""
	#return "%s<%s>"%[r, __str()]
#
##---------------------------------------------------------------------------------------------------
#func __str() -> String:
	#return ""
#
##---------------------------------------------------------------------------------------------------
##---------------------------------------------------------------------------------------------------
#class Initialize extends ProjectMessage: 
	#var project:ProjectContoller.ProjectData
	#func __str():
		#return "Initialize"
#
##---------------------------------------------------------------------------------------------------
#class New extends ProjectMessage: 
	#var model:ProjectDataContoller.BaseData
	#func __str():
		#return "New"
		#
##---------------------------------------------------------------------------------------------------
#class Delete extends ProjectMessage:
	#var id:String
	#func __str():
		#return "Delete"
#
##---------------------------------------------------------------------------------------------------
#class ChangeProperty extends ProjectMessage: 
	#var id:String
	#var property:String
	#var value
	#func __str():
		#return "ChangeProperty::property->%s"%[property]
#
##---------------------------------------------------------------------------------------------------
#class ChangeHierarchy extends ProjectMessage:
	#var drag_id:String
	#var drop_id:String
	#var mode:HierarchyData.DragDrop
	#func __str():
		#return "ChangeHierarchy::mode->%s"%[mode]
	#
	#
	#
	#
	#
