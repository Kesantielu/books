#!/bin/bash
# Скрипт: average_dpi.sh
# Описание:
#   Скрипт принимает путь к каталогу и для каждой его подпапки:
#   – ищет файлы *.jpg,
#   – извлекает из них DPI (тег XResolution) с помощью exiftool,
#   – вычисляет и выводит среднее значение DPI.
#
# Использование:
#   ./average_dpi.sh /путь/к/каталогу
#
# Требования:
#   exiftool должен быть установлен

# Проверка наличия аргумента
if [ "$#" -ne 1 ]; then
    echo "Использование: $0 /путь/к/каталогу"
    exit 1
fi

basepath="$1"

# Проверка, что аргумент является директорией
if [ ! -d "$basepath" ]; then
    echo "Указанный путь не является директорией: $basepath"
    exit 1
fi

# Включаем nullglob, чтобы при отсутствии совпадений не оставались шаблоны
shopt -s nullglob

echo "Обрабатывается каталог: $basepath"

# Перебираем все элементы в базовом пути
for subdir in "$basepath"/*; do
    if [ -d "$subdir" ]; then
        echo "Обрабатывается папка: $subdir"
        # Собираем все файлы с расширением .jpg в текущей папке
        files=( "$subdir"/*.jpg )
        
        if [ ${#files[@]} -eq 0 ]; then
            echo "  Нет jpg файлов в папке $subdir"
            continue
        fi

        total=0
        count=0

        # Обрабатываем каждый файл в папке
        for file in "${files[@]}"; do
            # Получаем значение DPI с помощью exiftool (выводим только значение)
            dpi=$(exiftool -s -s -s -XResolution "$file")
            if [ -n "$dpi" ]; then
                total=$(awk -v a="$total" -v b="$dpi" 'BEGIN {printf "%.4f", a+b}')
                count=$(( count + 1 ))
            else
                echo "  Не удалось получить DPI для файла: $file"
            fi
        done

        if [ $count -gt 0 ]; then
            average=$(awk -v total="$total" -v count="$count" 'BEGIN {printf "%.2f", total/count}')
            echo "  Среднее значение DPI для папки $subdir: $average"
        else
            echo "  Нет доступной информации о DPI в папке $subdir"
        fi
        echo
    fi
done
