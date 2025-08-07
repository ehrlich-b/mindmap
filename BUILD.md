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
Lists leaf folders (containing no subfolders) with insufficient content (< 4 articles + README). Helps identify over-granular structure that should be consolidated.

**Usage:**
```bash
make todo
```

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

# See which READMEs need completion (175 incomplete)
make outline-todo

# Find folders that may need consolidation
make todo
```

### 2. Content Creation
```bash
# Prioritize based on outline-todo output
# Focus on Science_and_Mathematics (43 incomplete READMEs)
vim Science_and_Mathematics/Physics/README.md
vim Science_and_Mathematics/Mathematics/Calculus/README.md
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

# Identify remaining work
make outline-todo
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
