#!/bin/bash

# SCRIPT TỐI ƯU HÓA ẢNH TOÀN DIỆN CHO WEBSITE
# Hỗ trợ: JPG, PNG, GIF, WebP, SVG, KTX2

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
UPLOADS_DIR="wp-content/uploads"
BACKUP_DIR="wp-content/uploads-backup-$(date +%Y%m%d_%H%M%S)"
LOG_FILE="image-optimization-$(date +%Y%m%d_%H%M%S).log"

# Statistics
TOTAL_FILES=0
TOTAL_ORIGINAL_SIZE=0
TOTAL_OPTIMIZED_SIZE=0
TOTAL_SAVED=0

# Create backup directory
echo -e "${BLUE}📦 Creating backup directory...${NC}"
mkdir -p "$BACKUP_DIR"

# Create log file
echo "Image Optimization Log - $(date)" > "$LOG_FILE"
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

# Function to optimize JPEG files
optimize_jpeg() {
    local file="$1"
    local original_size=$(get_file_size "$file")
    
    echo -e "${YELLOW}🔄 Optimizing JPEG: $(basename "$file")${NC}"
    
    # Create backup
    cp "$file" "$BACKUP_DIR/$(basename "$file")"
    
    # Optimize with jpegoptim
    jpegoptim --max=85 --strip-all --preserve --totals "$file" >/dev/null 2>&1
    
    local optimized_size=$(get_file_size "$file")
    local saved=$((original_size - optimized_size))
    local percent=0
    
    if [ $original_size -gt 0 ]; then
        percent=$(echo "scale=1; ($saved * 100) / $original_size" | bc)
    fi
    
    echo "  Original: $(format_size $original_size) → Optimized: $(format_size $optimized_size) (Saved: $(format_size $saved) - $percent%)"
    echo "JPEG: $file - $percent% saved" >> "$LOG_FILE"
    
    # Update statistics
    TOTAL_FILES=$((TOTAL_FILES + 1))
    TOTAL_ORIGINAL_SIZE=$((TOTAL_ORIGINAL_SIZE + original_size))
    TOTAL_OPTIMIZED_SIZE=$((TOTAL_OPTIMIZED_SIZE + optimized_size))
    TOTAL_SAVED=$((TOTAL_SAVED + saved))
}

# Function to optimize PNG files
optimize_png() {
    local file="$1"
    local original_size=$(get_file_size "$file")
    
    echo -e "${YELLOW}🔄 Optimizing PNG: $(basename "$file")${NC}"
    
    # Create backup
    cp "$file" "$BACKUP_DIR/$(basename "$file")"
    
    # Optimize with optipng
    optipng -o7 -quiet -clobber "$file"
    
    # Additional optimization with ImageMagick if needed
    if command -v convert >/dev/null 2>&1; then
        convert "$file" -strip "$file"
    fi
    
    local optimized_size=$(get_file_size "$file")
    local saved=$((original_size - optimized_size))
    local percent=0
    
    if [ $original_size -gt 0 ]; then
        percent=$(echo "scale=1; ($saved * 100) / $original_size" | bc)
    fi
    
    echo "  Original: $(format_size $original_size) → Optimized: $(format_size $optimized_size) (Saved: $(format_size $saved) - $percent%)"
    echo "PNG: $file - $percent% saved" >> "$LOG_FILE"
    
    # Update statistics
    TOTAL_FILES=$((TOTAL_FILES + 1))
    TOTAL_ORIGINAL_SIZE=$((TOTAL_ORIGINAL_SIZE + original_size))
    TOTAL_OPTIMIZED_SIZE=$((TOTAL_OPTIMIZED_SIZE + optimized_size))
    TOTAL_SAVED=$((TOTAL_SAVED + saved))
}

# Function to optimize GIF files
optimize_gif() {
    local file="$1"
    local original_size=$(get_file_size "$file")
    
    echo -e "${YELLOW}🔄 Optimizing GIF: $(basename "$file")${NC}"
    
    # Create backup
    cp "$file" "$BACKUP_DIR/$(basename "$file")"
    
    # Optimize with ImageMagick
    if command -v convert >/dev/null 2>&1; then
        convert "$file" -fuzz 10% -layers Optimize "$file"
    fi
    
    local optimized_size=$(get_file_size "$file")
    local saved=$((original_size - optimized_size))
    local percent=0
    
    if [ $original_size -gt 0 ]; then
        percent=$(echo "scale=1; ($saved * 100) / $original_size" | bc)
    fi
    
    echo "  Original: $(format_size $original_size) → Optimized: $(format_size $optimized_size) (Saved: $(format_size $saved) - $percent%)"
    echo "GIF: $file - $percent% saved" >> "$LOG_FILE"
    
    # Update statistics
    TOTAL_FILES=$((TOTAL_FILES + 1))
    TOTAL_ORIGINAL_SIZE=$((TOTAL_ORIGINAL_SIZE + original_size))
    TOTAL_OPTIMIZED_SIZE=$((TOTAL_OPTIMIZED_SIZE + optimized_size))
    TOTAL_SAVED=$((TOTAL_SAVED + saved))
}

# Function to optimize WebP files
optimize_webp() {
    local file="$1"
    local original_size=$(get_file_size "$file")
    
    echo -e "${YELLOW}🔄 Optimizing WebP: $(basename "$file")${NC}"
    
    # Create backup
    cp "$file" "$BACKUP_DIR/$(basename "$file")"
    
    # Optimize with ImageMagick
    if command -v convert >/dev/null 2>&1; then
        convert "$file" -strip "$file"
    fi
    
    local optimized_size=$(get_file_size "$file")
    local saved=$((original_size - optimized_size))
    local percent=0
    
    if [ $original_size -gt 0 ]; then
        percent=$(echo "scale=1; ($saved * 100) / $original_size" | bc)
    fi
    
    echo "  Original: $(format_size $original_size) → Optimized: $(format_size $optimized_size) (Saved: $(format_size $saved) - $percent%)"
    echo "WebP: $file - $percent% saved" >> "$LOG_FILE"
    
    # Update statistics
    TOTAL_FILES=$((TOTAL_FILES + 1))
    TOTAL_ORIGINAL_SIZE=$((TOTAL_ORIGINAL_SIZE + original_size))
    TOTAL_OPTIMIZED_SIZE=$((TOTAL_OPTIMIZED_SIZE + optimized_size))
    TOTAL_SAVED=$((TOTAL_SAVED + saved))
}

# Function to optimize SVG files
optimize_svg() {
    local file="$1"
    local original_size=$(get_file_size "$file")
    
    echo -e "${YELLOW}🔄 Optimizing SVG: $(basename "$file")${NC}"
    
    # Create backup
    cp "$file" "$BACKUP_DIR/$(basename "$file")"
    
    # Basic SVG optimization (remove comments, whitespace, etc.)
    if command -v sed >/dev/null 2>&1; then
        # Remove comments and unnecessary whitespace
        sed -i '' '/<!--.*-->/d' "$file" 2>/dev/null || sed -i '/<!--.*-->/d' "$file"
        sed -i '' 's/^[ \t]*//;s/[ \t]*$//' "$file" 2>/dev/null || sed -i 's/^[ \t]*//;s/[ \t]*$//' "$file"
    fi
    
    local optimized_size=$(get_file_size "$file")
    local saved=$((original_size - optimized_size))
    local percent=0
    
    if [ $original_size -gt 0 ]; then
        percent=$(echo "scale=1; ($saved * 100) / $original_size" | bc)
    fi
    
    echo "  Original: $(format_size $original_size) → Optimized: $(format_size $optimized_size) (Saved: $(format_size $saved) - $percent%)"
    echo "SVG: $file - $percent% saved" >> "$LOG_FILE"
    
    # Update statistics
    TOTAL_FILES=$((TOTAL_FILES + 1))
    TOTAL_ORIGINAL_SIZE=$((TOTAL_ORIGINAL_SIZE + original_size))
    TOTAL_OPTIMIZED_SIZE=$((TOTAL_OPTIMIZED_SIZE + optimized_size))
    TOTAL_SAVED=$((TOTAL_SAVED + saved))
}

# Function to handle KTX2 files (texture compression)
optimize_ktx2() {
    local file="$1"
    local original_size=$(get_file_size "$file")
    
    echo -e "${YELLOW}🔄 KTX2 file detected: $(basename "$file")${NC}"
    echo "  ${YELLOW}⚠️  KTX2 files are already compressed textures. Skipping optimization.${NC}"
    echo "KTX2: $file - skipped (already compressed)" >> "$LOG_FILE"
    
    # Update statistics
    TOTAL_FILES=$((TOTAL_FILES + 1))
    TOTAL_ORIGINAL_SIZE=$((TOTAL_ORIGINAL_SIZE + original_size))
    TOTAL_OPTIMIZED_SIZE=$((TOTAL_OPTIMIZED_SIZE + original_size))
}

# Main optimization function
optimize_images() {
    echo -e "${GREEN}🚀 STARTING IMAGE OPTIMIZATION${NC}"
    echo -e "${BLUE}📁 Uploads directory: $UPLOADS_DIR${NC}"
    echo -e "${BLUE}💾 Backup directory: $BACKUP_DIR${NC}"
    echo -e "${BLUE}📋 Log file: $LOG_FILE${NC}"
    echo ""
    
    # Find and process all image files
    echo -e "${BLUE}🔍 Finding image files...${NC}"
    
    while IFS= read -r -d '' file; do
        if [ -f "$file" ]; then
            case "${file##*.}" in
                jpg|jpeg)
                    optimize_jpeg "$file"
                    ;;
                png)
                    optimize_png "$file"
                    ;;
                gif)
                    optimize_gif "$file"
                    ;;
                webp)
                    optimize_webp "$file"
                    ;;
                svg)
                    optimize_svg "$file"
                    ;;
                ktx2)
                    optimize_ktx2 "$file"
                    ;;
            esac
        fi
    done < <(find "$UPLOADS_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.gif" -o -name "*.webp" -o -name "*.svg" -o -name "*.ktx2" \) -print0)
    
    # Calculate final statistics
    local total_percent=0
    if [ $TOTAL_ORIGINAL_SIZE -gt 0 ]; then
        total_percent=$(echo "scale=1; ($TOTAL_SAVED * 100) / $TOTAL_ORIGINAL_SIZE" | bc)
    fi
    
    echo ""
    echo -e "${GREEN}📊 OPTIMIZATION COMPLETE!${NC}"
    echo -e "${GREEN}================================${NC}"
    echo -e "${BLUE}📁 Files processed: $TOTAL_FILES${NC}"
    echo -e "${BLUE}📦 Original size: $(format_size $TOTAL_ORIGINAL_SIZE)${NC}"
    echo -e "${BLUE}📦 Optimized size: $(format_size $TOTAL_OPTIMIZED_SIZE)${NC}"
    echo -e "${GREEN}✅ Total saved: $(format_size $TOTAL_SAVED) ($total_percent%)${NC}"
    echo ""
    echo -e "${BLUE}📋 Detailed log saved to: $LOG_FILE${NC}"
    echo -e "${BLUE}💾 Backup saved to: $BACKUP_DIR${NC}"
    echo ""
    
    # Save final statistics to log
    echo "" >> "$LOG_FILE"
    echo "FINAL STATISTICS:" >> "$LOG_FILE"
    echo "=================" >> "$LOG_FILE"
    echo "Files processed: $TOTAL_FILES" >> "$LOG_FILE"
    echo "Original size: $(format_size $TOTAL_ORIGINAL_SIZE)" >> "$LOG_FILE"
    echo "Optimized size: $(format_size $TOTAL_OPTIMIZED_SIZE)" >> "$LOG_FILE"
    echo "Total saved: $(format_size $TOTAL_SAVED) ($total_percent%)" >> "$LOG_FILE"
}

# Check if uploads directory exists
if [ ! -d "$UPLOADS_DIR" ]; then
    echo -e "${RED}❌ Error: Uploads directory not found: $UPLOADS_DIR${NC}"
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
optimize_images

echo -e "${GREEN}🎉 Image optimization completed successfully!${NC}"
echo -e "${YELLOW}💡 To restore original files, use: cp -r $BACKUP_DIR/* $UPLOADS_DIR/${NC}"
