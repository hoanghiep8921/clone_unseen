#!/bin/bash

# Script cleanup các file tạm sau khi tối ưu thành công

SCRIPTS_DIR="wp-content/themes/unseen/public/scripts"

echo "🧹 DỌN DẸP FILES TỐI ƯU"
echo "==================================================
"
echo ""
echo "⚠️  Script này sẽ xóa:"
echo "   • Các file .backup.js"
echo "   • Các file .optimized.js"
echo "   • Các file .min.js"
echo "   • Các file .old.js"
echo ""
echo "Chỉ chạy script này khi đã test và confirm mọi thứ hoạt động OK!"
echo ""
echo "Bạn có chắc chắn muốn tiếp tục? (yes/no)"
read -r response

if [[ "$response" != "yes" ]]; then
    echo ""
    echo "❌ Hủy bỏ cleanup."
    exit 0
fi

echo ""
echo "🗑️  Đang xóa files..."

deleted=0

# Remove backup files
for file in "$SCRIPTS_DIR"/*.backup.js; do
    if [ -f "$file" ]; then
        echo "   Xóa $(basename "$file")"
        rm "$file"
        deleted=$((deleted + 1))
    fi
done

# Remove optimized files
for file in "$SCRIPTS_DIR"/*.optimized.js; do
    if [ -f "$file" ]; then
        echo "   Xóa $(basename "$file")"
        rm "$file"
        deleted=$((deleted + 1))
    fi
done

# Remove min files
for file in "$SCRIPTS_DIR"/*.min.js; do
    if [ -f "$file" ]; then
        echo "   Xóa $(basename "$file")"
        rm "$file"
        deleted=$((deleted + 1))
    fi
done

# Remove old files
for file in "$SCRIPTS_DIR"/*.old.js; do
    if [ -f "$file" ]; then
        echo "   Xóa $(basename "$file")"
        rm "$file"
        deleted=$((deleted + 1))
    fi
done

# Remove optimization scripts
echo ""
echo "Xóa optimization scripts? (yes/no)"
read -r response2

if [[ "$response2" == "yes" ]]; then
    [ -f "optimize-vendor.js" ] && rm "optimize-vendor.js" && echo "   Xóa optimize-vendor.js" && deleted=$((deleted + 1))
    [ -f "optimize-all-js.js" ] && rm "optimize-all-js.js" && echo "   Xóa optimize-all-js.js" && deleted=$((deleted + 1))
    [ -f "apply-optimized-vendor.sh" ] && rm "apply-optimized-vendor.sh" && echo "   Xóa apply-optimized-vendor.sh" && deleted=$((deleted + 1))
    [ -f "apply-all-optimizations.sh" ] && rm "apply-all-optimizations.sh" && echo "   Xóa apply-all-optimizations.sh" && deleted=$((deleted + 1))
    [ -f "restore-from-backup.sh" ] && rm "restore-from-backup.sh" && echo "   Xóa restore-from-backup.sh" && deleted=$((deleted + 1))
    [ -f "cleanup-optimization-files.sh" ] && rm "cleanup-optimization-files.sh" && echo "   Xóa cleanup-optimization-files.sh (chính nó)" && deleted=$((deleted + 1))
    [ -f "VENDOR-OPTIMIZATION.md" ] && rm "VENDOR-OPTIMIZATION.md" && echo "   Xóa VENDOR-OPTIMIZATION.md" && deleted=$((deleted + 1))
fi

echo ""
echo "✨ Hoàn thành! Đã xóa $deleted file(s)."
echo ""
echo "📁 Files còn lại trong $SCRIPTS_DIR:"
ls -lh "$SCRIPTS_DIR"/*.js | awk '{print "   " $9, "-", $5}'
echo ""
