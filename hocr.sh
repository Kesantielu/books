#!/bin/bash

# Проверка количества аргументов
if [ "$#" -ne 3 ] && [ "$#" -ne 4 ]; then
    echo "Usage: $0 <папка с файлами> <код языка> <расширение файлов (например, jpg)> <dpi=150>"
    exit 1
fi

default_dpi="150"

INPUT_DIR="$1"
LANG="$2"
FILE_EXT="$3"
DPI="${4:-$default_dpi}"
OUTPUT_DIR="$INPUT_DIR/hocr"

# Проверяем, существует ли папка с входными файлами
if [ ! -d "$INPUT_DIR" ]; then
    echo "Папка '$INPUT_DIR' не существует."
    exit 1
fi

# Создаем папку для вывода, если ее нет
mkdir -p "$OUTPUT_DIR"

# Обработка всех файлов с расширением .jpg в указанной папке
shopt -s nullglob  # Если нет файлов, переменная останется пустой
for file in "$INPUT_DIR"/*."$FILE_EXT"; do
# Если файл не найден — пропускаем (на случай, если шаблон не дал результатов)
    if [ ! -f "$file" ]; then
        echo "Файлы с расширением .$FILE_EXT в '$INPUT_DIR' не найдены."
        continue
    fi

    # Извлекаем имя файла без расширения
    base=$(basename "$file" ".$FILE_EXT")
    echo "Обработка файла: $file"
    
    # Запускаем Tesseract с выбранным языком и конфигурацией hocr,
    # вывод перенаправляем в файл hocr/<имя файла>.hocr.html
    tesseract "$file" - -l "$LANG" --dpi "$DPI" hocr > "$OUTPUT_DIR/${base}.hocr.html"
done

# Combine single hocr files into one

if hocr-combine-stream -g "$OUTPUT_DIR/*.html" > "$INPUT_DIR/hocr.html"; then
    # Дополнительная проверка существования hocr.html
    if [ -f "$INPUT_DIR/hocr.html" ]; then
        echo "Успешно создан: $INPUT_DIR/hocr.html"
    else
        echo "Ошибка: $INPUT_DIR/hocr.html не создан"
    fi
else
    echo "Ошибка: hocr-combine-stream завершился с ошибкой для $folder"
fi

rm -r $OUTPUT_DIR
echo "Обработка завершена. Результаты сохранены в каталоге '$INPUT_DIR'"

