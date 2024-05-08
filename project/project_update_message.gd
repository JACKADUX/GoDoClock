# 用于向下传递信息
class_name ProjectUpdateMessage extends BaseMessage.SimpleMessage

#---------------------------------------------------------------------------------------------------
class Initialize extends ProjectUpdateMessage: 
	var project:BaseItem.ProjectItem
	func _to_string():
		return "Initialize"

#---------------------------------------------------------------------------------------------------
class Add extends ProjectUpdateMessage: 
	var base_item:BaseItem
	var parent_id:String
	func _to_string():
		return "Add"
		
#---------------------------------------------------------------------------------------------------
class Remove extends ProjectUpdateMessage: 
	var id:String
	func _to_string():
		return "Remove"
		
#---------------------------------------------------------------------------------------------------
class PropertyUpdated extends ProjectUpdateMessage: 
	var id:String
	var key:String
	var value
	func _to_string():
		return "PropertyUpdated"
		
#---------------------------------------------------------------------------------------------------
class HierarchyUpdated extends ProjectUpdateMessage: 
	var drag_id:String
	var drop_id:String
	var section:int  # -> HierarchyData.DragDrop
	func _to_string():
		return "HierarchyUpdated"
		
#---------------------------------------------------------------------------------------------------
class PinUpdated extends ProjectUpdateMessage: 
	var pin:BaseItem
	func _to_string():
		return "PinUpdated"
		
		
		
		
		
		
		
		
		
		
