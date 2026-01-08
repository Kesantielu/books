#!/bin/bash

# Проверка наличия аргумента
if [ $# -lt 1 ]; then
  echo "Usage: $0 /path/to/directory"
  exit 1
fi

target_dir="$1"

[ ! -d "$target_dir" ] && echo "Директория '$target_dir' не существует." && exit 1
mkdir -p "processed"

shopt -s nullglob

# Проверка JPG-файлов
jpg_files=("$target_dir"/*.jpg)
if [ ${#jpg_files[@]} -eq 0 ]; then
	echo "Пропуск: в $target_dir нет JPG"
	exit 1
fi

mkdir -p "$target_dir/jp2" || exit 1

# Конвертация JPG → JP2
for jpg in "${jpg_files[@]}"; do
	jpg_name=$(basename "$jpg" .jpg)
	output_jp2="$target_dir/jp2/${jpg_name}.jp2"
	
	grk_compress \
		-i "$jpg" \
		-o "$output_jp2" \
		-r 30 \
		-n 6 \
		-b "64,64" \
		-f \
		-p RPCL || {
			echo "Ошибка конвертации $jpg"
			rm -rf "$target_dir/jp2"
			continue 2
		}
done

# Сборка PDF
output_pdf="processed/$(basename "$target_dir").pdf"
if [ -f "$output_pdf" ]; then
    output_pdf="processed/$(basename "$target_dir")_grk.pdf"
fi
if img2pdf "$target_dir/jp2"/*.jp2 -o "$output_pdf"; then
	rm -rf "$folder/jp2"
	echo "Успешно: $output_pdf"
else
	echo "Ошибка создания PDF"
	rm -rf "$target_dir/jp2"
	[ -f "$output_pdf" ] && rm -f "$output_pdf"  # <--- Удаление пустого PDF
fi

shopt -u nullglob
