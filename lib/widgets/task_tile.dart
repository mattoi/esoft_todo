import 'package:flutter/material.dart';
import 'package:todo/constants.dart';
import '../data/task_list.dart';
import 'round_button.dart';

///The UI tile that shows a task's info.
class TaskTile extends StatelessWidget {
  final Task task;

  ///Callback to refresh the screen state.
  final Function() updateCallback;

  ///Callback to delete the task and its tile.
  final Function(Task) deleteCallback;

  const TaskTile({
    Key? key,
    required this.task,
    required this.updateCallback,
    required this.deleteCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Checkbox(
          activeColor: Theme.of(context).colorScheme.primary,
          value: task.isDone,
          onChanged: (value) {
            task.isDone = value;
            updateCallback.call();
          },
        ),
        title: Text(
          task.title,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onPrimary),
        ),
        subtitle: Text(
          task.description,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
        ),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          RoundButton(
            size: 32,
            child: const Icon(Icons.edit, size: 16),
            onPressed: () async {
              String newTitle = task.title;
              String newDescription = task.description;
              final titleController = TextEditingController(text: task.title);
              final descriptionController =
                  TextEditingController(text: task.description);

              final result = await showDialog(
                context: context,
                builder: (BuildContext context) => StatefulBuilder(
                  builder: (context, setState) => AlertDialog(
                    title: const Text(UITextStrings.dialogTitleEditTask),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          autofocus: true,
                          cursorColor: Theme.of(context).colorScheme.primary,
                          controller: titleController,
                          decoration: const InputDecoration(
                            constraints: BoxConstraints(minWidth: 20),
                            hintText: UITextStrings.titleHintText,
                          ),
                          onChanged: (value) {
                            setState(() => newTitle = value);
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          cursorColor: Theme.of(context).colorScheme.primary,
                          controller: descriptionController,
                          decoration: const InputDecoration(
                            constraints: BoxConstraints(maxHeight: 64),
                            hintText: UITextStrings.descriptionHintText,
                          ),
                          onChanged: (value) => newDescription = value,
                        ),
                      ],
                    ),
                    actions: <TextButton>[
                      //"Cancel" button
                      TextButton(
                        child: Text(
                          UITextStrings.dialogButtonCancel,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary),
                        ),
                        onPressed: () => Navigator.pop(context, 'Cancel'),
                      ),
                      //"OK" button, only available if title as at least 1 letter
                      TextButton(
                        child: Text(
                          UITextStrings.dialogButtonOK,
                          style: newTitle != ''
                              ? Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.primary)
                              : Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                        ),
                        onPressed: newTitle != ''
                            ? () => Navigator.pop(context, 'OK')
                            : null,
                      ),
                    ],
                  ),
                ),
              );
              if (result == 'OK') {
                task.edit(newTitle: newTitle, newDescription: newDescription);
                updateCallback.call();
              }
            },
          ),
          RoundButton(
            size: 32,
            child: const Icon(Icons.close, size: 16),
            onPressed: () {
              deleteCallback(task);
            },
          ),
        ]),
      ),
    );
  }
}
