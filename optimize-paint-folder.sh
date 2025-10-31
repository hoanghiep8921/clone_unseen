#!/bin/bash

# SCRIPT TỐI ƯU HÓA ẢNH THƯ MỤC PAINT
# - Tối ưu các file mới trong wp-content/uploads/art-digital/paint/
# - Giữ nguyên tên file
# - Tạo backup riêng cho thư mục paint

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PAINT_DIR="wp-content/uploads/art-digital/paint"
BACKUP_DIR="wp-content/uploads/art-digital/paint-backup-$(date +%Y%m%d_%H%M%S)"
LOG_FILE="paint-optimization-$(date +%Y%m%d_%H%M%S).log"
PROGRESS_FILE="paint-optimization-progress.txt"
MAX_PARALLEL=4  # Số lượng file xử lý song song

# Statistics
TOTAL_FILES=0
PROCESSED_FILES=0
TOTAL_ORIGINAL_SIZE=0
TOTAL_OPTIMIZED_SIZE=0
TOTAL_SAVED=0
START_TIME=$(date +%s)

# Create backup directory
echo -e "${BLUE}📦 Creating backup directory for paint folder...${NC}"
mkdir -p "$BACKUP_DIR"

# Create log file
echo "Paint Folder Optimization Log - $(date)" > "$LOG_FILE"
echo "=====================================" >> "$LOG_FILE"

# Function to get file size in bytes
get_file_size() {
    stat -f%z "$1" 2>/dev/null || stat -c%s "$1" 2>/dev/null || echo 0
}

# Function to format size
format_size() {
    local bytes=$1
    if [ $bytes -ge 1073741824 ]; then
        echo "$(echo "scale=2; $bytes/1073741824" | bc)GB"
    elif [ $bytes -ge 1048576 ]; then
        echo "$(echo "scale=2; $bytes/1048576" | bc)MB"
    elif [ $bytes -ge 1024 ]; then
        echo "$(echo "scale=2; $bytes/1024" | bc)KB"
    else
        echo "${bytes}B"
    fi
}

# Function to check if file is already optimized
is_already_optimized() {
    local file="$1"
    local filename=$(basename "$file")
    
    # Check progress file
    if [ -f "$PROGRESS_FILE" ]; then
        if grep -q "^$filename$" "$PROGRESS_FILE"; then
            return 0
        fi
    fi
    
    return 1
}

# Function to mark file as processed
mark_as_processed() {
    local file="$1"
    local filename=$(basename "$file")
    echo "$filename" >> "$PROGRESS_FILE"
}

# Function to optimize a single file
optimize_file() {
    local file="$1"
    local filename=$(basename "$file")
    local extension="${file##*.}"
    local original_size=$(get_file_size "$file")
    
    # Skip if already processed
    if is_already_optimized "$file"; then
        echo -e "${YELLOW}⏭️  Skipping (already optimized): $filename${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}🔄 Optimizing: $filename${NC}"
    
    # Create backup
    cp "$file" "$BACKUP_DIR/$filename"
    
    case "$extension" in
        jpg|jpeg)
            # Optimize with jpegoptim
            jpegoptim --max=85 --strip-all --preserve --totals "$file" >/dev/null 2>&1
            ;;
            
        png)
            # Optimize with optipng
            optipng -o7 -quiet -clobber "$file"
            
            # Additional optimization with magick
            if command -v magick >/dev/null 2>&1; then
                magick "$file" -strip "$file" 2>/dev/null || true
            fi
            ;;
            
        gif)
            # Optimize with magick
            if command -v magick >/dev/null 2>&1; then
                magick "$file" -fuzz 10% -layers Optimize "$file" 2>/dev/null || true
            fi
            ;;
            
        webp)
            # Optimize with magick
            if command -v magick >/dev/null 2>&1; then
                magick "$file" -strip "$file" 2>/dev/null || true
            fi
            ;;
    esac
    
    local optimized_size=$(get_file_size "$file")
    local saved=$((original_size - optimized_size))
    local percent=0
    
    if [ $original_size -gt 0 ]; then
        percent=$(echo "scale=1; ($saved * 100) / $original_size" | bc)
    fi
    
    echo "  Original: $(format_size $original_size) → Optimized: $(format_size $optimized_size) (Saved: $(format_size $saved) - $percent%)"
    echo "$extension: $file - $percent% saved" >> "$LOG_FILE"
    
    # Mark as processed
    mark_as_processed "$file"
    
    # Update statistics
    echo "$original_size" >> /tmp/original_sizes.txt
    echo "$optimized_size" >> /tmp/optimized_sizes.txt
    echo "$filename" >> /tmp/processed_files.txt
}

# Main optimization function
optimize_paint_folder() {
    echo -e "${GREEN}🚀 STARTING PAINT FOLDER OPTIMIZATION${NC}"
    echo -e "${BLUE}📁 Paint directory: $PAINT_DIR${NC}"
    echo -e "${BLUE}💾 Backup directory: $BACKUP_DIR${NC}"
    echo -e "${BLUE}📋 Log file: $LOG_FILE${NC}"
    echo -e "${BLUE}⚡ Parallel processing: $MAX_PARALLEL files${NC}"
    echo ""
    
    # Find all image files in paint directory
    echo -e "${BLUE}🔍 Finding image files in paint folder...${NC}"
    local file_list=$(mktemp)
    find "$PAINT_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" -o -name "*.webp" \) | sort -V > "$file_list"
    
    TOTAL_FILES=$(wc -l < "$file_list")
    echo -e "${BLUE}📁 Found $TOTAL_FILES image files in paint folder${NC}"
    echo ""
    
    # Show files to be processed
    echo -e "${BLUE}📋 Files to optimize:${NC}"
    cat "$file_list" | while read file; do
        local filename=$(basename "$file")
        local size=$(get_file_size "$file")
        echo "  - $filename ($(format_size $size))"
    done
    echo ""
    
    # Process files in parallel
    echo -e "${BLUE}⚡ Starting parallel optimization...${NC}"
    
    # Initialize temp files for statistics
    : > /tmp/original_sizes.txt
    : > /tmp/optimized_sizes.txt
    : > /tmp/processed_files.txt
    
    # Export functions for parallel execution
    export -f optimize_file is_already_optimized mark_as_processed get_file_size format_size
    export PAINT_DIR BACKUP_DIR LOG_FILE PROGRESS_FILE
    
    # Process files in parallel
    cat "$file_list" | xargs -n 1 -P "$MAX_PARALLEL" -I {} bash -c 'optimize_file "$1"' _ "{}"
    
    # Calculate final statistics
    if [ -f /tmp/original_sizes.txt ]; then
        TOTAL_ORIGINAL_SIZE=$(awk '{sum += $1} END {print sum}' /tmp/original_sizes.txt)
        TOTAL_OPTIMIZED_SIZE=$(awk '{sum += $1} END {print sum}' /tmp/optimized_sizes.txt)
        PROCESSED_FILES=$(wc -l < /tmp/processed_files.txt)
        TOTAL_SAVED=$((TOTAL_ORIGINAL_SIZE - TOTAL_OPTIMIZED_SIZE))
    fi
    
    local total_percent=0
    if [ $TOTAL_ORIGINAL_SIZE -gt 0 ]; then
        total_percent=$(echo "scale=1; ($TOTAL_SAVED * 100) / $TOTAL_ORIGINAL_SIZE" | bc)
    fi
    
    local elapsed=$(( $(date +%s) - START_TIME ))
    local minutes=$(( elapsed / 60 ))
    local seconds=$(( elapsed % 60 ))
    
    echo ""
    echo -e "${GREEN}📊 PAINT FOLDER OPTIMIZATION COMPLETE!${NC}"
    echo -e "${GREEN}======================================${NC}"
    echo -e "${BLUE}📁 Files processed: $PROCESSED_FILES/$TOTAL_FILES${NC}"
    echo -e "${BLUE}⏱️  Time taken: ${minutes}m ${seconds}s${NC}"
    echo -e "${BLUE}📦 Original size: $(format_size $TOTAL_ORIGINAL_SIZE)${NC}"
    echo -e "${BLUE}📦 Optimized size: $(format_size $TOTAL_OPTIMIZED_SIZE)${NC}"
    echo -e "${GREEN}✅ Total saved: $(format_size $TOTAL_SAVED) ($total_percent%)${NC}"
    echo ""
    echo -e "${BLUE}📋 Detailed log saved to: $LOG_FILE${NC}"
    echo -e "${BLUE}💾 Backup saved to: $BACKUP_DIR${NC}"
    echo -e "${BLUE}📝 Progress file: $PROGRESS_FILE${NC}"
    echo ""
    
    # Save final statistics to log
    echo "" >> "$LOG_FILE"
    echo "FINAL STATISTICS:" >> "$LOG_FILE"
    echo "=================" >> "$LOG_FILE"
    echo "Files processed: $PROCESSED_FILES/$TOTAL_FILES" >> "$LOG_FILE"
    echo "Time taken: ${minutes}m ${seconds}s" >> "$LOG_FILE"
    echo "Original size: $(format_size $TOTAL_ORIGINAL_SIZE)" >> "$LOG_FILE"
    echo "Optimized size: $(format_size $TOTAL_OPTIMIZED_SIZE)" >> "$LOG_FILE"
    echo "Total saved: $(format_size $TOTAL_SAVED) ($total_percent%)" >> "$LOG_FILE"
    
    # Clean up temp files
    rm -f /tmp/original_sizes.txt /tmp/optimized_sizes.txt /tmp/processed_files.txt "$file_list"
}

# Check if paint directory exists
if [ ! -d "$PAINT_DIR" ]; then
    echo -e "${RED}❌ Error: Paint directory not found: $PAINT_DIR${NC}"
    exit 1
fi

# Check if required tools are available
if ! command -v jpegoptim >/dev/null 2>&1; then
    echo -e "${RED}❌ Error: jpegoptim not found. Please install it first.${NC}"
    exit 1
fi

if ! command -v optipng >/dev/null 2>&1; then
    echo -e "${RED}❌ Error: optipng not found. Please install it first.${NC}"
    exit 1
fi

# Run optimization
optimize_paint_folder

echo -e "${GREEN}🎉 Paint folder optimization completed successfully!${NC}"
echo -e "${YELLOW}💡 To restore original files, use: cp -r $BACKUP_DIR/* $PAINT_DIR/${NC}"
echo -e "${YELLOW}💡 To run again (will skip optimized files): ./optimize-paint-folder.sh${NC}"
echo -e "${YELLOW}💡 To start fresh: rm $PROGRESS_FILE && ./optimize-paint-folder.sh${NC}"
