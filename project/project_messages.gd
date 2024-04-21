class_name ProjectMessage extends BaseMessage.SimpleMessage

const P_TODO_STATE:="state"
const P_DATA_TITLE:="title"

#---------------------------------------------------------------------------------------------------
class NewMessage extends ProjectMessage: 
	var model:ProjectDataContoller.BaseData
	func _to_string():
		return "< NewMessage >"
		
#---------------------------------------------------------------------------------------------------
class RequestDeleteMessage extends ProjectMessage:
	var id:String
	func _to_string():
		return "< RequestDeleteMessage >"
		
#---------------------------------------------------------------------------------------------------
class DeletedMessage extends ProjectMessage:
	var id:String
	func _to_string():
		return "< DeletedMessage >"

#---------------------------------------------------------------------------------------------------
class RequestChangePropertyMessage extends ProjectMessage:
	var id:String
	var property:String
	var value
	func _to_string():
		return "< RequestChangePropertyMessage::property->%s >"%[property]

#---------------------------------------------------------------------------------------------------
class ChangePropertyMessage extends ProjectMessage: 
	var id:String
	var property:String
	var value
	func _to_string():
		return "< ChangePropertyMessage::property->%s >"%[property]

#---------------------------------------------------------------------------------------------------
class RequestChangeHierarchyMessage extends ProjectMessage:
	var drag_id:String
	var drop_id:String
	var mode:HierarchyData.DragDrop
	func _to_string():
		return "< RequestChangeHierarchyMessage::mode->%s >"%[mode]
	
#---------------------------------------------------------------------------------------------------
class ChangeHierarchyMessage extends ProjectMessage:
	var drag_id:String
	var drop_id:String
	var mode:HierarchyData.DragDrop
	func _to_string():
		return "< ChangeHierarchyMessage::mode->%s >"%[mode]	
	
	
	
	
	
