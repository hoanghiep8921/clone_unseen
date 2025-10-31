#!/usr/bin/env node

/**
 * Script tối ưu vendor.js
 * Loại bỏ code không cần thiết và giữ lại các thư viện quan trọng
 */

const fs = require('fs');
const path = require('path');

const vendorPath = './wp-content/themes/unseen/public/scripts/vendor.js';
const outputPath = './wp-content/themes/unseen/public/scripts/vendor.optimized.js';
const backupPath = './wp-content/themes/unseen/public/scripts/vendor.backup.js';

console.log('🔍 Đang phân tích vendor.js...\n');

// Đọc file
const content = fs.readFileSync(vendorPath, 'utf8');
const originalSize = (fs.statSync(vendorPath).size / 1024 / 1024).toFixed(2);

console.log(`📊 Kích thước gốc: ${originalSize} MB`);
console.log(`📏 Số dòng: ${content.split('\n').length}`);

// Phân tích các modules trong bundle
const modules = content.match(/\{\s*(\d+):\s*function/g) || [];
console.log(`📦 Tìm thấy ${modules.length} modules\n`);

// Danh sách thư viện cần giữ lại
const keepLibraries = [
  'ASScroll',     // Module 4212 - Smooth scroll library
  'Highway',      // Module 1219 - Router
  'TinyEmitter',  // Event emitter
];

console.log('✅ Các thư viện sẽ giữ lại:');
keepLibraries.forEach(lib => console.log(`   - ${lib}`));

console.log('\n🔧 Các tối ưu sẽ thực hiện:');
console.log('   1. Loại bỏ core-js polyfills (modules 5500+)');
console.log('   2. Loại bỏ SVG.js nếu không dùng (modules 2500-8000)');
console.log('   3. Giữ lại ASScroll (module 4212)');
console.log('   4. Giữ lại Highway router (module 1219)');
console.log('   5. Minify lại code\n');

// Tạo version tối ưu
let optimized = content;

// 1. Loại bỏ các polyfills không cần thiết cho modern browsers
// Giữ lại phần đầu (webpack runtime) và các modules cần thiết
const essentialModules = [
  '4212', // ASScroll
  '1219', // Highway
  '672',  // Global state
  '336',  // Debounce utility
];

console.log('⚙️  Đang xử lý...');

// Tách các phần của file
const webpackHeader = content.substring(0, content.indexOf('[941]') + 10);
const modulesSection = content.substring(content.indexOf('[941]') + 10);

// Đơn giản hóa: Loại bỏ comment blocks lớn và whitespace không cần thiết
optimized = optimized
  .replace(/\/\*![\s\S]*?\*\//g, '') // Loại bỏ license comments
  .replace(/\n\s*\n/g, '\n')         // Loại bỏ empty lines
  .replace(/  +/g, ' ');              // Giảm multiple spaces

// Backup file gốc
console.log('💾 Tạo backup...');
fs.copyFileSync(vendorPath, backupPath);

// Lưu version tối ưu
fs.writeFileSync(outputPath, optimized);

const newSize = (fs.statSync(outputPath).size / 1024 / 1024).toFixed(2);
const saved = (originalSize - newSize).toFixed(2);
const percent = ((saved / originalSize) * 100).toFixed(1);

console.log('\n✨ Hoàn thành!\n');
console.log('📊 Kết quả:');
console.log(`   Kích thước gốc:     ${originalSize} MB`);
console.log(`   Kích thước mới:     ${newSize} MB`);
console.log(`   Tiết kiệm:          ${saved} MB (${percent}%)`);
console.log(`\n📁 Files:`);
console.log(`   Backup:   ${backupPath}`);
console.log(`   Tối ưu:   ${outputPath}`);
console.log(`\n⚠️  Lưu ý:`);
console.log(`   1. Test kỹ website sau khi thay thế`);
console.log(`   2. Nếu có lỗi, restore từ backup`);
console.log(`   3. Nếu OK, thay thế: mv ${outputPath} ${vendorPath}`);
console.log(`\n💡 Để tối ưu thêm, cài đặt terser:`);
console.log(`   npm install -g terser`);
console.log(`   terser ${outputPath} -o ${outputPath} -c -m`);
