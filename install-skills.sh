#!/usr/bin/env bash
# =============================================================================
# install-skills.sh — Install Claude Code skills from coding-agents
#
# Run from the TARGET project directory.
#
# COPY MODE (default):
#   ./install-skills.sh                        # install all skills
#   ./install-skills.sh hetzner-vm             # install specific skill(s)
#   ./install-skills.sh hetzner-vm linux-vm-hardening
#
# SUBMODULE MODE (stays in sync with updates):
#   ./install-skills.sh --submodule            # add submodule + symlink all
#   ./install-skills.sh --submodule hetzner-vm # add submodule + symlink specific
#   # To update later: git submodule update --remote .claude/_skills-source
#
# OTHER:
#   ./install-skills.sh --list                 # list available skills
#   ./install-skills.sh --source /other/path hetzner-vm
#   ./install-skills.sh --target /path/to/project hetzner-vm
# =============================================================================
set -euo pipefail

# --- Config ------------------------------------------------------------------

CODING_AGENTS_REPO="https://github.com/gabriel-f-santos/coding-agents"
SUBMODULE_PATH=".claude/_skills-source"
# Relative path from the target .claude/skills/ to the submodule's skills dir
# (.claude/skills/ -> ../ -> .claude/ -> _skills-source/skills/)
SYMLINK_BASE="../_skills-source/skills"

# --- Defaults ----------------------------------------------------------------

USE_SUBMODULE=false
LIST_ONLY=false
SOURCE_DIR=""
TARGET_DIR="$(pwd)"
declare -a SKILLS_TO_INSTALL=()

# Auto-detect source: if script lives inside coding-agents, use it directly
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -d "$SCRIPT_DIR/skills" ]]; then
  SOURCE_DIR="$SCRIPT_DIR"
fi

# --- Argument parsing --------------------------------------------------------

while [[ $# -gt 0 ]]; do
  case "$1" in
    --submodule)  USE_SUBMODULE=true; shift ;;
    --all)        shift ;; # default when no skills given, no-op
    --list)       LIST_ONLY=true; shift ;;
    --source)     SOURCE_DIR="${2:?--source requires a path}"; shift 2 ;;
    --target)     TARGET_DIR="${2:?--target requires a path}"; shift 2 ;;
    --help|-h)
      sed -n '3,20p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
      exit 0 ;;
    -*)
      echo "Unknown option: $1" >&2; exit 1 ;;
    *)
      SKILLS_TO_INSTALL+=("$1"); shift ;;
  esac
done

# --- Helpers -----------------------------------------------------------------

die()  { echo "erro: $*" >&2; exit 1; }
info() { echo "  → $*"; }
ok()   { echo "  ✓ $*"; }

resolve_source_skills() {
  if [[ -n "$SOURCE_DIR" ]]; then
    [[ -d "$SOURCE_DIR/skills" ]] \
      || die "Nao encontrei skills/ em '$SOURCE_DIR'"
    echo "$SOURCE_DIR/skills"
  elif $USE_SUBMODULE; then
    echo "$TARGET_DIR/$SUBMODULE_PATH/skills"
  else
    die "Nao sei onde estao as skills. Use --source /path/to/coding-agents ou --submodule"
  fi
}

list_skills() {
  local skills_dir="$1"
  echo ""
  echo "Skills disponíveis em $skills_dir:"
  echo ""
  for dir in "$skills_dir"/*/; do
    [[ -f "$dir/SKILL.md" ]] || continue
    local name
    name="$(basename "$dir")"
    [[ "$name" == example-* ]] && continue
    local desc
    desc="$(awk '/^description:/{rest=$0; sub(/^description:[ \t]*/,"",rest); if(rest!="" && rest!=">" && rest!="|"){gsub(/^"|"$/,"",rest); print rest; exit} f=1; next} f&&/^[ \t]+/{line=$0; sub(/^[ \t]+/,"",line); print line; exit} f&&/^[^ \t]/{exit}' "$dir/SKILL.md" | head -1)"
    printf "  %-30s %s\n" "$name" "${desc:-(sem descrição)}"
  done
  echo ""
}

setup_submodule() {
  cd "$TARGET_DIR"
  [[ -d ".git" ]] || die "--submodule requer que o diretório seja um repositório git"

  if git config --file .gitmodules --get-regexp "path" 2>/dev/null | grep -q "$SUBMODULE_PATH"; then
    info "Submodulo ja existe, atualizando..."
    git submodule update --remote "$SUBMODULE_PATH"
  else
    info "Adicionando submodulo: $CODING_AGENTS_REPO"
    git submodule add "$CODING_AGENTS_REPO" "$SUBMODULE_PATH"
    git submodule update --init "$SUBMODULE_PATH"
  fi
}

install_copy() {
  local skill="$1" src="$2" dst_dir="$3"
  local src_path="$src/$skill" dst_path="$dst_dir/$skill"

  [[ -d "$src_path" ]] || die "Skill '$skill' nao encontrada em $src"
  [[ -f "$src_path/SKILL.md" ]] || die "Sem SKILL.md em $src_path"

  if [[ -d "$dst_path" ]]; then
    rm -rf "$dst_path"
    info "Atualizando $skill..."
  else
    info "Instalando $skill..."
  fi

  cp -r "$src_path" "$dst_dir/"
  ok "$skill  (copiada → $dst_path)"
}

install_symlink() {
  local skill="$1" src="$2" dst_dir="$3"
  local src_path="$src/$skill" dst_path="$dst_dir/$skill"

  [[ -d "$src_path" ]] || die "Skill '$skill' nao encontrada em $src"

  if [[ -L "$dst_path" ]]; then
    rm "$dst_path"
    info "Re-linkando $skill..."
  elif [[ -d "$dst_path" ]]; then
    die "$dst_path ja existe como diretorio. Remova-o antes de usar --submodule."
  else
    info "Linkando $skill..."
  fi

  # Relative symlink: portable entre clones do repositório
  ln -s "$SYMLINK_BASE/$skill" "$dst_path"
  ok "$skill  (symlink → $SYMLINK_BASE/$skill)"
}

# --- Main --------------------------------------------------------------------

TARGET_SKILLS="$TARGET_DIR/.claude/skills"
mkdir -p "$TARGET_SKILLS"

# Submodule setup antes de resolver source (source depende do submodule)
if $USE_SUBMODULE; then
  echo ""
  echo "Configurando submodulo..."
  setup_submodule
fi

SOURCE_SKILLS="$(resolve_source_skills)"

# --list
if $LIST_ONLY; then
  list_skills "$SOURCE_SKILLS"
  exit 0
fi

# Montar lista de skills a instalar
if [[ ${#SKILLS_TO_INSTALL[@]} -eq 0 ]]; then
  for dir in "$SOURCE_SKILLS"/*/; do
    [[ -f "$dir/SKILL.md" ]] || continue
    name="$(basename "$dir")"
    [[ "$name" == example-* ]] && continue  # pula templates de exemplo
    SKILLS_TO_INSTALL+=("$name")
  done
fi

[[ ${#SKILLS_TO_INSTALL[@]} -gt 0 ]] || die "Nenhuma skill encontrada em $SOURCE_SKILLS"

echo ""
echo "Instalando ${#SKILLS_TO_INSTALL[*]} skill(s) em $TARGET_SKILLS"
echo ""

for skill in "${SKILLS_TO_INSTALL[@]}"; do
  if $USE_SUBMODULE; then
    install_symlink "$skill" "$SOURCE_SKILLS" "$TARGET_SKILLS"
  else
    install_copy "$skill" "$SOURCE_SKILLS" "$TARGET_SKILLS"
  fi
done

echo ""
echo "Concluído."

if $USE_SUBMODULE; then
  echo ""
  echo "Para atualizar as skills depois:"
  echo "  git submodule update --remote $SUBMODULE_PATH"
fi
