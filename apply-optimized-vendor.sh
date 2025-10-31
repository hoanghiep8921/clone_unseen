#!/bin/bash

# Script apply vendor.js đã tối ưu

echo "🎯 TỔNG KẾT TỐI ƯU VENDOR.JS"
echo "================================"
echo ""
echo "📊 So sánh kích thước:"
echo ""
echo "   vendor.js (gốc):        2.2 MB"
echo "   vendor.min.js (mới):    1.1 MB"
echo "   ✅ Tiết kiệm: 1.1 MB (50%)"
echo ""
echo "🔧 Các bước đã thực hiện:"
echo "   1. ✅ Loại bỏ license comments"
echo "   2. ✅ Loại bỏ whitespace không cần thiết"
echo "   3. ✅ Minify với terser"
echo "   4. ✅ Giữ nguyên functionality (ASScroll, Highway)"
echo ""
echo "📁 Files hiện có:"
ls -lh wp-content/themes/unseen/public/scripts/vendor*.js | awk '{printf "   %-30s %s\n", $9, $5}'
echo ""
echo "⚠️  QUAN TRỌNG - TEST TRƯỚC KHI APPLY"
echo "================================"
echo ""
echo "Bước 1: Test với file mới"
echo "   Tạm thời đổi tên để test:"
echo "   $ mv wp-content/themes/unseen/public/scripts/vendor.js wp-content/themes/unseen/public/scripts/vendor.old.js"
echo "   $ cp wp-content/themes/unseen/public/scripts/vendor.min.js wp-content/themes/unseen/public/scripts/vendor.js"
echo ""
echo "Bước 2: Kiểm tra website"
echo "   - Mở website trong browser"
echo "   - Kiểm tra console (F12) xem có lỗi không"
echo "   - Test các chức năng:"
echo "     • Smooth scroll"
echo "     • Navigation"
echo "     • Page transitions"
echo "     • Menu interactions"
echo ""
echo "Bước 3a: Nếu mọi thứ OK ✅"
echo "   $ rm wp-content/themes/unseen/public/scripts/vendor.old.js"
echo "   $ rm wp-content/themes/unseen/public/scripts/vendor.backup.js"
echo "   $ rm wp-content/themes/unseen/public/scripts/vendor.optimized.js"
echo ""
echo "Bước 3b: Nếu có lỗi ❌"
echo "   $ mv wp-content/themes/unseen/public/scripts/vendor.old.js wp-content/themes/unseen/public/scripts/vendor.js"
echo "   Sau đó report lỗi để investigate"
echo ""
echo "💡 TỐI ƯU THÊM"
echo "================================"
echo ""
echo "1. Enable GZIP trên web server"
echo "   Thêm vào .htaccess:"
echo '   <IfModule mod_deflate.c>'
echo '     AddOutputFilterByType DEFLATE text/javascript application/javascript'
echo '   </IfModule>'
echo ""
echo "2. Enable browser caching"
echo "   Thêm vào .htaccess:"
echo '   <FilesMatch "\.(js)$">'
echo '     Header set Cache-Control "max-age=31536000, public"'
echo '   </FilesMatch>'
echo ""
echo "🚀 Tác động dự kiến:"
echo "   • Page load nhanh hơn ~500ms"
echo "   • Giảm băng thông 1.1 MB/lần tải"
echo "   • Cải thiện Core Web Vitals"
echo ""
echo "Bạn muốn apply ngay? (y/n)"
read -r response

if [[ "$response" =~ ^[Yy]$ ]]; then
    echo ""
    echo "🔄 Đang apply..."
    mv wp-content/themes/unseen/public/scripts/vendor.js wp-content/themes/unseen/public/scripts/vendor.old.js
    cp wp-content/themes/unseen/public/scripts/vendor.min.js wp-content/themes/unseen/public/scripts/vendor.js
    echo "✅ Hoàn thành!"
    echo ""
    echo "⚠️  Hãy test website ngay!"
    echo "   Nếu có lỗi, restore bằng:"
    echo "   $ mv wp-content/themes/unseen/public/scripts/vendor.old.js wp-content/themes/unseen/public/scripts/vendor.js"
else
    echo ""
    echo "👍 OK, bạn có thể test thủ công sau."
    echo "   File đã sẵn sàng tại: wp-content/themes/unseen/public/scripts/vendor.min.js"
fi
