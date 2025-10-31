#!/usr/bin/env node

/**
 * Script tối ưu tất cả JS files
 * Xử lý theme.js và manifest.js
 */

const fs = require('fs');
const path = require('path');

const scriptsDir = './wp-content/themes/unseen/public/scripts';

const files = [
  {
    name: 'theme.js',
    path: `${scriptsDir}/theme.js`,
  },
  {
    name: 'manifest.js', 
    path: `${scriptsDir}/manifest.js`,
  }
];

console.log('🚀 TỐI ƯU TOÀN BỘ JS FILES');
console.log('=' .repeat(50));
console.log('');

const results = [];

files.forEach(file => {
  if (!fs.existsSync(file.path)) {
    console.log(`⚠️  ${file.name} không tồn tại, bỏ qua...`);
    return;
  }

  console.log(`\n📦 Đang xử lý ${file.name}...`);
  
  // Đọc file
  const content = fs.readFileSync(file.path, 'utf8');
  const originalSize = fs.statSync(file.path).size;
  const lines = content.split('\n').length;
  
  console.log(`   📏 Số dòng: ${lines.toLocaleString()}`);
  console.log(`   📊 Kích thước: ${(originalSize / 1024).toFixed(2)} KB`);
  
  // Tối ưu cơ bản - chỉ loại bỏ license comments và whitespace
  let optimized = content
    .replace(/\/\*!.*?For license information.*?\*\//gs, '')  // License header only
    .replace(/\n\s*\n\s*\n/g, '\n\n')     // Multiple empty lines
    .replace(/^\s+$/gm, '')               // Empty lines with spaces
    .trim();
  
  // Backup
  const backupPath = file.path.replace('.js', '.backup.js');
  const optimizedPath = file.path.replace('.js', '.optimized.js');
  
  if (!fs.existsSync(backupPath)) {
    fs.copyFileSync(file.path, backupPath);
    console.log(`   💾 Backup: ${path.basename(backupPath)}`);
  } else {
    console.log(`   ℹ️  Backup đã tồn tại, bỏ qua...`);
  }
  
  // Save optimized version
  fs.writeFileSync(optimizedPath, optimized);
  const optimizedSize = fs.statSync(optimizedPath).size;
  const saved = originalSize - optimizedSize;
  const percent = ((saved / originalSize) * 100).toFixed(1);
  
  console.log(`   ✅ Tối ưu: ${(optimizedSize / 1024).toFixed(2)} KB`);
  console.log(`   📉 Tiết kiệm: ${(saved / 1024).toFixed(2)} KB (${percent}%)`);
  
  results.push({
    name: file.name,
    originalSize,
    optimizedSize,
    saved,
    percent,
    backupPath,
    optimizedPath
  });
});

// Minify với terser
console.log('\n\n🔧 MINIFYING VỚI TERSER...');
console.log('=' .repeat(50));

results.forEach(result => {
  const minPath = result.optimizedPath.replace('.optimized.js', '.min.js');
  
  console.log(`\n⚙️  Minify ${result.name}...`);
  
  try {
    const { execSync } = require('child_process');
    execSync(`npx -y terser ${result.optimizedPath} -o ${minPath} -c -m`, {
      stdio: 'pipe'
    });
    
    const minSize = fs.statSync(minPath).size;
    const totalSaved = result.originalSize - minSize;
    const totalPercent = ((totalSaved / result.originalSize) * 100).toFixed(1);
    
    result.minSize = minSize;
    result.totalSaved = totalSaved;
    result.totalPercent = totalPercent;
    result.minPath = minPath;
    
    console.log(`   ✅ Hoàn thành: ${(minSize / 1024).toFixed(2)} KB`);
    console.log(`   📉 Tổng tiết kiệm: ${(totalSaved / 1024).toFixed(2)} KB (${totalPercent}%)`);
  } catch (error) {
    console.log(`   ❌ Lỗi: ${error.message}`);
  }
});

// Summary
console.log('\n\n📊 TỔNG KẾT');
console.log('=' .repeat(50));
console.log('');

let totalOriginal = 0;
let totalMinified = 0;

results.forEach(result => {
  totalOriginal += result.originalSize;
  if (result.minSize) {
    totalMinified += result.minSize;
  }
});

console.log('┌─────────────────┬──────────┬──────────┬──────────┬─────────┐');
console.log('│ File            │ Gốc      │ Tối ưu   │ Minified │ Giảm    │');
console.log('├─────────────────┼──────────┼──────────┼──────────┼─────────┤');

results.forEach(result => {
  const name = result.name.padEnd(15);
  const orig = `${(result.originalSize / 1024).toFixed(0)}K`.padStart(8);
  const opt = `${(result.optimizedSize / 1024).toFixed(0)}K`.padStart(8);
  const min = result.minSize ? `${(result.minSize / 1024).toFixed(0)}K`.padStart(8) : '   -    ';
  const saved = result.totalPercent ? `${result.totalPercent}%`.padStart(7) : '   -   ';
  
  console.log(`│ ${name} │ ${orig} │ ${opt} │ ${min} │ ${saved} │`);
});

console.log('└─────────────────┴──────────┴──────────┴──────────┴─────────┘');

const totalSaved = totalOriginal - totalMinified;
const totalPercent = ((totalSaved / totalOriginal) * 100).toFixed(1);

console.log('');
console.log(`📦 Tổng kích thước gốc:     ${(totalOriginal / 1024).toFixed(2)} KB`);
console.log(`📦 Tổng kích thước minified: ${(totalMinified / 1024).toFixed(2)} KB`);
console.log(`✅ Tổng tiết kiệm:          ${(totalSaved / 1024).toFixed(2)} KB (${totalPercent}%)`);

console.log('\n\n📁 FILES ĐÃ TẠO');
console.log('=' .repeat(50));
results.forEach(result => {
  console.log(`\n${result.name}:`);
  console.log(`   📄 Backup:    ${path.basename(result.backupPath)}`);
  console.log(`   📄 Optimized: ${path.basename(result.optimizedPath)}`);
  if (result.minPath) {
    console.log(`   ⭐ Minified:  ${path.basename(result.minPath)}`);
  }
});

console.log('\n\n🎯 TIẾP THEO');
console.log('=' .repeat(50));
console.log('');
console.log('1. Test website với các file minified');
console.log('2. Nếu OK, chạy script apply:');
console.log('   $ ./apply-all-optimizations.sh');
console.log('');
console.log('3. Hoặc apply thủ công:');
results.forEach(result => {
  if (result.minPath) {
    const original = result.minPath.replace('.min.js', '.js');
    console.log(`   $ cp ${result.minPath} ${original}`);
  }
});
console.log('');
console.log('4. Nếu có lỗi, restore từ backup:');
results.forEach(result => {
  const original = result.backupPath.replace('.backup.js', '.js');
  console.log(`   $ cp ${result.backupPath} ${original}`);
});
console.log('');
