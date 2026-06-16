# Контейнер Chromium с Accessibility Inspector

В проект добавлена Docker-конфигурация, которая запускает Chromium с локальным
расширением `accessibility-inspector`, установленным как распакованное
расширение.

## Запуск

Собрать образ и запустить браузер:

```powershell
docker compose up --build
```

Endpoint удалённой отладки Chromium доступен по адресу:

```text
http://localhost:9222
```

## Настройка

В `docker-compose.yml` поддерживаются следующие переменные окружения:

```yaml
DISPLAY_WIDTH: "1440"
DISPLAY_HEIGHT: "900"
DISPLAY_DEPTH: "24"
START_URL: "about:blank"
```

Например, чтобы автоматически открыть страницу:

```powershell
$env:START_URL="https://example.com"
docker compose up --build
```

Профиль Chromium хранится в именованном Docker volume `chromium-profile`,
поэтому состояние расширения и настройки браузера сохраняются между
перезапусками контейнера.

## Остановка

```powershell
docker compose down
```

Чтобы вместе с контейнером удалить сохранённый профиль Chromium:

```powershell
docker compose down -v
```
