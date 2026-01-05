#!/bin/bash

# Проверяем наличие аргумента с путём
if [ $# -eq 0 ]; then
    echo "Ошибка: Укажите целевую директорию."
    echo "Пример: $0 /путь/к/директории"
    exit 1
fi

target_dir="$1"

# Проверяем существование целевой директории
if [ ! -d "$target_dir" ]; then
    echo "Ошибка: Директория '$target_dir' не существует."
    exit 1
fi

# Активируем виртуальное окружение
source ~/archtools/venv/bin/activate || exit 1

# Создаём папку для результатов, если её нет
mkdir -p "processed"

# Обрабатываем каждую поддиректорию
for folder in "$target_dir"/*/; do
    # Удаляем завершающий слэш
    folder="${folder%/}"
    
    # Проверяем наличие hocr.html
    if [ -f "$folder/hocr.html" ]; then
        echo "Обработка: $folder"

        # Ищем первый JPG-файл в папке
        first_jpg=$(find "$folder" -maxdepth 1 -type f -iname "*.jpg" -print -quit)
        
        # Если JPG-файлов нет - пропускаем
        if [ -z "$first_jpg" ]; then
            echo "Предупреждение: Нет JPG-файлов в $folder"
            continue
        fi

        # Получаем DPI из метаданных
        dpi=$(exiftool -T -XResolution "$first_jpg" | awk '{print int($1)}')
		
		# Формируем путь к выходному PDF
        output_pdf="processed/$(basename "$folder").pdf"
        
		# Запускаем recode_pdf и проверяем результат
        if recode_pdf \
            -I "$folder/*.jpg" \
            -T "$folder/hocr.html" \
            -D "$dpi" \
            --mask-compression jbig2 \
            --threads 2 \
            --report-every 10 \
            -o "$output_pdf"; then

            # Дополнительная проверка существования PDF
            if [ -f "$output_pdf" ]; then
                echo "Успешно создан: $output_pdf"
                rm -f "$folder/hocr.html" && echo "Удалён: $folder/hocr.html"
            else
                echo "Ошибка: PDF не создан для $folder"
            fi
        else
            echo "Ошибка: recode_pdf завершился с ошибкой для $folder"
        fi

    else
        echo "Пропуск: $folder (hocr.html не найден)"
    fi
done

echo "Готово! Результаты в папке processed/"