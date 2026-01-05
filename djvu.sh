#!/bin/bash
set -euo pipefail

# Проверка аргументов
if [ $# -ne 1 ]; then
  echo "Usage: $0 /path/to/directory"
  exit 1
fi

BASE_DIR="$1"
FOREGROUND_DIR="${BASE_DIR}/out/foreground"
BACKGROUND_DIR="${BASE_DIR}/out/background"
OUT_DIR="${BASE_DIR}/out"
FILE_NAME=$(basename "${BASE_DIR%/}")

# Проверка наличия необходимых утилит
command -v cpaldjvu >/dev/null 2>&1 || { echo "Error: cpaldjvu not found"; exit 1; }
command -v tifftopnm >/dev/null 2>&1 || { echo "Error: tifftopnm (netpbm) not found"; exit 1; }
command -v cjb2 >/dev/null 2>&1 || { echo "Error: cjb2 not found"; exit 1; }
command -v c44 >/dev/null 2>&1 || { echo "Error: c44 not found"; exit 1; }
command -v djvumake >/dev/null 2>&1 || { echo "Error: djvumake not found"; exit 1; }
command -v djvm >/dev/null 2>&1 || { echo "Error: djvm not found"; exit 1; }
command -v identify >/dev/null 2>&1 || { echo "Error: ImageMagick not found"; exit 1; }

process_file() {
  local fg_tif="$1"
  local base_name="$(basename "${fg_tif}" .tif)"
  
  echo "Processing: ${base_name}"

  # Получаем параметры изображения
  local geometry=$(identify -format "%w %h %z %x" "${fg_tif}" 2>/dev/null)
  local width=$(echo "${geometry}" | awk '{print $1}')
  local height=$(echo "${geometry}" | awk '{print $2}')
  local bitdepth=$(echo "${geometry}" | awk '{print $3}')
  local dpi=$(echo "${geometry}" | awk '{print $4}' | awk -F. '{print $1}')
  dpi=${dpi:-600}

  # Обработка foreground
  if [ "$bitdepth" -gt 1 ]; then
    echo "  Generate Sjbz and FGbz for colored foreground"
    tifftopnm "${fg_tif}" > "${OUT_DIR}/${base_name}_fg.pnm"
    cpaldjvu -dpi "${dpi}" -bgwhite "${OUT_DIR}/${base_name}_fg.pnm" "${OUT_DIR}/${base_name}_fg.djvu"
    djvuextract "${OUT_DIR}/${base_name}_fg.djvu" \
      "Sjbz=${OUT_DIR}/${base_name}.sjbz" \
      "FGbz=${OUT_DIR}/${base_name}.fgbz"
    fg_params="Sjbz=${OUT_DIR}/${base_name}.sjbz FGbz=${OUT_DIR}/${base_name}.fgbz"
  else
    echo "  Generate Sjbz for 1-bit foreground"
    cjb2 -dpi "${dpi}" "${fg_tif}" "${OUT_DIR}/${base_name}_fg.djvu"
    djvuextract "${OUT_DIR}/${base_name}_fg.djvu" "Sjbz=${OUT_DIR}/${base_name}.sjbz"
    fg_params="Sjbz=${OUT_DIR}/${base_name}.sjbz"
  fi

  # Обработка background если существует
  local bg_params=""
  local bg_tif="${BACKGROUND_DIR}/${base_name}.tif"
  if [ -f "${bg_tif}" ]; then
    tifftopnm "${bg_tif}" > "${OUT_DIR}/${base_name}.pnm"
    c44 -dpi "${dpi}" "${OUT_DIR}/${base_name}.pnm" "${OUT_DIR}/${base_name}_bg.djvu"
    djvuextract "${OUT_DIR}/${base_name}_bg.djvu" "BG44=${OUT_DIR}/${base_name}.bg44"
    bg_params="BG44=${OUT_DIR}/${base_name}.bg44"
  fi

  # Сборка страницы
  djvumake_cmd="djvumake ${OUT_DIR}/${base_name}.djvu INFO=${width},${height},${dpi}"
  [ -n "$fg_params" ] && djvumake_cmd+=" $fg_params"
  [ -n "$bg_params" ] && djvumake_cmd+=" $bg_params"
  
  eval "$djvumake_cmd"

  # Очистка промежуточных файлов
  rm -f \
    "${OUT_DIR}/${base_name}_fg.djvu" \
    "${OUT_DIR}/${base_name}_fg.pnm" \
    "${OUT_DIR}/${base_name}_bg.djvu" \
    "${OUT_DIR}/${base_name}.pnm" \
    "${OUT_DIR}/${base_name}.sjbz" \
    "${OUT_DIR}/${base_name}.fgbz" \
    "${OUT_DIR}/${base_name}.bg44" 2>/dev/null
}

# Основной цикл обработки
find "${FOREGROUND_DIR}" -name "*.tif" | while read fg_file; do
  process_file "${fg_file}"
done

# Создание многостраничного DJVU
djvm -c "processed/${FILE_NAME}.djvu" "${OUT_DIR}"/*.djvu

# Финальная очистка
rm -f "${OUT_DIR}"/*.djvu
echo "Processing complete. Result: processed/${FILE_NAME}.djvu"