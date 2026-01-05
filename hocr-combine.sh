#!/bin/bash

# Проверяем наличие аргумента с путём
if [ $# -eq 0 ]; then
    echo "Ошибка: Укажите целевую директорию."
    echo "Пример: $0 /путь/к/директории"
    exit 1
fi

target_dir="$1"

# Проверяем, что директория существует
if [ ! -d "$target_dir" ]; then
    echo "Ошибка: Директория '$target_dir' не существует."
    exit 1
fi

# Активируем виртуальное окружение
source ~/archtools/venv/bin/activate || exit 1

# Перебираем подпапки внутри целевой директории
for folder in "$target_dir"/*/; do
    # Удаляем завершающий слэш для корректной работы с путями
    folder="${folder%/}"
    
    # Проверяем наличие папки hocr
    if [ -d "$folder/hocr" ] && [ ! -f "$folder/hocr.html" ]; then
        echo "Обработка: $folder/hocr/"
        # Запускаем команду с подстановкой пути
        if hocr-combine-stream -g "$folder/hocr/*.html" > "$folder/hocr.html"; then
			# Дополнительная проверка существования hocr.html
            if [ -f "$folder/hocr.html" ]; then
                echo "Успешно создан: $folder/hocr.html"
            else
                echo "Ошибка: $folder/hocr.html не создан"
            fi
		else
            echo "Ошибка: hocr-combine-stream завершился с ошибкой для $folder"
        fi
    fi
done

echo "Готово!"