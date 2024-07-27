extends Node

const MAX_NUMBER = 10
var recent_list :PackedStringArray = []

#--------------------------------------------------------------------------------------------------
func _ready():
	var recents = Array(AssetUtils.get_configs(AssetUtils.S_SETTINGS, AssetUtils.K_RECENT_PROJECTS, []))
	for file_path in recents:
		if not AssetUtils.is_valid_project_path(file_path):
			recents.erase(file_path)
			continue
		if not AssetUtils.is_valid_project(file_path):
			recents.erase(file_path)
			continue
	FileManager.recent_list = recents

#---------------------------------------------------------------------------------------------------
func new_project(file_path:String) -> BaseItem:
	assert(file_path.get_extension() == AssetUtils.GDC_EXTENSION)
	var project := ItemFactory.new_project()
	project.set_path(file_path)
	project.set_title("Project")
	save_project(project)
	return project

#---------------------------------------------------------------------------------------------------
func save_project(project:BaseItem) -> Error:
	var file_path = project.get_path()
	assert(file_path.get_extension() == AssetUtils.GDC_EXTENSION)
	var data = {}
	var item_datas = ItemFactory.serialization(project)
	data["item_datas"] = item_datas
	JsonHelper.save_meta(file_path, data)
	return OK

#---------------------------------------------------------------------------------------------------
func open_project(file_path:String) -> BaseItem.ProjectItem:
	assert(FileAccess.file_exists(file_path))
	assert(file_path.get_extension() == AssetUtils.GDC_EXTENSION)
	var data = JsonHelper.load_meta(file_path)
	var project = ItemFactory.deserialization(data.get("item_datas", []))
	if not project:
		push_error("project deserialization failed")
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
