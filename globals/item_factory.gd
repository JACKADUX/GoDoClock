extends Node

var factory := Factory.new()

enum ItemType {
	Group,
	Todo,
}

func _init():
	var simple_register := func(object:Object, type:ItemType):
		factory.register(type, func():
			var instance = object.new()
			instance._type = type
			instance._type_string = ItemType.keys()[type]
			return instance 
		)
		
	simple_register.call(BaseItem.GroupItem, ItemType.Group)
	simple_register.call(BaseItem.TodoItem, ItemType.Todo)
	
#--------------------------------------------------------------------------------------------------
func create(type:ItemType) -> BaseItem:
	return factory.create(type)
	
#--------------------------------------------------------------------------------------------------
func new_group() -> BaseItem.GroupItem:
	return factory.create(ItemType.Group)

#---------------------------------------------------------------------------------------------------
func serialization(item:BaseItem):
	var all_data = []
	for sub_item:BaseItem in item.iterate():
		var data = sub_item.serialization()
		all_data.append(data)
	return all_data

#---------------------------------------------------------------------------------------------------
func deserialization(data:Array):
	var temp_map = {}
	var project
	for item_data in data:
		var item :BaseItem = ItemFactory.create(item_data.type)
		temp_map[item_data.id] = item
		if not project:
			project = item
		var parent = temp_map.get(item_data.pid)
		if parent:
			parent.add_child(item)
		item.deserialization(item_data)
	return project
	
