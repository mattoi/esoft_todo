import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/constants.dart';
import 'package:todo/data/task_list.dart';
import 'package:todo/widgets/task_tile.dart';
import 'package:todo/widgets/round_button.dart';

class MainPageMobile extends StatefulWidget {
  const MainPageMobile({Key? key}) : super(key: key);

  @override
  _MainPageMobileState createState() => _MainPageMobileState();
}

class _MainPageMobileState extends State<MainPageMobile> {
  final _listController = TaskList();
  final _scrollController = ScrollController();

  ///Loads the list of saved tasks, if any, from shared preferences.
  void initialLoad() async {
    //This implementation is really poor but I don't know how a json-type format could be used,
    //or whether prefs even allows this anymore
    final prefs = await SharedPreferences.getInstance();
    final List<String>? cachedTitles = prefs.getStringList('list_titles');
    final List<String>? cachedDescriptions =
        prefs.getStringList('list_descriptions');
    final List<String>? cachedStatuses = prefs.getStringList('list_statuses');

    if (cachedTitles != null) {
      setState(() {
        for (int i = 0; i < cachedTitles.length; i++) {
          _listController.loadTask(
              title: cachedTitles[i],
              description: cachedDescriptions![i],
              isDone: cachedStatuses![i] == 'true' ? true : false);
        }
      });
    }
  }

  ///Scrolls down the view, with an animation, to the last element. Usually called when a new task is added.
  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent + 104,
      duration: const Duration(seconds: 1, milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void initState() {
    super.initState();
    initialLoad();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: const Text(UITextStrings.appName),
        actions: [
          //TODO consider adding a button to delete all checked counters
          //Button to delete all counters.
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () async {
              if (_listController.contents.isNotEmpty) {
                final result = await showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text(
                      UITextStrings.dialogTitleDeleteAll,
                    ),
                    content: const Text(
                      UITextStrings.dialogContentDeleteAll,
                    ),
                    actions: [
                      //"No" button
                      TextButton(
                        child: Text(
                          UITextStrings.dialogButtonNo,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary),
                        ),
                        onPressed: () => Navigator.pop(context, 'No'),
                      ),
                      //"Yes" button
                      TextButton(
                        child: Text(
                          UITextStrings.dialogButtonYes,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary),
                        ),
                        onPressed: () {
                          Navigator.pop(context, 'Yes');
                        },
                      ),
                    ],
                  ),
                );
                if (result == 'Yes') {
                  setState(() => _listController.clear());
                  _listController.saveToPrefs();
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text(UITextStrings.emptyListSnackBar)));
              }
            },
          ),
        ],
      ),
      floatingActionButton: RoundButton(
        size: 48,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          String title = '';
          String description = '';
          final result = await showDialog(
            context: context,
            builder: (BuildContext context) => StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                title: const Text(UITextStrings.dialogTitleAddTask),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      autofocus: true,
                      cursorColor: Theme.of(context).colorScheme.primary,
                      decoration: const InputDecoration(
                        hintText: UITextStrings.titleHintText,
                      ),
                      onChanged: (value) {
                        setState(() => title = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      cursorColor: Theme.of(context).colorScheme.primary,
                      decoration: const InputDecoration(
                        hintText: UITextStrings.descriptionHintText,
                      ),
                      onChanged: (value) => description = value,
                    ),
                  ],
                ),
                actions: <TextButton>[
                  //"Cancel" button
                  TextButton(
                    child: Text(
                      UITextStrings.dialogButtonCancel,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    onPressed: () => Navigator.pop(context, 'Cancel'),
                  ),
                  //"OK" button, only available if title as at least 1 letter
                  TextButton(
                    child: Text(
                      UITextStrings.dialogButtonOK,
                      style: title != ''
                          ? Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary)
                          : Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface),
                    ),
                    onPressed:
                        title != '' ? () => Navigator.pop(context, 'OK') : null,
                  ),
                ],
              ),
            ),
          );
          if (result == 'OK') {
            setState(() => _listController.addTask(
                title: title, description: description));
            _listController.saveToPrefs();
            _scrollDown();
          }
        },
      ),
      //ListView that generates all the tiles for the counters.
      body: (ListView.builder(
        padding: const EdgeInsets.only(bottom: 80, top: 8),
        shrinkWrap: true,
        itemCount: _listController.contents.length,
        controller: _scrollController,
        itemBuilder: (BuildContext context, int index) => TaskTile(
          task: _listController.contents[index],
          updateCallback: () {
            // setState with an expression body into an async function causes an exception.
            setState(() {
              _listController.saveToPrefs();
            });
          },
          deleteCallback: (task) {
            setState(() => _listController.removeTask(task));
            _listController.saveToPrefs();
          },
        ),
      )),
    );
  }
}
