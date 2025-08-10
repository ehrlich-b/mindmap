# Mind Map Project - Knowledge Repository

## ⚠️ CRITICAL: RE-ANCHORING REQUIREMENT ⚠️
**EVERY TIME** you start a new session or after any `/compact` command, you MUST:

1. **FIRST** re-read these core files to restore project context:
   - `/Users/ehrlich/repos/mindmap/README.md` - Project overview and current status
   - `/Users/ehrlich/repos/mindmap/TODO.md` - Master roadmap and phase tracking  
   - `/Users/ehrlich/repos/mindmap/BUILD.md` - Development tools and workflow
   - `/Users/ehrlich/repos/mindmap/CLAUDE.md` - This file with project guidelines

2. **THEN** run `make status` to check current progress

3. **THEN** proceed with Phase 4 article creation using the established workflow

**RE-ANCHORING IS NOT OPTIONAL** - The project has complex state and without proper re-anchoring you will lose critical context about where we are and what needs to be done next.

## Project Overview
This repository represents a comprehensive, hierarchical map of human knowledge organized for exploration and learning. The structure mimics how knowledge domains naturally interconnect while maintaining clear categorical boundaries.

## Current Development Strategy
**BREADTH-FIRST APPROACH**: Creating comprehensive structure and roadmaps first, with leaf articles to be filled in later by efficient processes.

### What I (Claude Opus) Am Building
1. **Complete folder hierarchy** - All domains, subdomains, and topic folders
2. **Comprehensive README.md files** - Rich guides for every folder explaining structure and connections
3. **Detailed TODO.md roadmaps** - Distributed throughout the tree, mapping out exactly what articles should exist
4. **Article specifications** - Brief descriptions of what each leaf article should contain (in TODOs)

### What Will Be Built Later
- Actual leaf articles (500-1500 word explanations of specific topics)
- These will be created by more efficient processes based on the roadmap

## Structure Guidelines

### Folder Hierarchy
- **Top-Level Folders**: Major knowledge domains (e.g., Science_and_Mathematics, Human_Society_and_Culture)
- **Intermediate Folders**: Subdomains within each major area (e.g., Physics, Chemistry under Science)
- **Leaf Documents**: Specific topics as markdown files (e.g., `Quantum_Mechanics.md`, `Democracy.md`)

### Documentation Standards
1. **README.md Files**: Every folder must contain a README.md explaining:
   - Why this categorization exists
   - What topics it encompasses
   - How it relates to parent and sibling categories
   - Key concepts and themes
   - What articles should exist here (overview)

2. **TODO.md Files**: Distributed throughout subdirectories containing:
   - List of planned articles for that section
   - Brief description (1-2 sentences) of what each article should cover
   - Priority levels for article creation
   - Cross-references to related articles in other sections

3. **Future Leaf Documents**: Topic-specific markdown files will:
   - Be 500-1500 words typically
   - Focus on human-centric explanations
   - Include practical applications and examples
   - Reference related topics via links
   - Follow consistent formatting

### Content Philosophy
- **Human-Focused**: All content written from a human perspective, emphasizing relevance to daily life
- **Comprehensive**: Covering the breadth of human knowledge while maintaining appropriate depth
- **Interconnected**: Heavy use of cross-references to show relationships between topics
- **Accessible**: Clear explanations suitable for curious exploration
- **Evolving**: Regular updates as knowledge advances

## Navigation
- Start with [TODO.md](TODO.md) for the master development roadmap
- Browse top-level folders to explore major domains
- Use README files as guides through each knowledge area
- Check local TODO.md files for planned articles in each section
- Follow cross-references to discover connections

## Current Status
- Phase 1: Foundation structure planning ✅ COMPLETE
- Phase 2: Complete folder hierarchy (214 folders) ✅ COMPLETE
- Phase 3: Intermediate README completion ✅ COMPLETE
  - Top-level READMEs: 12/12 ✅
  - Comprehensive intermediate READMEs: 214/214 ✅ **100.0% COMPLETE**
  - All structural documentation finished
- Phase 3.5: TODO.md format refactoring ✅ COMPLETE  
- Phase 4: Article Creation 🚀 **READY TO BEGIN**
  - **1,360 articles planned** with detailed specifications
  - **782 HIGH priority** foundational articles (start here)
  - **476 MEDIUM priority** expansion articles  
  - **102 LOW priority** specialized articles
- Phase 5: [Future] Quality and cross-referencing
- Phase 6: [Future] Maintenance and evolution

## Implementation Ready
The framework now provides:
- **Complete structural foundation** - All 214 folders with comprehensive documentation
- **Comprehensive roadmaps** - Detailed specifications for 1,360 articles across 12 domains  
- **Clear priorities** - High/Medium/Low priority guidance with completion tracking
- **Cross-domain connections** - Mapped relationships between knowledge areas
- **Human-centric approach** - All content specified to emphasize relevance to human experience
- **Unified workflow** - Integrated article identification, creation, and progress tracking system

## Development Tools

### Make Commands
The project includes a comprehensive Makefile with development and maintenance commands:

**📋 Development Commands:**
- `make status` - Show overall project completion statistics
- `make outline-todo` - List folders with blank/placeholder READMEs (< 5 lines)  
- `make todo` - List leaf folders with insufficient articles (< 4 + README)
- `make help` - Show all available commands

**🚀 Phase 4 Article Commands (NEW UNIFIED SYSTEM):**
- `make article-todo` - **Unified article system** with priority filtering and completion tracking
  - `make article-todo` - Show all 782 HIGH priority articles (default)
  - `make article-todo priority=medium` - Show all 476 MEDIUM priority articles  
  - `make article-todo priority=low` - Show all 102 LOW priority articles
  - `make article-todo priority=all` - Show breakdown across all priorities with completion status
  - `make article-todo show_completed=false` - Hide completed articles, show only remaining work
  - `make article-todo limit=10` - Limit to first 10 articles per domain
- `make next-articles` - Suggest next 24 articles (2 per domain) for balanced coverage
- `make reconcile-todos` - **Automatically sync TODO checkboxes with existing articles (REQUIRED)**
- `make reconcile-todos-dry` - Preview checkbox changes without modifying files
- `make priority-high` - Legacy alias for `make article-todo priority=high`

**🏗️ Build Commands:**
- `make format` - Format markdown files (normalize spacing, line endings)
- `make build` - Convert markdown to HTML in dist/ folder (requires pandoc)
- `make serve` - Start development server for HTML version
- `make clean` - Remove build artifacts

**Usage Examples:**
```bash
# Check project status and identify work needed
make status

# Phase 4: Identify articles to write (NEW UNIFIED SYSTEM)
make article-todo                    # See all 718 high-priority articles with completion tracking
make article-todo priority=all       # Get breakdown across all priorities with completion status
make next-articles                   # Get balanced selection for next 24 articles across domains
make article-todo show_completed=false # See only remaining work, hide completed articles

# After creating articles, sync checkboxes automatically
make reconcile-todos-dry             # Preview what checkboxes would be updated
make reconcile-todos                 # Apply checkbox updates to match existing files

# See which folders still need articles  
make todo

# Format all markdown files
make format
```

### Development Workflow

**⚠️ CRITICAL: Session Re-anchoring (See Top of File for Full Requirements)**
The re-anchoring requirement is now detailed at the top of this file - scroll up to see the complete process that MUST be followed every time.

**Phase 4 Article Development Process:**
1. Run `make status` to see overall completion (currently 6.7% - 88/1,296 articles)
2. Use `make article-todo` to see all 718 high-priority articles with completion tracking  
3. Use `make next-articles` to get balanced selection of 24 articles across domains
4. Use `make article-todo priority=all` to see breakdown across all priorities
5. Check domain TODO.md files for detailed article specifications
6. Create articles following established README patterns and tone
7. **AUTOMATICALLY sync checkboxes** using `make reconcile-todos` (replaces manual updating)
8. Use `make article-todo show_completed=false` to track remaining work
9. Use `make format` to maintain consistent formatting

**⚠️ IMPORTANT:** Never manually update checkboxes in TODO.md files. Always use `make reconcile-todos` to ensure accuracy and prevent synchronization errors.

**Previous Development Process (Phase 3 - Complete):**
1. ✅ Used `make outline-todo` to prioritize README completion  
2. ✅ Used `make todo` to identify structural issues
3. ✅ Completed all 214 comprehensive READMEs (100.0%)
4. ✅ Created detailed article specifications in domain TODO.md files

## Contribution Guidelines
- Maintain consistent folder naming (Title_Case_With_Underscores)
- README files should be rich and comprehensive (≥5 lines meaningful content)
- TODO files should clearly specify article requirements
- Preserve the human-centric perspective throughout
- Focus on structure and roadmapping over article writing
- Use the make commands to track progress and identify priorities 


