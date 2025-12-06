#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

TEMPLATE_VERSION="1.0.0"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Print colored message
print_message() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

print_header() {
    echo ""
    print_message "$BLUE" "═══════════════════════════════════════════════════════════"
    print_message "$BLUE" "  AI-First Development Template Setup (Local)"
    print_message "$BLUE" "  Version: ${TEMPLATE_VERSION}"
    print_message "$BLUE" "═══════════════════════════════════════════════════════════"
    echo ""
}

print_step() {
    print_message "$GREEN" "▶ $1"
}

print_error() {
    print_message "$RED" "✗ $1"
}

print_success() {
    print_message "$GREEN" "✓ $1"
}

print_warning() {
    print_message "$YELLOW" "⚠ $1"
}

# Check if project directory already exists
check_directory() {
    local project_name=$1

    # If using current directory, don't check existence
    if [ "$project_name" = "." ]; then
        return 0
    fi

    if [ -d "$project_name" ]; then
        print_error "Directory '$project_name' already exists!"
        echo ""
        echo "Please choose one of the following options:"
        echo "  1. Remove the existing directory: rm -rf $project_name"
        echo "  2. Choose a different project name"
        exit 1
    fi
}

# Show usage
show_usage() {
    cat <<EOF
Usage: $0 [OPTIONS] [project-name]

Setup AI-first development template for a new project (using local template).

Arguments:
  project-name    Name of the project directory to create (optional)
                  If not specified, templates will be installed in the current directory

Options:
  -h, --help      Show this help message
  -v, --version   Show template version
  --no-git        Skip git repository initialization

Examples:
  # Install templates in current directory
  $0

  # Create new project from local template
  $0 my-awesome-project

  # Create project without git initialization
  $0 --no-git my-project

EOF
}

# Copy template files
copy_template_files() {
    local project_name=$1
    local target_dir="$project_name"

    # For current directory, use absolute path
    if [ "$project_name" = "." ]; then
        target_dir="$(pwd)"
    fi

    # Check if target is the same as source
    if [ "$(cd "$target_dir" 2>/dev/null && pwd)" = "$SCRIPT_DIR" ]; then
        print_warning "Target directory is the same as template source. Skipping copy."
        return 0
    fi

    print_step "Copying template files from: $SCRIPT_DIR"

    # Copy all template files except git directory and script files
    rsync -a \
        --exclude='.git' \
        --exclude='setup.sh' \
        --exclude='setup-local.sh' \
        --exclude='.template-metadata.json' \
        --exclude='test-project-demo' \
        --exclude='PROJECT_README.md' \
        "$SCRIPT_DIR/" "$target_dir/" 2>/dev/null || {
        print_error "Failed to copy template files"
        exit 1
    }

    print_success "Template files copied"
}

# Create project-specific files
create_project_files() {
    local project_name=$1
    local display_name="$project_name"

    # For current directory, use the directory name
    if [ "$project_name" = "." ]; then
        display_name="$(basename "$(pwd)")"
    fi

    print_step "Creating project-specific files..."

    # Create .gitignore if it doesn't exist
    if [ ! -f "$project_name/.gitignore" ]; then
        cat > "$project_name/.gitignore" <<'EOF'
# Dependencies
node_modules/
__pycache__/
*.pyc
venv/
.venv/
vendor/

# Build outputs
dist/
build/
*.o
*.so
*.exe

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Environment
.env
.env.local
*.env

# Logs
*.log
logs/

# Temporary
tmp/
temp/
*.tmp

# Test coverage
coverage/
.coverage
*.cover
htmlcov/
EOF
    fi

    # Create .editorconfig if it doesn't exist
    if [ ! -f "$project_name/.editorconfig" ]; then
        cat > "$project_name/.editorconfig" <<'EOF'
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.{js,ts,jsx,tsx}]
indent_style = space
indent_size = 2

[*.{py}]
indent_style = space
indent_size = 4

[*.{go}]
indent_style = tab
indent_size = 4

[*.{yml,yaml}]
indent_style = space
indent_size = 2

[*.md]
trim_trailing_whitespace = false
EOF
    fi

    # Create project README
    cat > "$project_name/PROJECT_README.md" <<EOF
# $display_name

AIファースト開発テンプレートを使用したプロジェクトです。

## セットアップ日時
$(date '+%Y-%m-%d %H:%M:%S')

## 次のステップ

1. **プロジェクト情報の更新**
   - \`docs/product/vision.md\` - プロダクトビジョンを記述
   - \`docs/product/requirements.yaml\` - 機能要件を定義
   - \`docs/architecture/system_overview.md\` - システム構成を設計

2. **開発環境のセットアップ**
   - 使用する言語・フレームワークのインストール
   - \`docs/dev_process/coding_standards.md\` の確認と調整

3. **AIエージェントの設定**
   - \`CLAUDE.md\` を確認
   - \`docs/agent/roles.yaml\` で必要な役割を定義
   - \`generator_instructions/system_prompt.md\` をカスタマイズ

4. **バージョン管理の初期化** (まだの場合)
   \`\`\`bash
   git init
   git add .
   git commit -m "feat: initialize project with AI-first development template"
   \`\`\`

## ドキュメント構造

\`\`\`
$display_name/
├── docs/                          # ドキュメント
│   ├── product/                   # プロダクト定義
│   ├── architecture/              # アーキテクチャ
│   ├── agent/                     # AIエージェント設定
│   ├── dev_process/               # 開発プロセス
│   └── ops/                       # 運用
├── generator_instructions/        # AIエージェント指示
├── meta/                          # メタ情報
├── project/                       # プロジェクト管理
└── CLAUDE.md                      # Claude Code指示書
\`\`\`

## AI駆動開発の開始

Claude Codeまたは他のAIアシスタントに以下を参照させてください:

- \`CLAUDE.md\` - AI向けの包括的な指示書
- \`generator_instructions/\` - 行動規則と制約
- \`docs/dev_process/\` - 開発規約

---
Generated by AI-First Development Template Setup Script (Local) v${TEMPLATE_VERSION}
EOF

    print_success "Project-specific files created"
}

# Initialize git repository (optional)
init_git() {
    local project_name=$1

    print_step "Initializing git repository..."

    cd "$project_name"

    if git init; then
        git add .
        git commit -m "feat: initialize project with AI-first development template

- Setup project structure based on AI-first development template
- Add comprehensive documentation templates
- Configure AI agent instructions and constraints
- Prepare development process guidelines

Template version: ${TEMPLATE_VERSION}

🤖 Generated with AI-First Development Template Setup Script (Local)" 2>/dev/null || true

        print_success "Git repository initialized"
    else
        print_warning "Git initialization failed (git may not be installed)"
    fi

    cd - > /dev/null
}

# Create project metadata
create_metadata() {
    local project_name=$1
    local display_name="$project_name"

    # For current directory, use the directory name
    if [ "$project_name" = "." ]; then
        display_name="$(basename "$(pwd)")"
    fi

    cat > "$project_name/.template-metadata.json" <<EOF
{
  "template_version": "${TEMPLATE_VERSION}",
  "template_source": "local",
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "project_name": "$display_name"
}
EOF
}

# Print next steps
print_next_steps() {
    local project_name=$1

    echo ""
    print_message "$GREEN" "═══════════════════════════════════════════════════════════"
    print_message "$GREEN" "  Setup Complete!"
    print_message "$GREEN" "═══════════════════════════════════════════════════════════"
    echo ""

    if [ "$project_name" = "." ]; then
        echo "Your AI-first development templates have been installed in the current directory."
    else
        echo "Your AI-first development project is ready at: $project_name/"
    fi
    echo ""
    echo "Next steps:"
    echo ""

    if [ "$project_name" != "." ]; then
        echo "  1. Navigate to your project:"
        print_message "$BLUE" "     cd $project_name"
        echo ""
    fi

    echo "  $([ "$project_name" = "." ] && echo "1" || echo "2"). Review the project README:"
    print_message "$BLUE" "     cat PROJECT_README.md"
    echo ""
    echo "  $([ "$project_name" = "." ] && echo "2" || echo "3"). Customize project information:"
    print_message "$BLUE" "     \$EDITOR docs/product/vision.md"
    print_message "$BLUE" "     \$EDITOR docs/product/requirements.yaml"
    echo ""
    echo "  $([ "$project_name" = "." ] && echo "3" || echo "4"). Start using AI agents:"
    print_message "$BLUE" "     # Reference CLAUDE.md for AI instructions"
    echo ""
    print_success "Happy AI-driven development! 🚀"
    echo ""
}

# Main function
main() {
    local skip_git=false
    local project_name=""

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -v|--version)
                echo "AI-First Development Template Setup (Local) v${TEMPLATE_VERSION}"
                exit 0
                ;;
            --no-git)
                skip_git=true
                shift
                ;;
            -*)
                print_error "Unknown option: $1"
                echo ""
                show_usage
                exit 1
                ;;
            *)
                project_name="$1"
                shift
                ;;
        esac
    done

    # If no project name is provided, use current directory
    if [ -z "$project_name" ]; then
        project_name="."
        print_warning "No project name specified. Installing templates in current directory."
    fi

    # Validate project name (skip validation for current directory)
    if [ "$project_name" != "." ] && [[ ! "$project_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        print_error "Invalid project name. Use only letters, numbers, hyphens, and underscores."
        exit 1
    fi

    print_header

    # Check if directory already exists
    check_directory "$project_name"

    # Copy template files
    copy_template_files "$project_name"

    # Create project-specific files
    create_project_files "$project_name"
    create_metadata "$project_name"

    # Initialize git if not skipped (skip for current directory if already a git repo)
    if [ "$skip_git" = false ]; then
        if [ "$project_name" = "." ] && [ -d ".git" ]; then
            print_warning "Git repository already exists. Skipping git initialization."
        else
            init_git "$project_name"
        fi
    fi

    # Print next steps
    print_next_steps "$project_name"
}

# Run main function
main "$@"
