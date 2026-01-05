#!/bin/bash

# Проверка наличия аргумента
if [ $# -eq 0 ]; then
    echo "Ошибка: Укажите целевую директорию."
    exit 1
fi

target_dir="$1"
marker_file=".processed"  # Файл-маркер

[ ! -d "$target_dir" ] && echo "Директория '$target_dir' не существует." && exit 1
mkdir -p "processed"

shopt -s nullglob

for folder in "$target_dir"/*/; do
    folder="${folder%/}"
    
    # Пропускаем, если:
    # 1. Есть папка hocr
    # 2. Уже есть маркер
    # 3. В processed уже есть PDF
    if [ -d "$folder/hocr" ] || \
       [ -f "$folder/$marker_file" ] ; then
        echo "Пропуск: $folder (есть hocr или уже обработана)"
        continue
    fi

    # Проверка JPG-файлов
    jpg_files=("$folder"/*.jpg)
    if [ ${#jpg_files[@]} -eq 0 ]; then
        echo "Пропуск: $folder (нет JPG)"
        continue
    fi

    echo "Обработка: $folder"
    mkdir -p "$folder/jp2" || exit 1

    # Конвертация JPG → JP2
    for jpg in "${jpg_files[@]}"; do
        jpg_name=$(basename "$jpg" .jpg)
        output_jp2="$folder/jp2/${jpg_name}.jp2"
        
        grk_compress \
            -i "$jpg" \
            -o "$output_jp2" \
            -r 30 \
            -n 6 \
            -b "64,64" \
			-f \
            -p RPCL || {
                echo "Ошибка конвертации $jpg"
                rm -rf "$folder/jp2"
                continue 2
            }
    done

    # Сборка PDF
    output_pdf="processed/$(basename "$folder").pdf"
    if img2pdf "$folder/jp2"/*.jp2 -o "$output_pdf"; then
        # Удаляем временные файлы И создаём маркер
        rm -rf "$folder/jp2"
        touch "$folder/$marker_file"  # <--- Маркировка
        echo "Успешно: $output_pdf"
    else
        echo "Ошибка создания PDF"
        rm -rf "$folder/jp2"
		[ -f "$output_pdf" ] && rm -f "$output_pdf"  # <--- Удаление пустого PDF
    fi
done

shopt -u nullglob
echo "Готово! Новые PDF в папке processed/"