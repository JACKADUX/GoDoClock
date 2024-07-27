class_name AssetUtils


const GDC_EXTENSION = "gdclock"
#---------------------------------------------------------------------------------------------------
const S_SETTINGS := "Settings"
const K_RECENT_PROJECTS := "recent_projects"
const K_COUNTDOWN_TIME := "countdown_time"
const K_WINDOW_SIZE := "window_size" 
const K_WINDOW_POSITION := "window_position" 
const K_FONT_SIZE := "font_size"


#---------------------------------------------------------------------------------------------------
static func init_paths():
	DirAccess.make_dir_recursive_absolute(get_root_path())
	if not FileAccess.file_exists(get_configs_path()):
		var config = ConfigFile.new()
		config.save(get_configs_path())

#---------------------------------------------------------------------------------------------------
static func get_root_path()->String:
	return "user://projects"

#---------------------------------------------------------------------------------------------------
static func get_all_project_paths() -> Array:
	var projects = []
	var root = get_root_path()
	for file in DirAccess.get_files_at(root):
		if not file.ends_with("json"):
			continue
		projects.append(root.path_join(file))
	return projects

#---------------------------------------------------------------------------------------------------
static func new_project_path() -> String:
	"返回一个可用的默认文件路径"
	while true:
		var uuid = UUID.v4()
		var valid = true
		for path:String in get_all_project_paths():
			if path.get_file().get_basename() == uuid:
				valid = false
				break
		if valid:
			return get_root_path().path_join(uuid+"."+GDC_EXTENSION)
	return ""
	
#---------------------------------------------------------------------------------------------------
static func is_valid_project_path(file_path:String) -> bool:
	if not FileAccess.file_exists(file_path):
		return false
	if file_path.get_extension() != GDC_EXTENSION:
		return false
	return true

#---------------------------------------------------------------------------------------------------
static func is_valid_project(file_path:String) -> bool:
	if not is_valid_project_path(file_path):
		return false
	var data = JsonHelper.load_meta(file_path)
	var project = ItemFactory.deserialization(data.get("item_datas", []))
	if not project:
		return false
	return true
	
#---------------------------------------------------------------------------------------------------
static func get_configs_path():
	return get_root_path().path_join("config.cfg")

#---------------------------------------------------------------------------------------------------
static func save_configs(section: String, key: String, value: Variant):
	var config = load_configs()
	config.set_value(section, key, value)
	config.save(get_configs_path())
	
#---------------------------------------------------------------------------------------------------
static func load_configs():
	var config = ConfigFile.new()
	config.load(get_configs_path())
	return config
	
#---------------------------------------------------------------------------------------------------
static func get_configs(section: String, key: String, default=null):
	var config = load_configs()
	return config.get_value(section, key, default)
