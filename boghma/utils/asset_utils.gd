class_name AssetUtils

static func init_paths():
	DirAccess.make_dir_recursive_absolute(get_root_path())

static func get_root_path():
	return "user://projects"
