#!/bin/bash

if [ -z "$VIRTUAL_ENV" ]; then
    echo "Ошибка: скрипт должен быть запущен внутри venv!"
    exit 1
fi

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

# Проверяем наличие hocr.html
if [ -f "$folder/hocr.html" ]; then
	hocr=true
fi

# Ищем первый JPG-файл в папке
first_jpg=$(find "$target_dir" -maxdepth 1 -type f -iname "*.jpg" -print -quit)

# Если JPG-файлов нет - пропускаем
if [ -z "$first_jpg" ]; then
	echo "Предупреждение: Нет JPG-файлов в $target_dir"
	continue
fi

# Получаем DPI из метаданных
dpi=$(exiftool -T -XResolution "$first_jpg" | awk '{print int($1)}')

# Формируем путь к выходному PDF
output_pdf="$(basename "$target_dir").pdf"

# Запускаем recode_pdf и проверяем результат
if recode_pdf \
	-I "$target_dir/*.jpg" \
	$( [[ "$hocr" == true ]] && echo -T "$target_dir/hocr.html" ) \
	-D "$dpi" \
	--mask-compression jbig2 \
	--threads 2 \
	--report-every 10 \
	-o "$output_pdf"; then

	# Дополнительная проверка существования PDF
	if [ -f "$output_pdf" ]; then
		echo "Успешно создан: $output_pdf"
		rm -f "$target_dir/hocr.html" && echo "Удалён: $target_dir/hocr.html"
	else
		echo "Ошибка: PDF не создан для $target_dir"
	fi
else
	echo "Ошибка: recode_pdf завершился с ошибкой для $target_dir"
fi

echo "Готово! Результат в папке $target_dir"
