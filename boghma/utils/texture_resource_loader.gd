class_name TextureResourceLoader extends ResourceFormatLoader

# 这个类会自动添加到ResourceLoader 

func _get_recognized_extensions():
	return ["png","jpg","jpeg"]

func _load(path: String, original_path: String, use_sub_threads: bool, cache_mode: int):
	return ImageTexture.create_from_image(Image.load_from_file(path))
