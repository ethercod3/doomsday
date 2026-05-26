![Nushell](https://img.shields.io/badge/Shell-Nushell-4E9A06?style=flat-square)
![7--Zip](https://img.shields.io/badge/Archive-7--Zip-222222?style=flat-square)
![SHA--256](https://img.shields.io/badge/Integrity-SHA--256-0A66C2?style=flat-square)
![AES--256](https://img.shields.io/badge/Encryption-AES--256-8A2BE2?style=flat-square)
![Header encryption](https://img.shields.io/badge/Headers-Encrypted-0A66C2?style=flat-square)
![Cross platform](https://img.shields.io/badge/OS-Cross--platform-555555?style=flat-square)
![Windows](https://img.shields.io/badge/Windows-supported-0078D4?style=flat-square&logo=windows&logoColor=white)
![macOS](https://img.shields.io/badge/macOS-supported-000000?style=flat-square&logo=apple&logoColor=white)
![Linux](https://img.shields.io/badge/Linux-supported-FCC624?style=flat-square&logo=linux&logoColor=black)
![No data in Git](https://img.shields.io/badge/Git-no%20archives%20stored-CB2431?style=flat-square)
![License MIT](https://img.shields.io/badge/License-MIT-green?style=flat-square)

Набор небольших скриптов для безопасной передачи данных в условиях, где важны простота, воспроизводимость и минимальное количество зависимостей.

## Что внутри

| Путь | Назначение |
| --- | --- |
| `scripts/encrypt_archive.nu` | Создает зашифрованный `7z`-архив и файл с `SHA-256`-хешем результата |
| `.gitignore` | Исключает архивы и текстовые файлы с хешами из Git |
| `README.md` | Инструкция по использованию проекта |
| `LICENSE` | Условия использования проекта |

Файлы вроде `*.rar`, `*.zip`, `*.tar.gz` и `*.txt` не должны попадать в Git. Это сделано намеренно: в репозитории должны храниться скрипты, а не передаваемые данные, контрольные суммы или временные артефакты.


<details>

<summary>Требования</summary>

Нужны две команды в `PATH`:

- `nu` - Nushell;
- `7z` - 7-Zip.

Windows:

```powershell
winget install Nushell.Nushell
winget install 7zip.7zip
```

macOS с Homebrew:

```bash
brew install nushell
brew install sevenzip
```

Linux:

```bash
# Debian/Ubuntu
sudo apt install nushell 7zip

# Arch Linux
sudo pacman -S nushell 7zip
```

Проверить установку:

```bash
nu --version
7z
```

Если `7z` не находится, добавьте каталог установки 7-Zip в `PATH`. На Windows это обычно:

```text
C:\Program Files\7-Zip
```

</details>


<details>

<summary>Быстрый старт</summary>

Создать зашифрованный архив:

```bash
nu scripts/encrypt_archive.nu input.zip output.7z "your-strong-password"
```

Скрипт:

- удалит старый файл назначения, если он уже существует;
- создаст новый архив формата `7z`;
- включит шифрование заголовков через `-mhe=on`;
- создаст файл контрольной суммы рядом с архивом.

Пример результата:

```text
output.7z
output.7z_2026-05-26_sha256.txt
```

> **Важно**
>
> Скрипт использует `7z a -t7z`, поэтому фактический формат результата - `7z`. Можно указать любое имя выходного файла, но рекомендуется расширение `.7z`, чтобы имя соответствовало содержимому.

</details>

<details>
<summary>Формат команды</summary>

```bash
nu scripts/encrypt_archive.nu <src> <dst> <key>
```

Параметры:

| Параметр | Назначение |
| --- | --- |
| `src` | Исходный файл или архив, который нужно защитить |
| `dst` | Путь к выходному зашифрованному архиву |
| `key` | Пароль шифрования |

Пример:

```bash
nu scripts/encrypt_archive.nu data.zip data_encrypted.7z "correct horse battery staple"
```

`src` и `dst` должны быть разными файлами. Скрипт специально останавливается, если входной и выходной путь совпадают.
</details>


<details>
<summary>Проверка целостности</summary>

После создания архива рядом появляется файл:

```text
<dst>_<дата>_sha256.txt
```

Внутри хранится имя архива и его `SHA-256`. Этот файл нужен, чтобы получатель мог проверить, что архив не был поврежден или подменен при передаче.

Проверить хеш вручную в Nushell:

```bash
open output.7z --raw | hash sha256
```

Сравните результат со значением в файле `output.7z_YYYY-MM-DD_sha256.txt`.
</details>

<details>

<summary>Проверка расшифровки</summary>

Перед передачей полезно убедиться, что архив открывается с тем паролем, который вы собираетесь передать получателю:

```bash
7z t output.7z -p"your-strong-password"
```

Распаковать архив:

```bash
7z x output.7z -p"your-strong-password"
```

Если пароль содержит пробелы или спецсимволы, оставляйте кавычки.
</details>

## Практический порядок передачи

1. Подготовьте исходный файл или архив.
2. Создайте зашифрованный `7z` через `scripts/encrypt_archive.nu`.
3. Проверьте тестовое открытие командой `7z t`.
4. Передайте получателю зашифрованный архив и файл с `SHA-256`.
5. Передайте пароль отдельно от архива, по другому каналу.
6. Попросите получателя проверить хеш перед распаковкой.
