extends Node

const MAX_NUMBER = 10
var recent_list :PackedStringArray = []

const GDC_EXTENSION = "gdclock"


#--------------------------------------------------------------------------------------------------
func _ready():
	var recents = AssetUtils.get_configs(AssetUtils.S_SETTINGS, AssetUtils.K_RECENT_PROJECTS, [])
	for file in recents:
		if not FileAccess.file_exists(file):
			recents.erase(file)
	FileManager.recent_list = recents

#---------------------------------------------------------------------------------------------------
func new_project(file_path:String) -> BaseItem:
	assert(file_path.get_extension() == GDC_EXTENSION)
	var project := ItemFactory.new_group()
	project.set_title(file_path)
	save_project(project)
	return project

#---------------------------------------------------------------------------------------------------
func save_project(project:BaseItem) -> Error:
	var file_path = project.get_title()
	assert(file_path.get_extension() == GDC_EXTENSION)
	JsonHelper.save_meta(file_path, ItemFactory.serialization(project))
	return OK

#---------------------------------------------------------------------------------------------------
func open_project(file_path:String) -> BaseItem:
	assert(FileAccess.file_exists(file_path))
	assert(file_path.get_extension() == GDC_EXTENSION)
	var project = ItemFactory.deserialization(JsonHelper.load_meta(file_path))
	project.set_title(file_path)
	return project

#---------------------------------------------------------------------------------------------------
func get_recent_list() -> PackedStringArray:
	return recent_list

#---------------------------------------------------------------------------------------------------
func add_to_recent_list(file_path:String) -> Error:
	if file_path in recent_list:
		recent_list.remove_at(recent_list.find(file_path))
	elif recent_list.size() >= MAX_NUMBER:
		recent_list.remove_at(MAX_NUMBER-1)
	recent_list.insert(0, file_path)
	return OK

func clear_recent_list():
	recent_list.clear()



















