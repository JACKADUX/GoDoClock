# 用于向下传递信息
class_name ProjectMessage extends BaseMessage.SimpleMessage


class UpdateMessage extends ProjectMessage: pass

#---------------------------------------------------------------------------------------------------
class Initialize extends UpdateMessage: 
	var project:BaseItem.GroupItem
	func _to_string():
		return "Initialize"

#---------------------------------------------------------------------------------------------------
class Add extends UpdateMessage: 
	var base_item:BaseItem
	var parent_id:String
	func _to_string():
		return "Add"
		
#---------------------------------------------------------------------------------------------------
class Remove extends UpdateMessage: 
	var id:String
	func _to_string():
		return "Remove"
		
#---------------------------------------------------------------------------------------------------
class PropertyUpdated extends UpdateMessage: 
	var id:String
	var key:String
	var value
	func _to_string():
		return "PropertyUpdated"
		
#---------------------------------------------------------------------------------------------------
class HierarchyUpdated extends UpdateMessage: 
	var drag_id:String
	var drop_id:String
	var section:int  # -> HierarchyData.DragDrop
	func _to_string():
		return "HierarchyUpdated"
		
#---------------------------------------------------------------------------------------------------
class PinUpdated extends UpdateMessage: 
	var pin:BaseItem
	func _to_string():
		return "PinUpdated"
		
		
		
		
		
		
		
		
		
		
