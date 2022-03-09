import 'dart:collection';
import 'package:shared_preferences/shared_preferences.dart';

///A task with a [title], optional [description] and a [isDone] boolean which is false by default.
class Task {
  String title = '';
  String description;
  bool? isDone = false;

  ///Creates a task with a required [title] and an optional [description].
  Task({required this.title, this.description = ''});

  ///Creates a task with a required [title] and an optional [description], as well as its [isDone] status.
  ///
  ///Called when loading tasks from prefs.
  Task.fromStorage(
      {required this.title, required this.description, required this.isDone});

  ///Edits the task with a [newTitle] and [newDescription].
  void edit({required String newTitle, required String newDescription}) {
    title = newTitle;
    description = newDescription;
  }
}

class TaskList {
  final List<Task> _contents = [];
  UnmodifiableListView<Task> get contents => UnmodifiableListView(_contents);
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  ///Adds a new task with a required [title] and an optional [description].
  void addTask({String title = '', String description = ''}) {
    _contents.add(Task(title: title, description: description));
  }

  ///Adds a task with a [title], [description] and [isDone] status.
  ///
  ///Usually called when loading from storage.
  void loadTask(
      {String title = '', String description = '', required bool isDone}) {
    _contents.add(Task.fromStorage(
        title: title, description: description, isDone: isDone));
  }

  ///Edits the specified [task] with a [newTitle] and [newDescription].
  void edit(
      {required task,
      required String newTitle,
      required String newDescription}) {
    task.title = newTitle;
    task.description = newDescription;
  }

  ///Removes the specified [task] from the list.
  void removeTask(Task task) => _contents.remove(task);

  void clear() => _contents.clear();

  ///Loads the list of saved tasks, if any, from shared preferences.
  Future<bool> loadFromPrefs() async {
    //This implementation is really poor but I don't know how a json-type format could be used,
    //or whether prefs even allows this anymore
    //this works fine and can be tested, but when used on initState() it doesn't refresh the screen with the values
    final prefs = await _prefs;
    final List<String>? cachedTitles = prefs.getStringList('list_titles');
    final List<String>? cachedDescriptions =
        prefs.getStringList('list_descriptions');
    final List<String>? cachedStatuses = prefs.getStringList('list_statuses');

    if (cachedTitles != null) {
      for (int i = 0; i < cachedTitles.length; i++) {
        loadTask(
            title: cachedTitles[i],
            description: cachedDescriptions?[i] ?? '',
            isDone: cachedStatuses?[i] == 'true' ? true : false);
      }
      return true;
    }
    return false;
  }

  ///Saves all tasks as a list into shared preferences.
  Future<bool> saveToPrefs() async {
    //Same as loadFromPrefs
    final prefs = await _prefs;
    List<String> titles = [];
    List<String> descriptions = [];
    List<String> statuses = [];
    for (var i = 0; i < contents.length; i++) {
      titles.add(contents[i].title.toString());
      descriptions.add(contents[i].description.toString());
      statuses.add(contents[i].isDone.toString());
    }
    final status = (await prefs.setStringList('list_titles', titles) &&
        await prefs.setStringList('list_descriptions', descriptions) &&
        await prefs.setStringList('list_statuses', statuses));
    return status;
  }
}
