# 用于向上传递命令请求
class_name ProjectActionMessage extends BaseMessage.SimpleMessage

var _is_process:bool=false
func as_process(value:=true):
	_is_process = value
	return self
func is_process():
	return _is_process
	
#---------------------------------------------------------------------------------------------------
class BundleAction extends ProjectActionMessage:
	# 可以将其他的action 作为 bundle 一起发送
	# undoredo只会记录一次
	var action_name:String=""
	var messages : Array = []
	func _to_string():
		return "BundleAction"
		
	func add_action(msg:ProjectActionMessage):
		messages.append(msg)
		
	static func empty(name:String):
		return BundleAction.new([name, []])
	
#---------------------------------------------------------------------------------------------------
class NewAction extends ProjectActionMessage:
	var type:int
	var drop_id:String
	var section: int  # -> BaseHierarchy.DragDrop
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
	
	static func create_todo_state(_id:String, _value):
		return ChangePropertyAction.new([_id, ProjectContoller.P_TODO_STATE, _value])
	
	static func create_base_title(_id:String, _value):
		return ChangePropertyAction.new([_id, ProjectContoller.P_BASE_TITLE, _value])
	
	static func create_base_fold_state(_id:String, _value):
		return ChangePropertyAction.new([_id, ProjectContoller.P_BASE_FOLD_STATE, _value])
		
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
	




















