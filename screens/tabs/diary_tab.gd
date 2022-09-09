extends VBoxContainer

const DiaryEditorScreen = preload("res://screens/diary_editor_screen.tscn")

@export var datetime_dict: Dictionary:
	get:
		return _datetime.to_local_datetime_dict()
	set(value):
		_datetime = Datetime.from_local_datetime_dict(value)
		_update_ui()

var DiaryRepo = DiaryRepository.new()

var _selected_diary_idx := -1
var _datetime := Datetime.new()

@onready var date_label = %DateLabel as Label
@onready var diary_list = %DiaryList as ItemList
@onready var title_edit = %TitleEdit as LineEdit
@onready var content_edit = %ContentEdit as TextEdit

func _get_date_string() -> String:
	return "%04d-%02d-%02d" % [datetime_dict["year"], datetime_dict["month"], datetime_dict['day']]

func _read_diaries() -> void:
	var diaries = DiaryRepo.find_by_date(_datetime)
	diaries.sort_custom(func (a, b): return a.content.date < b.content.date)
	for diary in diaries:
		diary_list.add_item("%s @ %s" % [diary.content.title, Datetime.new(diary.content.date).format("HH:mm")])
		diary_list.set_item_metadata(diary_list.item_count - 1, diary)

func _update_ui() -> void:
	date_label.text = _get_date_string()
	if _selected_diary_idx != -1:
		var diary = diary_list.get_item_metadata(_selected_diary_idx)
		title_edit.text = diary.content.title
		content_edit.text = diary.content.content
	else:
		title_edit.text = ""
		content_edit.text = ""

func _ready() -> void:
	_read_diaries()
	_update_ui()

func _on_previous_day_button_pressed() -> void:
	datetime_dict = _datetime.get_previous_day().to_local_datetime_dict()
	_read_diaries()
	_update_ui()

func _on_next_day_button_pressed() -> void:
	datetime_dict = _datetime.get_next_day().to_local_datetime_dict()
	_read_diaries()
	_update_ui()

func _on_add_diary_button_pressed() -> void:
	Screens.go_to(DiaryEditorScreen.instantiate())

func _on_remove_diary_button_pressed() -> void:
	if _selected_diary_idx != -1:
		var diary = diary_list.get_item_metadata(_selected_diary_idx)
		DiaryRepo.soft_remove(diary)
		diary_list.remove_item(_selected_diary_idx)
	_update_ui()

func _on_edit_diary_button_pressed() -> void:
	if _selected_diary_idx != -1:
		var diary = diary_list.get_item_metadata(_selected_diary_idx)
		var editor = DiaryEditorScreen.instantiate()
		editor.diary = diary
		editor.diary_chagned.connect(func (_diary): _update_ui())
		Screens.go_to(editor)

func _on_diary_list_item_selected(index: int) -> void:
	_selected_diary_idx = index
	_update_ui()
