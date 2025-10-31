#!/bin/bash

# Script restore từ backup

SCRIPTS_DIR="wp-content/themes/unseen/public/scripts"

echo "🔄 RESTORE TỪ BACKUP"
echo "==================================================
"
echo ""

restored=0

# Restore vendor.js
if [ -f "$SCRIPTS_DIR/vendor.backup.js" ]; then
    echo "📝 Restoring vendor.js..."
    cp "$SCRIPTS_DIR/vendor.backup.js" "$SCRIPTS_DIR/vendor.js"
    echo "✅ vendor.js restored"
    restored=$((restored + 1))
else
    echo "⚠️  vendor.backup.js không tồn tại"
fi

# Restore theme.js
if [ -f "$SCRIPTS_DIR/theme.backup.js" ]; then
    echo "📝 Restoring theme.js..."
    cp "$SCRIPTS_DIR/theme.backup.js" "$SCRIPTS_DIR/theme.js"
    echo "✅ theme.js restored"
    restored=$((restored + 1))
else
    echo "⚠️  theme.backup.js không tồn tại"
fi

# Restore manifest.js
if [ -f "$SCRIPTS_DIR/manifest.backup.js" ]; then
    echo "📝 Restoring manifest.js..."
    cp "$SCRIPTS_DIR/manifest.backup.js" "$SCRIPTS_DIR/manifest.js"
    echo "✅ manifest.js restored"
    restored=$((restored + 1))
else
    echo "⚠️  manifest.backup.js không tồn tại"
fi

echo ""
if [ $restored -gt 0 ]; then
    echo "✨ Restore hoàn thành! $restored file(s) được restore."
    echo ""
    echo "🔄 Reload website và clear cache (Ctrl+Shift+R)"
else
    echo "❌ Không tìm thấy backup files nào!"
fi
echo ""
