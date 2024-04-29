class_name ProjectContoller

signal message_sended(msg:BaseMessage)

var _project :BaseItem

var _undoredo:=UndoRedo.new()

#---------------------------------------------------------------------------------------------------
func _init():
	_undoredo.max_steps = 50
	_project = ItemFactory.new_group()

#---------------------------------------------------------------------------------------------------
func get_project() -> BaseItem:
	return _project

#---------------------------------------------------------------------------------------------------
func set_project(value:BaseItem):
	_project = value
	initialize()

#---------------------------------------------------------------------------------------------------
func _to_string():
	return "<ProjectContoller>"

#---------------------------------------------------------------------------------------------------
func handle_message(msg:BaseMessage):
	if msg is ProjectAction:
		pass

#---------------------------------------------------------------------------------------------------
func send_message(msg:BaseMessage):
	message_sended.emit(msg)



##==================================================================================================
func initialize():
	send_message(ProjectMessage.Initialize.new([_project]))


##==================================================================================================
func undoredo_warp(action_name:String, cmd_fn:Callable):
	_undoredo.create_action(action_name)
	cmd_fn.call()
	_undoredo.commit_action()
	















