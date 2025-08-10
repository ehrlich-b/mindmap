# Build System Documentation

## Overview
This project includes a cross-platform Makefile for formatting markdown files and building them into a static HTML website.

## Requirements
- **make** (cross-platform GNU Make)
- **pandoc** (for HTML conversion - required only for building)
- **Python** (optional - for development server)

### Installing Dependencies

**macOS (with Homebrew):**
```bash
brew install pandoc make
```

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install pandoc make
```

**Windows:**
- Install [pandoc](https://pandoc.org/installing.html)
- Use Git Bash, WSL, or install GNU Make for Windows

## Available Commands

### Development Commands

#### `make status`
Shows overall project completion statistics including:
- Total folders, READMEs, and articles
- Completion percentages
- Current development phase

**Usage:**
```bash
make status
```

#### `make outline-todo`
Lists folders with blank/placeholder READMEs (less than 5 lines) organized by domain. Essential for identifying which documentation needs completion.

**Usage:**
```bash
make outline-todo
```

#### `make todo`
Lists leaf folders (containing no subfolders) with insufficient content (< 4 articles + README). Shows 207 folders needing articles for Phase 4.

**Usage:**
```bash
make todo
```

#### `make article-todo`
**Unified article listing system** with priority filtering, completion tracking, and flexible display options. Essential for Phase 4 article development.

**Basic Usage:**
```bash
# Show ALL 782 HIGH priority articles (default)
make article-todo

# Show ALL 476 MEDIUM priority articles  
make article-todo priority=medium

# Show ALL 102 LOW priority articles
make article-todo priority=low

# Show breakdown across all priorities with completion status
make article-todo priority=all
```

**Advanced Options:**
```bash
# Limit to first 10 articles per domain
make article-todo limit=10

# Hide completed articles, show only remaining work
make article-todo show_completed=false

# Combine options
make article-todo priority=medium limit=5 show_completed=false
```

**Completion Tracking:**
- ⏳ **Pending articles** - `- [ ]` in TODO.md files
- ✅ **Completed articles** - `- [x]` in TODO.md files  
- Shows **"X done, Y remaining"** for each domain

#### `make priority-high` (Legacy)
Alias for `make article-todo priority=high`. Maintained for backward compatibility.

#### `make next-articles`
Suggests next 24 articles (2 from each domain) for balanced coverage across all knowledge areas.

**Usage:**
```bash
make next-articles
```

#### `make reconcile-todos` / `make reconcile-todos-dry`
**Automatically syncs TODO.md checkboxes with existing article files**. Essential tool that eliminates manual checkbox updating and prevents synchronization errors.

**Key Features:**
- Scans all domain TODO.md files for article entries
- Checks if corresponding .md files exist in the filesystem  
- Updates checkboxes to match actual file existence
- ✅ Checks boxes for existing articles
- ☐ Unchecks boxes for missing articles
- Reports all changes made

**Usage:**
```bash
# Preview changes without modifying files
make reconcile-todos-dry

# Apply synchronization changes
make reconcile-todos
```

**Example Output:**
```
📁 Science_and_Mathematics:
  ✓ CHECK: Thermodynamics.md
  ☐ UNCHECK: Missing_Article.md (file not found)
  📊 Updated 2 checkboxes

📊 RECONCILIATION COMPLETE:
  - Total checkboxes updated: 15
  - Articles found and checked: 12  
  - Missing articles unchecked: 3
```

**⚠️ Important:** Use this instead of manually updating checkboxes in TODO.md files. Manual updates are error-prone and this tool ensures accuracy.

### Build Commands

#### `make help`
Shows all available targets with descriptions.

#### `make format`
Formats all markdown files by:
- Adding newline at end of file if missing
- Removing excessive blank lines (more than 2 consecutive)
- Preserving content structure and readability

**Usage:**
```bash
make format
```

**Safe to run repeatedly** - only affects formatting, not content.

### `make build`
Converts all markdown files to HTML with:
- Responsive CSS styling
- Navigation breadcrumbs
- Cross-linked structure
- Mobile-friendly layout

**Usage:**
```bash
make build
```

**Output:** Static HTML files in `dist/html/` directory

### `make serve`
Starts a local development server for previewing the built site.

**Usage:**
```bash
make serve
```

**Access:** Open http://localhost:8000 in your browser
**Stop:** Press Ctrl+C

### `make clean`
Removes all build artifacts including:
- `dist/` directory
- Temporary build files

**Usage:**
```bash
make clean
```

### `make all` (default)
Runs `format` then `build` - the complete build process.

**Usage:**
```bash
make        # or make all
```

## Build Output Structure
```
dist/
├── html/
│   ├── README.html                    # Main entry point
│   ├── NAVIGATION.html               # Navigation guide
│   ├── TODO.html                     # Project roadmap
│   ├── Science_and_Mathematics/
│   │   ├── README.html
│   │   ├── TODO.html
│   │   └── Physics/
│   │       └── README.html
│   └── [other domains...]
└── assets/
    └── style.css                     # Responsive stylesheet
```

## Styling Features
The generated HTML includes:
- **Responsive design** - Works on desktop and mobile
- **Clean typography** - System fonts, readable line spacing
- **Navigation aids** - Breadcrumb links between sections
- **Syntax highlighting** - Code blocks properly formatted
- **Print-friendly** - Good contrast and layout for printing

## Development Workflow

### 1. Assess Project Status
```bash
# Check overall completion statistics
make status

# Phase 4: Identify articles to write
make article-todo                    # See all 782 high-priority articles
make article-todo priority=all       # Get breakdown across all priorities  
make next-articles                   # Get next 24 balanced across domains

# Find folders that need more articles
make todo
```

### 2. Article Creation (Phase 4)
```bash
# Select articles from priority lists
make article-todo                # See all 782 high-priority articles
make next-articles              # Get balanced selection of 24 articles
make article-todo priority=all   # See completion status across all priorities

# Focus on specific priority levels
make article-todo priority=medium               # See 476 medium priority articles
make article-todo show_completed=false          # Hide completed, show remaining work

# Create articles based on specifications
vim Science_and_Mathematics/Physics/Classical_Mechanics/Newtons_Laws.md
vim Technology_and_Computing/Programming/Languages/Python.md

# ✨ AUTOMATICALLY sync TODO checkboxes with created articles
make reconcile-todos            # Updates checkboxes to match existing files
make reconcile-todos-dry        # Preview changes without modifying files

# Check domain TODO.md for detailed specifications
cat Science_and_Mathematics/TODO.md  # See article requirements and completion status
```

### 3. Format and Build
```bash
# Format all files and build HTML
make

# Or just format without building
make format
```

### 4. Preview Changes
```bash
# Start development server
make serve
# Open http://localhost:8000
```

### 5. Track Progress
```bash
# Check completion progress regularly
make status

# Identify remaining high-priority articles  
make article-todo show_completed=false

# Get next articles to write
make next-articles

# See completion progress by priority
make article-todo priority=all
```

### 6. Deploy
```bash
# Copy dist/html/ contents to web server
rsync -av dist/html/ user@server:/var/www/mindmap/
```

## Cross-Platform Compatibility
The Makefile automatically detects the operating system and uses appropriate commands:
- **Windows**: PowerShell commands for formatting, Windows paths
- **Linux/macOS**: Standard Unix commands and paths

## File Processing Details

### Formatting Process
1. **Newline Normalization**: Ensures each file ends with exactly one newline
2. **Blank Line Cleanup**: Removes sequences of 3+ blank lines, preserving intentional spacing
3. **Content Preservation**: Never modifies actual content, only whitespace

### HTML Conversion Process
1. **Markdown Parsing**: Uses pandoc's GitHub-flavored markdown
2. **Template Application**: Adds navigation, styling, and structure
3. **Link Processing**: Converts `.md` links to `.html` automatically
4. **Asset Generation**: Creates CSS and template files

## Customization

### Modifying Styles
Edit the CSS generation in the Makefile:
```bash
# Find this section in Makefile
.PHONY: create-css
create-css:
    @echo "body { ... }" >> $(ASSETS_DIR)/style.css
```

### Changing HTML Template
Edit the template generation in the Makefile:
```bash
# Find this section in Makefile
.PHONY: create-template
create-template:
    @echo '<!DOCTYPE html>' > html-template.html
```

### Adding Build Steps
Add new targets to the Makefile following the existing pattern.

## Troubleshooting

### "pandoc: command not found"
Install pandoc using your system package manager or from [pandoc.org](https://pandoc.org).

### "make: command not found" (Windows)
Install GNU Make for Windows or use Git Bash which includes make.

### Formatting Issues
The formatting is conservative and safe. If files look wrong:
1. Check original file encoding (should be UTF-8)
2. Verify no binary files are being processed
3. Run `make clean format` to reset

### Build Errors
1. Ensure all markdown files have valid syntax
2. Check that no files are locked/in use
3. Verify write permissions for `dist/` directory

## Integration with Version Control

### Recommended .gitignore
```
# Build output (already included)
/dist/

# Temporary build files
html-template.html
```

### Pre-commit Hook
Consider adding to `.git/hooks/pre-commit`:
```bash
#!/bin/bash
make format
git add *.md
```

## Performance Notes
- **Incremental builds**: Currently rebuilds everything (could be optimized)
- **File watching**: Not implemented (manual rebuild required)
- **Caching**: No caching (pandoc re-processes all files)

For large repositories, consider implementing dependency tracking and incremental builds.
