extends SceneTree
func _init():
    var f = FileAccess.open("res://debug.txt", FileAccess.WRITE)
    f.store_string("Godot is running!\n")
    f.store_string("Attempting to load MainMenu...\n")
    var main = load("res://scenes/ui/MainMenu.tscn")
    if main == null:
        f.store_string("FAILED TO LOAD MainMenu.tscn\n")
    else:
        f.store_string("MainMenu loaded successfully.\n")
        var inst = main.instantiate()
        f.store_string("MainMenu instantiated successfully.\n")
    f.close()
    quit()
