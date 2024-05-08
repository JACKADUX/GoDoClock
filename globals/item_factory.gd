extends Node

var factory := Factory.new()

enum ItemType {
	Project,
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
		
	simple_register.call(BaseItem.ProjectItem, ItemType.Project)
	simple_register.call(BaseItem.TodoItem, ItemType.Todo)
	
#--------------------------------------------------------------------------------------------------
func create(type:ItemType) -> BaseItem:
	return factory.create(type)
	
#--------------------------------------------------------------------------------------------------
func new_project() -> BaseItem.ProjectItem:
	return factory.create(ItemType.Project)

#---------------------------------------------------------------------------------------------------
func serialization(item:BaseItem):
	var item_datas = []
	for sub_item:BaseItem in item.iterate():
		var item_data = sub_item.serialization()
		item_datas.append(item_data)
	return item_datas

#---------------------------------------------------------------------------------------------------
func deserialization(item_datas:Array):
	var temp_map = {}
	var project
	for item_data in item_datas:
		var item :BaseItem = ItemFactory.create(item_data.type)
		temp_map[item_data.id] = item
		if not project:
			project = item
		var parent = temp_map.get(item_data.pid)
		if parent:
			parent.add_child(item)
		item.deserialization(item_data)
	return project
	
