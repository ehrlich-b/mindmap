# Mind Map Project Makefile
# Cross-platform makefile for formatting and building the knowledge repository

# Detect OS for cross-platform compatibility
ifeq ($(OS),Windows_NT)
	DETECTED_OS := Windows
	RM_RF := rmdir /s /q
	MKDIR_P := mkdir
	SHELL := cmd.exe
	FIND := dir /s /b
	SED := sed
	PANDOC := pandoc.exe
else
	DETECTED_OS := $(shell uname -s)
	RM_RF := rm -rf
	MKDIR_P := mkdir -p
	FIND := find
	SED := sed
	PANDOC := pandoc
endif

# Directories
SRC_DIR := .
DIST_DIR := dist
HTML_DIR := $(DIST_DIR)/html
ASSETS_DIR := $(DIST_DIR)/assets

# Find all markdown files
MD_FILES := $(shell $(FIND) $(SRC_DIR) -name "*.md" -type f 2>/dev/null | grep -v $(DIST_DIR) | grep -v .git)

# Convert source paths to HTML output paths
HTML_FILES := $(patsubst %.md,$(HTML_DIR)/%.html,$(MD_FILES))

# Tools check - pandoc only required for build
PANDOC_EXISTS := $(shell which $(PANDOC) 2>/dev/null)

# Default target
.PHONY: all
all: format build

# Format all markdown files
.PHONY: format
format:
	@echo "Formatting markdown files..."
	@$(MAKE) format-files

# Format individual markdown files
.PHONY: format-files
format-files:
ifeq ($(DETECTED_OS),Windows)
	@for /r %%f in (*.md) do ( \
		if not "%%f"=="*$(DIST_DIR)*" if not "%%f"=="*.git*" ( \
			echo Formatting %%f && \
			powershell -Command "$$content = Get-Content '%%f' -Raw; $$content = $$content -replace '\r?\n$$', ''; $$content = $$content -replace '\n{3,}', '\n\n'; $$content = $$content.TrimEnd() + '\n'; Set-Content '%%f' $$content -NoNewline" \
		) \
	)
else
	@for file in $(MD_FILES); do \
		echo "Formatting $$file"; \
		$(SED) -i -e :a -e '/^\s*$$/N' -e '/\n\s*$$/ba' -e 's/\n\s*$$//' $$file; \
		$(SED) -i -e '/^$$/N;/^\n$$/d' $$file; \
		echo >> $$file; \
	done
endif

# Build HTML from markdown
.PHONY: build
build: check-pandoc clean-dist setup-dist $(HTML_FILES) copy-assets
	@echo "Build complete! Open $(HTML_DIR)/README.html to start exploring."

# Check for pandoc before building
.PHONY: check-pandoc
check-pandoc:
ifndef PANDOC_EXISTS
	$(error pandoc is required for building HTML but not installed. Please install pandoc first or use 'make format' only)
endif

# Clean distribution directory
.PHONY: clean-dist
clean-dist:
	@echo "Cleaning distribution directory..."
ifeq ($(DETECTED_OS),Windows)
	@if exist $(DIST_DIR) $(RM_RF) $(DIST_DIR)
else
	@$(RM_RF) $(DIST_DIR)
endif

# Setup distribution directory structure
.PHONY: setup-dist
setup-dist:
	@echo "Setting up distribution directory..."
	@$(MKDIR_P) $(HTML_DIR)
	@$(MKDIR_P) $(ASSETS_DIR)

# Convert individual markdown files to HTML
$(HTML_DIR)/%.html: %.md | setup-dist
	@echo "Converting $< to $@"
	@$(MKDIR_P) $(dir $@)
	@$(PANDOC) $< \
		-f markdown \
		-t html5 \
		--standalone \
		--css="/assets/style.css" \
		--template=html-template.html \
		--metadata title="$(shell basename $< .md | sed 's/_/ /g')" \
		--metadata pagetitle="Mind Map: $(shell basename $< .md | sed 's/_/ /g')" \
		-o $@

# Copy static assets
.PHONY: copy-assets
copy-assets: setup-dist create-css create-template

# Create CSS file
.PHONY: create-css
create-css:
	@echo "Creating CSS stylesheet..."
	@echo "/* Mind Map Project Styles */" > $(ASSETS_DIR)/style.css
	@echo "body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif; line-height: 1.6; max-width: 800px; margin: 0 auto; padding: 20px; }" >> $(ASSETS_DIR)/style.css
	@echo "h1, h2, h3 { color: #333; margin-top: 2em; }" >> $(ASSETS_DIR)/style.css
	@echo "h1 { border-bottom: 2px solid #eee; padding-bottom: 0.3em; }" >> $(ASSETS_DIR)/style.css
	@echo "h2 { border-bottom: 1px solid #eee; padding-bottom: 0.2em; }" >> $(ASSETS_DIR)/style.css
	@echo "a { color: #0366d6; text-decoration: none; }" >> $(ASSETS_DIR)/style.css
	@echo "a:hover { text-decoration: underline; }" >> $(ASSETS_DIR)/style.css
	@echo "code { background: #f6f8fa; padding: 2px 4px; border-radius: 3px; font-size: 0.9em; }" >> $(ASSETS_DIR)/style.css
	@echo "pre { background: #f6f8fa; padding: 16px; border-radius: 6px; overflow-x: auto; }" >> $(ASSETS_DIR)/style.css
	@echo "blockquote { margin: 0; padding-left: 1em; border-left: 4px solid #dfe2e5; color: #586069; }" >> $(ASSETS_DIR)/style.css
	@echo ".navigation { background: #f8f9fa; padding: 15px; border-radius: 6px; margin: 20px 0; }" >> $(ASSETS_DIR)/style.css
	@echo ".domain-links { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 15px; margin: 20px 0; }" >> $(ASSETS_DIR)/style.css
	@echo ".domain-link { background: #fff; border: 1px solid #e1e4e8; border-radius: 6px; padding: 15px; transition: border-color 0.15s ease-in-out; }" >> $(ASSETS_DIR)/style.css
	@echo ".domain-link:hover { border-color: #0366d6; }" >> $(ASSETS_DIR)/style.css
	@echo "@media (max-width: 768px) { body { padding: 10px; } .domain-links { grid-template-columns: 1fr; } }" >> $(ASSETS_DIR)/style.css

# Create HTML template
.PHONY: create-template
create-template:
	@echo "Creating HTML template..."
	@echo '<!DOCTYPE html>' > html-template.html
	@echo '<html lang="en">' >> html-template.html
	@echo '<head>' >> html-template.html
	@echo '    <meta charset="utf-8">' >> html-template.html
	@echo '    <meta name="viewport" content="width=device-width, initial-scale=1">' >> html-template.html
	@echo '    <title>$$pagetitle$$</title>' >> html-template.html
	@echo '    <link rel="stylesheet" href="/assets/style.css">' >> html-template.html
	@echo '</head>' >> html-template.html
	@echo '<body>' >> html-template.html
	@echo '    <nav class="navigation">' >> html-template.html
	@echo '        <a href="/README.html">🏠 Home</a> |' >> html-template.html
	@echo '        <a href="/NAVIGATION.html">📖 Navigation Guide</a> |' >> html-template.html
	@echo '        <a href="/TODO.html">📋 Roadmap</a>' >> html-template.html
	@echo '    </nav>' >> html-template.html
	@echo '    $$body$$' >> html-template.html
	@echo '    <footer style="margin-top: 3em; padding-top: 1em; border-top: 1px solid #eee; color: #666; font-size: 0.9em;">' >> html-template.html
	@echo '        <p>Generated from AI-organized knowledge repository | <a href="https://github.com/user/mindmap">Source</a></p>' >> html-template.html
	@echo '    </footer>' >> html-template.html
	@echo '</body>' >> html-template.html
	@echo '</html>' >> html-template.html

# Development server (requires Python)
.PHONY: serve
serve: build
	@echo "Starting development server at http://localhost:8000"
	@echo "Press Ctrl+C to stop"
ifeq ($(DETECTED_OS),Windows)
	@cd $(HTML_DIR) && python -m http.server 8000 2>nul || python3 -m http.server 8000
else
	@cd $(HTML_DIR) && python3 -m http.server 8000 2>/dev/null || python -m http.server 8000
endif

# Clean everything
.PHONY: clean
clean: clean-dist
	@echo "Cleaning build artifacts..."
	@$(RM_RF) html-template.html

# Watch mode (requires inotify-tools on Linux/macOS or similar on Windows)
.PHONY: watch
watch:
	@echo "Watch mode not implemented. Use 'make build' to rebuild manually."

# Development and maintenance commands

# Find folders with blank/placeholder READMEs (less than 5 lines)
.PHONY: outline-todo
outline-todo:
	@echo "=== FOLDERS WITH BLANK/PLACEHOLDER READMEs ==="
	@echo "(READMEs with less than 5 lines)"
	@echo ""
	@total=0; \
	for domain in Science_and_Mathematics Technology_and_Computing Human_Society_and_Culture Arts_and_Expression Philosophy_and_Cognition Natural_World Health_and_Medicine Language_and_Communication History_and_Time Daily_Life_and_Skills Systems_and_Structures Future_and_Speculation; do \
		echo "📁 $$domain:"; \
		count=0; \
		if [ -f "$$domain/README.md" ] && [ $$(wc -l < "$$domain/README.md" | tr -d ' ') -lt 5 ]; then \
			echo "  - $$domain/README.md"; \
			count=$$((count + 1)); \
		fi; \
		$(FIND) "$$domain" -name "README.md" -type f | while read -r readme; do \
			if [ $$(wc -l < "$$readme" | tr -d ' ') -lt 5 ]; then \
				echo "  - $$readme"; \
			fi; \
		done | head -20; \
		domain_total=$$($(FIND) "$$domain" -name "README.md" -type f -exec sh -c 'if [ $$(wc -l < "$$1" | tr -d " ") -lt 5 ]; then echo "$$1"; fi' _ {} \; | wc -l | tr -d ' '); \
		if [ $$domain_total -gt 0 ]; then \
			echo "  Total: $$domain_total incomplete READMEs"; \
		else \
			echo "  ✅ All READMEs complete"; \
		fi; \
		echo ""; \
		total=$$((total + domain_total)); \
	done; \
	echo "🎯 Total incomplete READMEs across all domains: $$total"

# Find leaf folders (containing no subfolders) with insufficient content
# Leaf folders should have at least 4 articles + README to justify existence
.PHONY: todo
todo:
	@echo "=== LEAF FOLDERS WITH INSUFFICIENT ARTICLES ==="
	@echo "(Folders with no subfolders that have < 4 articles + README)"
	@echo ""
	@total=0; \
	for domain in Science_and_Mathematics Technology_and_Computing Human_Society_and_Culture Arts_and_Expression Philosophy_and_Cognition Natural_World Health_and_Medicine Language_and_Communication History_and_Time Daily_Life_and_Skills Systems_and_Structures Future_and_Speculation; do \
		echo "📁 $$domain:"; \
		domain_count=0; \
		$(FIND) "$$domain" -type d | while read -r dir; do \
			if [ "$$dir" != "$$domain" ]; then \
				subdir_count=$$($(FIND) "$$dir" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' '); \
				if [ $$subdir_count -eq 0 ]; then \
					md_count=$$($(FIND) "$$dir" -maxdepth 1 -name "*.md" -type f | wc -l | tr -d ' '); \
					if [ $$md_count -lt 5 ]; then \
						echo "  - $$dir ($$md_count files)"; \
					fi; \
				fi; \
			fi; \
		done; \
		domain_total=$$($(FIND) "$$domain" -type d -exec sh -c 'subdir_count=$$(find "$$1" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d " "); if [ $$subdir_count -eq 0 ] && [ "$$1" != "'$$domain'" ]; then md_count=$$(find "$$1" -maxdepth 1 -name "*.md" -type f | wc -l | tr -d " "); if [ $$md_count -lt 5 ]; then echo "$$1"; fi; fi' _ {} \; | wc -l | tr -d ' '); \
		if [ $$domain_total -gt 0 ]; then \
			echo "  Total: $$domain_total underpopulated folders"; \
		else \
			echo "  ✅ All leaf folders have sufficient content"; \
		fi; \
		echo ""; \
		total=$$((total + domain_total)); \
	done; \
	echo "📝 Total underpopulated leaf folders: $$total"

# Show overall project status
.PHONY: status
status:
	@echo "=== MIND MAP PROJECT STATUS ==="
	@echo ""
	@total_folders=$$($(FIND) . -type d | grep -v "^\.$$" | grep -v "./\.git" | grep -v "./dist" | wc -l | tr -d ' '); \
	total_readmes=$$($(FIND) . -name "README.md" -type f | wc -l | tr -d ' '); \
	complete_readmes=$$($(FIND) . -name "README.md" -type f -exec sh -c 'if [ $$(wc -l < "$$1" | tr -d " ") -ge 5 ]; then echo "$$1"; fi' _ {} \; | wc -l | tr -d ' '); \
	incomplete_readmes=$$((total_readmes - complete_readmes)); \
	total_articles=$$($(FIND) . -name "*.md" -type f ! -name "README.md" ! -name "TODO.md" ! -name "CLAUDE.md" ! -name "NAVIGATION.md" ! -name "BUILD.md" | wc -l | tr -d ' '); \
	echo "📊 Structure:"; \
	echo "  - Total folders: $$total_folders"; \
	echo "  - Total README files: $$total_readmes"; \
	echo "  - Complete READMEs (≥5 lines): $$complete_readmes"; \
	echo "  - Incomplete READMEs (<5 lines): $$incomplete_readmes"; \
	if command -v bc >/dev/null 2>&1; then \
		completion_rate=$$(echo "scale=1; $$complete_readmes * 100 / $$total_readmes" | bc -l); \
		echo "  - README completion: $${completion_rate}%"; \
	else \
		echo "  - README completion: $$((complete_readmes * 100 / total_readmes))%"; \
	fi; \
	echo ""; \
	echo "📝 Content & Articles:"; \
	echo "  - Current articles: $$total_articles"; \
	total_high=0; total_medium=0; total_low=0; \
	for domain in Science_and_Mathematics Technology_and_Computing Human_Society_and_Culture Arts_and_Expression Philosophy_and_Cognition Natural_World Health_and_Medicine Language_and_Communication History_and_Time Daily_Life_and_Skills Systems_and_Structures Future_and_Speculation; do \
		if [ -f "$$domain/TODO.md" ]; then \
			high_count=$$(sed -n '/^## PRIORITY_HIGH/,/^## PRIORITY_MEDIUM/p' "$$domain/TODO.md" | grep "^- \[ \]" | wc -l | tr -d ' '); \
			medium_count=$$(sed -n '/^## PRIORITY_MEDIUM/,/^## PRIORITY_LOW/p' "$$domain/TODO.md" | grep "^- \[ \]" | wc -l | tr -d ' '); \
			low_count=$$(sed -n '/^## PRIORITY_LOW/,/^## /p' "$$domain/TODO.md" | grep "^- \[ \]" | wc -l | tr -d ' '); \
			total_high=$$((total_high + high_count)); \
			total_medium=$$((total_medium + medium_count)); \
			total_low=$$((total_low + low_count)); \
		fi; \
	done; \
	total_planned=$$((total_high + total_medium + total_low)); \
	echo "  - HIGH priority articles: $$total_high planned"; \
	echo "  - MEDIUM priority articles: $$total_medium planned"; \
	echo "  - LOW priority articles: $$total_low planned"; \
	echo "  - Total articles planned: $$total_planned"; \
	if command -v bc >/dev/null 2>&1 && [ $$total_planned -gt 0 ]; then \
		article_completion=$$(echo "scale=1; $$total_articles * 100 / $$total_planned" | bc -l); \
		echo "  - Article completion: $${article_completion}%"; \
	elif [ $$total_planned -gt 0 ]; then \
		article_completion=$$((total_articles * 100 / total_planned)); \
		echo "  - Article completion: $${article_completion}%"; \
	else \
		echo "  - Article completion: 0%"; \
	fi
	@echo ""
	@echo "🎯 Current Phase: Article Creation (Phase 4) - Ready to Begin"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Run 'make priority-high' to see 782 foundational articles"
	@echo "  2. Run 'make next-articles' for balanced selection across domains"
	@echo "  3. Start with HIGH priority articles using domain TODO.md specifications"

# Reconcile TODO checkboxes with actual article files
.PHONY: reconcile-todos
reconcile-todos:
	@echo "=== TODO CHECKBOX RECONCILIATION ==="
	@echo "Syncing TODO.md checkboxes with existing article files..."
	@echo ""
	@total_updated=0; \
	total_checked=0; \
	total_unchecked=0; \
	for domain in Science_and_Mathematics Technology_and_Computing Human_Society_and_Culture Arts_and_Expression Philosophy_and_Cognition Natural_World Health_and_Medicine Language_and_Communication History_and_Time Daily_Life_and_Skills Systems_and_Structures Future_and_Speculation; do \
		if [ -f "$$domain/TODO.md" ]; then \
			echo "📁 $$domain:"; \
			domain_updated=0; \
			temp_file="$$domain/TODO.md.tmp"; \
			cp "$$domain/TODO.md" "$$temp_file"; \
			while IFS= read -r line; do \
				if echo "$$line" | grep -q "^- \[[x ]\] \*\*.*\.md\*\*"; then \
					filename=$$(echo "$$line" | sed 's/.*\*\*\(.*\)\.md\*\*.*/\1/'); \
					current_status=$$(echo "$$line" | sed 's/^- \[\([x ]\)\].*/\1/'); \
					if $(FIND) "$$domain" -name "$$filename.md" -type f | grep -q "$$filename.md"; then \
						if [ "$$current_status" = " " ]; then \
							echo "$$line" | sed 's/^- \[ \]/- [x]/' >> "$$temp_file.new"; \
							echo "  ✓ CHECK: $$filename.md"; \
							domain_updated=$$((domain_updated + 1)); \
							total_checked=$$((total_checked + 1)); \
						else \
							echo "$$line" >> "$$temp_file.new"; \
						fi; \
					else \
						if [ "$$current_status" = "x" ]; then \
							echo "$$line" | sed 's/^- \[x\]/- [ ]/' >> "$$temp_file.new"; \
							echo "  ☐ UNCHECK: $$filename.md (file not found)"; \
							domain_updated=$$((domain_updated + 1)); \
							total_unchecked=$$((total_unchecked + 1)); \
						else \
							echo "$$line" >> "$$temp_file.new"; \
						fi; \
					fi; \
				else \
					echo "$$line" >> "$$temp_file.new"; \
				fi; \
			done < "$$temp_file"; \
			if [ $$domain_updated -gt 0 ]; then \
				mv "$$temp_file.new" "$$domain/TODO.md"; \
				echo "  📊 Updated $$domain_updated checkboxes"; \
				total_updated=$$((total_updated + domain_updated)); \
			else \
				rm -f "$$temp_file.new"; \
				echo "  ✅ No updates needed"; \
			fi; \
			rm -f "$$temp_file"; \
			echo ""; \
		fi; \
	done; \
	echo "📊 RECONCILIATION COMPLETE:"; \
	echo "  - Total checkboxes updated: $$total_updated"; \
	echo "  - Articles found and checked: $$total_checked"; \
	echo "  - Missing articles unchecked: $$total_unchecked"

# Dry run of TODO reconciliation (show what would be changed)
.PHONY: reconcile-todos-dry
reconcile-todos-dry:
	@echo "=== TODO CHECKBOX RECONCILIATION (DRY RUN) ==="
	@echo "Showing what would be changed without modifying files..."
	@echo ""
	@total_changes=0; \
	total_checks=0; \
	total_unchecks=0; \
	for domain in Science_and_Mathematics Technology_and_Computing Human_Society_and_Culture Arts_and_Expression Philosophy_and_Cognition Natural_World Health_and_Medicine Language_and_Communication History_and_Time Daily_Life_and_Skills Systems_and_Structures Future_and_Speculation; do \
		if [ -f "$$domain/TODO.md" ]; then \
			echo "📁 $$domain:"; \
			domain_changes=0; \
			while IFS= read -r line; do \
				if echo "$$line" | grep -q "^- \[[x ]\] \*\*.*\.md\*\*"; then \
					filename=$$(echo "$$line" | sed 's/.*\*\*\(.*\)\.md\*\*.*/\1/'); \
					current_status=$$(echo "$$line" | sed 's/^- \[\([x ]\)\].*/\1/'); \
					if $(FIND) "$$domain" -name "$$filename.md" -type f | grep -q "$$filename.md"; then \
						if [ "$$current_status" = " " ]; then \
							echo "  ✓ WOULD CHECK: $$filename.md"; \
							domain_changes=$$((domain_changes + 1)); \
							total_checks=$$((total_checks + 1)); \
						fi; \
					else \
						if [ "$$current_status" = "x" ]; then \
							echo "  ☐ WOULD UNCHECK: $$filename.md (file not found)"; \
							domain_changes=$$((domain_changes + 1)); \
							total_unchecks=$$((total_unchecks + 1)); \
						fi; \
					fi; \
				fi; \
			done < "$$domain/TODO.md"; \
			if [ $$domain_changes -eq 0 ]; then \
				echo "  ✅ No changes needed"; \
			fi; \
			total_changes=$$((total_changes + domain_changes)); \
			echo ""; \
		fi; \
	done; \
	echo "📊 SUMMARY (DRY RUN):"; \
	echo "  - Total changes needed: $$total_changes"; \
	echo "  - Would check: $$total_checks"; \
	echo "  - Would uncheck: $$total_unchecks"; \
	if [ $$total_changes -gt 0 ]; then \
		echo ""; \
		echo "Run 'make reconcile-todos' to apply these changes."; \
	fi

# Help target
.PHONY: help
help:
	@echo "Mind Map Project Makefile"
	@echo ""
	@echo "🏗️  Build targets:"
	@echo "  all           - Format files and build HTML (default)"
	@echo "  format        - Format markdown files (add newlines, remove excess blank lines)"
	@echo "  build         - Convert markdown to HTML in dist/ folder"
	@echo "  serve         - Start development server (requires Python)"
	@echo "  clean         - Remove all build artifacts"
	@echo "  clean-dist    - Remove only the dist/ directory"
	@echo ""
	@echo "📋 Development targets:"
	@echo "  outline-todo       - List folders with blank/placeholder READMEs (< 5 lines)"
	@echo "  todo               - List leaf folders with insufficient articles (< 4 + README)"
	@echo "  article-todo       - List articles by priority (see usage below)"
	@echo "  priority-high      - Alias for 'make article-todo priority=high' (legacy)"
	@echo "  next-articles      - Suggest next 24 articles balanced across domains"
	@echo "  todo-refactor      - Identify TODO.md files needing format refactoring"
	@echo "  reconcile-todos    - Sync TODO checkboxes with existing article files"
	@echo "  reconcile-todos-dry- Show what checkbox changes would be made (dry run)"
	@echo "  status             - Show overall project completion status"
	@echo "  help               - Show this help message"
	@echo ""
	@echo "📝 Article Todo Usage:"
	@echo "  make article-todo                   - Show ALL HIGH priority articles (default)"
	@echo "  make article-todo priority=medium   - Show ALL MEDIUM priority articles"
	@echo "  make article-todo priority=low      - Show ALL LOW priority articles"
	@echo "  make article-todo priority=all      - Show all priorities with completion breakdown"
	@echo "  make article-todo limit=10          - Show first 10 articles per domain"
	@echo "  make article-todo show_completed=false - Hide completed articles, show only remaining"
	@echo ""
	@echo "Requirements:"
	@echo "  - pandoc (for markdown to HTML conversion)"
	@echo "  - Python (optional, for development server)"
	@echo ""
	@echo "The dist/ folder is automatically gitignored."

# Unified article listing with priority filtering
# Usage: make article-todo [priority=high|medium|low|all] [limit=N] [full=true]
.PHONY: article-todo
article-todo:
	@priority="$(if $(priority),$(priority),high)"; \
	limit="$(if $(limit),$(limit),999999)"; \
	show_completed="$(if $(show_completed),$(show_completed),true)"; \
	case "$$priority" in \
		high) \
			echo "=== HIGH PRIORITY ARTICLES ==="; \
			section_start="## PRIORITY_HIGH"; \
			section_end="## PRIORITY_MEDIUM"; \
			;; \
		medium) \
			echo "=== MEDIUM PRIORITY ARTICLES ==="; \
			section_start="## PRIORITY_MEDIUM"; \
			section_end="## PRIORITY_LOW"; \
			;; \
		low) \
			echo "=== LOW PRIORITY ARTICLES ==="; \
			section_start="## PRIORITY_LOW"; \
			section_end="## REFACTOR_STATUS"; \
			;; \
		all) \
			echo "=== ALL PRIORITY ARTICLES ==="; \
			;; \
		*) \
			echo "Error: Invalid priority '$$priority'. Use: high, medium, low, or all"; \
			exit 1; \
			;; \
	esac; \
	echo ""; \
	total=0; \
	for domain in Science_and_Mathematics Technology_and_Computing Human_Society_and_Culture Arts_and_Expression Philosophy_and_Cognition Natural_World Health_and_Medicine Language_and_Communication History_and_Time Daily_Life_and_Skills Systems_and_Structures Future_and_Speculation; do \
		if [ -f "$$domain/TODO.md" ]; then \
			if [ "$$priority" = "all" ]; then \
				high_incomplete=$$(sed -n '/^## PRIORITY_HIGH/,/^## PRIORITY_MEDIUM/p' "$$domain/TODO.md" | grep "^- \[ \]" | wc -l | tr -d ' '); \
				high_complete=$$(sed -n '/^## PRIORITY_HIGH/,/^## PRIORITY_MEDIUM/p' "$$domain/TODO.md" | grep "^- \[x\]" | wc -l | tr -d ' '); \
				medium_incomplete=$$(sed -n '/^## PRIORITY_MEDIUM/,/^## PRIORITY_LOW/p' "$$domain/TODO.md" | grep "^- \[ \]" | wc -l | tr -d ' '); \
				medium_complete=$$(sed -n '/^## PRIORITY_MEDIUM/,/^## PRIORITY_LOW/p' "$$domain/TODO.md" | grep "^- \[x\]" | wc -l | tr -d ' '); \
				low_incomplete=$$(sed -n '/^## PRIORITY_LOW/,/^## REFACTOR_STATUS/p' "$$domain/TODO.md" | grep "^- \[ \]" | wc -l | tr -d ' '); \
				low_complete=$$(sed -n '/^## PRIORITY_LOW/,/^## REFACTOR_STATUS/p' "$$domain/TODO.md" | grep "^- \[x\]" | wc -l | tr -d ' '); \
				high_total=$$((high_incomplete + high_complete)); \
				medium_total=$$((medium_incomplete + medium_complete)); \
				low_total=$$((low_incomplete + low_complete)); \
				domain_total=$$((high_total + medium_total + low_total)); \
				if [ $$domain_total -gt 0 ]; then \
					echo "📁 $$domain (H:$$high_complete/$$high_total M:$$medium_complete/$$medium_total L:$$low_complete/$$low_total = $$domain_total total):"; \
					echo "  HIGH PRIORITY:"; \
					if [ "$$show_completed" = "true" ]; then \
						sed -n '/^## PRIORITY_HIGH/,/^## PRIORITY_MEDIUM/p' "$$domain/TODO.md" | grep "^- \[.\]" | head -$$limit | sed 's/^- \[ \] /    ⏳ /' | sed 's/^- \[x\] /    ✅ /' | sed 's/ | [^|]* | / - /' | sed 's/\*\*\([^*]*\)\.md\*\*/\1.md/'; \
					else \
						sed -n '/^## PRIORITY_HIGH/,/^## PRIORITY_MEDIUM/p' "$$domain/TODO.md" | grep "^- \[ \]" | head -$$limit | sed 's/^- \[ \] /    ⏳ /' | sed 's/ | [^|]* | / - /' | sed 's/\*\*\([^*]*\)\.md\*\*/\1.md/'; \
					fi; \
					echo "  MEDIUM PRIORITY:"; \
					if [ "$$show_completed" = "true" ]; then \
						sed -n '/^## PRIORITY_MEDIUM/,/^## PRIORITY_LOW/p' "$$domain/TODO.md" | grep "^- \[.\]" | head -$$limit | sed 's/^- \[ \] /    ⏳ /' | sed 's/^- \[x\] /    ✅ /' | sed 's/ | [^|]* | / - /' | sed 's/\*\*\([^*]*\)\.md\*\*/\1.md/'; \
					else \
						sed -n '/^## PRIORITY_MEDIUM/,/^## PRIORITY_LOW/p' "$$domain/TODO.md" | grep "^- \[ \]" | head -$$limit | sed 's/^- \[ \] /    ⏳ /' | sed 's/ | [^|]* | / - /' | sed 's/\*\*\([^*]*\)\.md\*\*/\1.md/'; \
					fi; \
					echo "  LOW PRIORITY:"; \
					if [ "$$show_completed" = "true" ]; then \
						sed -n '/^## PRIORITY_LOW/,/^## REFACTOR_STATUS/p' "$$domain/TODO.md" | grep "^- \[.\]" | head -$$limit | sed 's/^- \[ \] /    ⏳ /' | sed 's/^- \[x\] /    ✅ /' | sed 's/ | [^|]* | / - /' | sed 's/\*\*\([^*]*\)\.md\*\*/\1.md/'; \
					else \
						sed -n '/^## PRIORITY_LOW/,/^## REFACTOR_STATUS/p' "$$domain/TODO.md" | grep "^- \[ \]" | head -$$limit | sed 's/^- \[ \] /    ⏳ /' | sed 's/ | [^|]* | / - /' | sed 's/\*\*\([^*]*\)\.md\*\*/\1.md/'; \
					fi; \
					echo ""; \
					total=$$((total + domain_total)); \
				fi; \
			else \
				if grep -q "$$section_start" "$$domain/TODO.md" 2>/dev/null; then \
					incomplete_articles=$$(sed -n "/$$section_start/,/$$section_end/p" "$$domain/TODO.md" | grep "^- \[ \]" | wc -l | tr -d ' '); \
					completed_articles=$$(sed -n "/$$section_start/,/$$section_end/p" "$$domain/TODO.md" | grep "^- \[x\]" | wc -l | tr -d ' '); \
					total_articles=$$((incomplete_articles + completed_articles)); \
					if [ $$total_articles -gt 0 ]; then \
						echo "📁 $$domain ($$total_articles $$priority priority: $$completed_articles done, $$incomplete_articles remaining):"; \
						if [ "$$show_completed" = "true" ]; then \
							sed -n "/$$section_start/,/$$section_end/p" "$$domain/TODO.md" | grep "^- \[.\]" | head -$$limit | sed 's/^- \[ \] /  ⏳ /' | sed 's/^- \[x\] /  ✅ /' | sed 's/ | [^|]* | / - /' | sed 's/\*\*\([^*]*\)\.md\*\*/\1.md/'; \
						else \
							sed -n "/$$section_start/,/$$section_end/p" "$$domain/TODO.md" | grep "^- \[ \]" | head -$$limit | sed 's/^- \[ \] /  ⏳ /' | sed 's/ | [^|]* | / - /' | sed 's/\*\*\([^*]*\)\.md\*\*/\1.md/'; \
						fi; \
						echo ""; \
						total=$$((total + total_articles)); \
					fi; \
				fi; \
			fi; \
		fi; \
	done; \
	echo "🎯 Total $$priority priority articles: $$total"; \
	if [ "$$limit" != "999999" ]; then \
		echo "💡 Showing first $$limit articles per domain. Use 'make article-todo priority=$$priority' to see all."; \
	fi; \
	if [ "$$show_completed" != "true" ]; then \
		echo "💡 Showing incomplete articles only. Use 'show_completed=true' to see completed articles."; \
	fi

# Legacy aliases for backward compatibility  
.PHONY: priority-high
priority-high:
	@$(MAKE) article-todo priority=high

# Suggest next 24 articles to write (2 from each domain's high priority)
.PHONY: next-articles
next-articles:
	@echo "=== NEXT 24 ARTICLES TO WRITE ==="
	@echo "(2 high-priority articles from each domain for balanced coverage)"
	@echo ""
	@$(MAKE) article-todo priority=high limit=2

# Identify TODO.md files needing format refactoring for makefile compatibility
.PHONY: todo-refactor
todo-refactor:
	@echo "=== TODO.md FILES NEEDING REFACTORING ==="
	@echo "(Files missing standardized PRIORITY_HIGH/MEDIUM/LOW sections or REFACTOR_STATUS)"
	@echo ""
	@total=0; \
	for domain in Science_and_Mathematics Technology_and_Computing Human_Society_and_Culture Arts_and_Expression Philosophy_and_Cognition Natural_World Health_and_Medicine Language_and_Communication History_and_Time Daily_Life_and_Skills Systems_and_Structures Future_and_Speculation; do \
		if [ -f "$$domain/TODO.md" ]; then \
			needs_refactor=0; \
			if ! grep -q "^## PRIORITY_HIGH" "$$domain/TODO.md" 2>/dev/null; then \
				needs_refactor=1; \
			fi; \
			if ! grep -q "^## PRIORITY_MEDIUM" "$$domain/TODO.md" 2>/dev/null; then \
				needs_refactor=1; \
			fi; \
			if ! grep -q "^## PRIORITY_LOW" "$$domain/TODO.md" 2>/dev/null; then \
				needs_refactor=1; \
			fi; \
			if ! grep -q "^## REFACTOR_STATUS" "$$domain/TODO.md" 2>/dev/null; then \
				needs_refactor=1; \
			fi; \
			if ! grep -q "TODO_REFACTOR_NEEDED" "$$domain/TODO.md" 2>/dev/null; then \
				needs_refactor=1; \
			fi; \
			if [ $$needs_refactor -eq 1 ]; then \
				echo "📁 $$domain/TODO.md"; \
				echo "  Missing: "; \
				if ! grep -q "^## PRIORITY_HIGH" "$$domain/TODO.md" 2>/dev/null; then \
					echo "    - PRIORITY_HIGH section"; \
				fi; \
				if ! grep -q "^## PRIORITY_MEDIUM" "$$domain/TODO.md" 2>/dev/null; then \
					echo "    - PRIORITY_MEDIUM section"; \
				fi; \
				if ! grep -q "^## PRIORITY_LOW" "$$domain/TODO.md" 2>/dev/null; then \
					echo "    - PRIORITY_LOW section"; \
				fi; \
				if ! grep -q "^## REFACTOR_STATUS" "$$domain/TODO.md" 2>/dev/null; then \
					echo "    - REFACTOR_STATUS section"; \
				fi; \
				echo ""; \
				total=$$((total + 1)); \
			fi; \
		fi; \
	done; \
	echo "🎯 Total TODO.md files needing refactoring: $$total"; \
	if [ $$total -eq 0 ]; then \
		echo "✅ All TODO.md files follow standardized format!"; \
	else \
		echo ""; \
		echo "Required format:"; \
		echo "## PRIORITY_HIGH"; \
		echo "### Section_Name"; \
		echo "- [ ] **Article.md** | folder/path | Description"; \
		echo ""; \
		echo "## PRIORITY_MEDIUM"; \
		echo "## PRIORITY_LOW"; \
		echo "## REFACTOR_STATUS"; \
		echo "- [ ] TODO_REFACTOR_NEEDED"; \
	fi

# Declare phony targets
.PHONY: all format build serve clean help watch format-files clean-dist setup-dist copy-assets create-css create-template outline-todo todo status article-todo priority-high next-articles todo-refactor