class_name AssetUtils

static func init_paths():
	DirAccess.make_dir_recursive_absolute(get_root_path())

static func get_root_path():
	return "user://projects"

static func get_all_project_paths() -> Array:
	var projects = []
	var root = get_root_path()
	for file in DirAccess.get_files_at(root):
		if not file.ends_with("json"):
			continue
		projects.append(root.path_join(file))
	return projects
