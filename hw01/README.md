# hw01

## Запуск

Запуск происходит через `main.sh` с помощью команды:

```shell
bash main.sh
```

### main.sh

1. Настраивает узлы кластера: настраивает доступ по SSH между узлами, создает пользователя `hadoop`
2. Устанавливает Hadoop: распространяет исходный код на все узлы, настраивает окружение для работы Hadoop
3. Запускает кластер: форматирует NameNode и запускает нужные сервисы Hadoop (NameNode, SecondaryNameNode, DataNodes)

### Настройка скрипта

- Сохранить пароль от учётной записи в `scripts/.password`
- В случае необходимости изменить IP-адреса узлов кластера в [templates/hosts](./templates/hosts) и [scripts/inventory.sh](./scripts/inventory.sh)