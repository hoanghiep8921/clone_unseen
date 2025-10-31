#!/bin/bash

# Script apply tất cả tối ưu JS

SCRIPTS_DIR="wp-content/themes/unseen/public/scripts"

echo "🎯 ÁP DỤNG TOÀN BỘ TỐI ƯU JS"
echo "==================================================
"
echo ""

# Check if minified files exist
if [ ! -f "$SCRIPTS_DIR/vendor.min.js" ]; then
    echo "❌ vendor.min.js không tồn tại!"
    echo "   Chạy: node optimize-vendor.js && npx terser ..."
    exit 1
fi

if [ ! -f "$SCRIPTS_DIR/theme.min.js" ]; then
    echo "❌ theme.min.js không tồn tại!"
    echo "   Chạy: node optimize-all-js.js"
    exit 1
fi

if [ ! -f "$SCRIPTS_DIR/manifest.min.js" ]; then
    echo "❌ manifest.min.js không tồn tại!"
    echo "   Chạy: node optimize-all-js.js"
    exit 1
fi

# Display summary
echo "📊 TỔNG KẾT TỐI ƯU"
echo "==================================================
"
echo ""
echo "┌─────────────────┬──────────┬──────────┬─────────┐"
echo "│ File            │ Gốc      │ Minified │ Giảm    │"
echo "├─────────────────┼──────────┼──────────┼─────────┤"

# vendor.js
VENDOR_OLD=$(du -k "$SCRIPTS_DIR/vendor.js" | cut -f1)
VENDOR_NEW=$(du -k "$SCRIPTS_DIR/vendor.min.js" | cut -f1)
VENDOR_SAVE=$((VENDOR_OLD - VENDOR_NEW))
VENDOR_PERCENT=$((VENDOR_SAVE * 100 / VENDOR_OLD))
printf "│ %-15s │ %6sK │ %6sK │ %6s%% │\n" "vendor.js" "$VENDOR_OLD" "$VENDOR_NEW" "$VENDOR_PERCENT"

# theme.js
THEME_OLD=$(du -k "$SCRIPTS_DIR/theme.js" | cut -f1)
THEME_NEW=$(du -k "$SCRIPTS_DIR/theme.min.js" | cut -f1)
THEME_SAVE=$((THEME_OLD - THEME_NEW))
THEME_PERCENT=$((THEME_SAVE * 100 / THEME_OLD))
printf "│ %-15s │ %6sK │ %6sK │ %6s%% │\n" "theme.js" "$THEME_OLD" "$THEME_NEW" "$THEME_PERCENT"

# manifest.js
MANIFEST_OLD=$(du -k "$SCRIPTS_DIR/manifest.js" | cut -f1)
MANIFEST_NEW=$(du -k "$SCRIPTS_DIR/manifest.min.js" | cut -f1)
MANIFEST_SAVE=$((MANIFEST_OLD - MANIFEST_NEW))
MANIFEST_PERCENT=$((MANIFEST_SAVE * 100 / MANIFEST_OLD))
printf "│ %-15s │ %6sK │ %6sK │ %6s%% │\n" "manifest.js" "$MANIFEST_OLD" "$MANIFEST_NEW" "$MANIFEST_PERCENT"

echo "└─────────────────┴──────────┴──────────┴─────────┘"

TOTAL_OLD=$((VENDOR_OLD + THEME_OLD + MANIFEST_OLD))
TOTAL_NEW=$((VENDOR_NEW + THEME_NEW + MANIFEST_NEW))
TOTAL_SAVE=$((TOTAL_OLD - TOTAL_NEW))
TOTAL_PERCENT=$((TOTAL_SAVE * 100 / TOTAL_OLD))

echo ""
echo "📦 Tổng kích thước gốc:     ${TOTAL_OLD} KB"
echo "📦 Tổng kích thước minified: ${TOTAL_NEW} KB"
echo "✅ Tổng tiết kiệm:          ${TOTAL_SAVE} KB (${TOTAL_PERCENT}%)"

echo ""
echo ""
echo "⚠️  CẢNH BÁO QUAN TRỌNG"
echo "==================================================
"
echo ""
echo "Backup files đã được tạo sẵn:"
echo "   • vendor.backup.js"
echo "   • theme.backup.js"
echo "   • manifest.backup.js"
echo ""
echo "Nếu có lỗi, bạn có thể restore bằng:"
echo "   $ ./restore-from-backup.sh"
echo ""
echo ""
echo "Bạn có chắc chắn muốn apply? (yes/no)"
read -r response

if [[ "$response" != "yes" ]]; then
    echo ""
    echo "❌ Hủy bỏ. Không có thay đổi nào được thực hiện."
    exit 0
fi

echo ""
echo "🔄 Đang apply tối ưu..."
echo ""

# Apply vendor.js
echo "   📝 Applying vendor.js..."
if [ -f "$SCRIPTS_DIR/vendor.backup.js" ]; then
    cp "$SCRIPTS_DIR/vendor.min.js" "$SCRIPTS_DIR/vendor.js"
    echo "   ✅ vendor.js updated"
else
    echo "   ⚠️  Backup not found, creating one first..."
    cp "$SCRIPTS_DIR/vendor.js" "$SCRIPTS_DIR/vendor.backup.js"
    cp "$SCRIPTS_DIR/vendor.min.js" "$SCRIPTS_DIR/vendor.js"
    echo "   ✅ vendor.js updated"
fi

# Apply theme.js
echo "   📝 Applying theme.js..."
if [ -f "$SCRIPTS_DIR/theme.backup.js" ]; then
    cp "$SCRIPTS_DIR/theme.min.js" "$SCRIPTS_DIR/theme.js"
    echo "   ✅ theme.js updated"
else
    echo "   ⚠️  Backup not found, creating one first..."
    cp "$SCRIPTS_DIR/theme.js" "$SCRIPTS_DIR/theme.backup.js"
    cp "$SCRIPTS_DIR/theme.min.js" "$SCRIPTS_DIR/theme.js"
    echo "   ✅ theme.js updated"
fi

# Apply manifest.js
echo "   📝 Applying manifest.js..."
if [ -f "$SCRIPTS_DIR/manifest.backup.js" ]; then
    cp "$SCRIPTS_DIR/manifest.min.js" "$SCRIPTS_DIR/manifest.js"
    echo "   ✅ manifest.js updated"
else
    echo "   ⚠️  Backup not found, creating one first..."
    cp "$SCRIPTS_DIR/manifest.js" "$SCRIPTS_DIR/manifest.backup.js"
    cp "$SCRIPTS_DIR/manifest.min.js" "$SCRIPTS_DIR/manifest.js"
    echo "   ✅ manifest.js updated"
fi

echo ""
echo "✨ HOÀN THÀNH!"
echo "==================================================
"
echo ""
echo "📊 Kết quả:"
echo "   • vendor.js:   $VENDOR_OLD KB → $VENDOR_NEW KB (-$VENDOR_PERCENT%)"
echo "   • theme.js:    $THEME_OLD KB → $THEME_NEW KB (-$THEME_PERCENT%)"
echo "   • manifest.js: $MANIFEST_OLD KB → $MANIFEST_NEW KB (-$MANIFEST_PERCENT%)"
echo ""
echo "   🎉 Tổng tiết kiệm: $TOTAL_SAVE KB ($TOTAL_PERCENT%)"
echo ""
echo ""
echo "🧪 TIẾP THEO - TEST WEBSITE"
echo "==================================================
"
echo ""
echo "1. Clear browser cache (Ctrl+Shift+R / Cmd+Shift+R)"
echo "2. Mở website và kiểm tra:"
echo "   • Console (F12) - không có lỗi"
echo "   • Smooth scroll hoạt động"
echo "   • Navigation hoạt động"
echo "   • Page transitions hoạt động"
echo "   • Animations hoạt động"
echo "   • Mobile responsive"
echo ""
echo "3. Nếu có lỗi, restore ngay:"
echo "   $ ./restore-from-backup.sh"
echo ""
echo "4. Nếu mọi thứ OK, dọn dẹp:"
echo "   $ ./cleanup-optimization-files.sh"
echo ""
