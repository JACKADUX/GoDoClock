# 用于向上传递命令请求
class_name ProjectActionMessage extends BaseMessage.SimpleMessage

var _is_process:bool
func as_process(value:=true):
	_is_process = value
	return self
func is_process():
	return _is_process
	
#---------------------------------------------------------------------------------------------------
class NewAction extends ProjectActionMessage:
	var type:int
	var parent_id:String
	func _to_string():
		return "NewAction"

#---------------------------------------------------------------------------------------------------
class DeletAction extends ProjectActionMessage:
	var id:String
	func _to_string():
		return "DeletAction"

#---------------------------------------------------------------------------------------------------
class ChangePropertyAction extends ProjectActionMessage:
	var id:String
	var key:String
	var value
	func _to_string():
		return "ChangePropertyAction"
	
	static func create_todo_state(id:String, value):
		return ChangePropertyAction.new([id, ProjectContoller.P_TODO_STATE, value])
	
	static func create_base_title(id:String, value):
		return ChangePropertyAction.new([id, ProjectContoller.P_BASE_TITLE, value])

#---------------------------------------------------------------------------------------------------
class ChangeHierarchyAction extends ProjectActionMessage:
	var drags: Array #-> get_data
	var drop_id: String
	var section: int  # -> BaseHierarchy.DragDrop
	func _to_string():
		return "ChangeHierarchy"

#---------------------------------------------------------------------------------------------------
class PinAction extends ProjectActionMessage:
	var id:String
	var _backward := false
	func _to_string():
		return "ChangeHierarchy"
	
	static func unpin_all():
		return PinAction.new([""])
	
	func as_backward():
		_backward = true
		return self
	




















