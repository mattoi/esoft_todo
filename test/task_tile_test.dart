import 'package:test/test.dart';
import 'package:todo/data/task_list.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Task', () {
    test('Tarefa deve ser inicializada corretamente', () {
      final task =
          Task(title: 'Nome da tarefa', description: 'descrição da tarefa');

      expect(task.title, 'Nome da tarefa');
      expect(task.description, 'descrição da tarefa');
    });

    test(
        'Tarefa pode ser editada, podendo deixar a descrição vazia se desejado',
        () {
      final task =
          Task(title: 'Nome inicial', description: 'Descrição inicial');
      task.edit(newTitle: 'Nome após a mudança', newDescription: '');

      expect(task.title, 'Nome após a mudança');
      expect(task.description, '');
    });
  });
  group('TaskListController', () {
    test('Deve ser possível adicionar novas tarefas à lista', () {
      final listController = TaskList();
      expect(listController.contents.isEmpty, true);

      listController.addTask(
          title: 'Nova tarefa', description: 'Descrição da tarefa');
      expect(listController.contents[0].title, 'Nova tarefa');
      expect(listController.contents[0].description, 'Descrição da tarefa');
    });
    test('Uma tarefa pode ser removida passando-se sua referência', () {
      final listController = TaskList();
      listController.addTask(title: 'Tarefa descartável');

      listController.removeTask(listController.contents[0]);
      expect(listController.contents.isEmpty, true);
    });
    test('A lista pode ser esvaziada de uma vez', () {
      final listController = TaskList();
      listController.addTask(title: 'Tarefa 1');
      listController.addTask(title: 'Tarefa 2');
      listController.addTask(title: 'Tarefa 3');
      expect(listController.contents.isEmpty, false);

      listController.clear();
      expect(listController.contents.isEmpty, true);
    });
    test(
        'Deve ser possível adicionar tarefas salvas à lista quando iniciar o app, com seu estado isDone',
        () {
      final listController = TaskList();
      expect(listController.contents.isEmpty, true);

      listController.loadTask(
          title: 'Tarefa que foi armazenada localmente',
          description: 'Olá',
          isDone: true);
      expect(listController.contents[0].title,
          'Tarefa que foi armazenada localmente');
      expect(listController.contents[0].description, 'Olá');
      expect(listController.contents[0].isDone, true);
    });
  });
  group('shared_preferences', () {
    test('Deve ser possível salvar e carregar dados no shared_preferences',
        () async {
      final listController = TaskList();
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      listController.addTask(title: 'Oi');
      listController.saveToPrefs();
      expect(await listController.saveToPrefs(), true);
      expect(prefs.getStringList('list_titles')?[0], 'Oi');

      listController.clear();
      expect(await listController.loadFromPrefs(), true);
      expect(listController.contents.isEmpty, false);
      expect(listController.contents[0].title, 'Oi');
    });
  });
}
