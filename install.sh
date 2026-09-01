#!/bin/sh
# Symlink the init-agents skill into the locations each harness discovers.
set -eu

REPO=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
SRC="$REPO/skills/init-agents"
NAME=init-agents

# ~/.agents/skills is the Agent Skills standard location: Codex, pi, and opencode all
# discover it. Claude Code does not, so it gets its own link.
TARGETS="$HOME/.agents/skills $HOME/.claude/skills"

usage() {
    echo "usage: $0 [--uninstall]" >&2
    exit 2
}

uninstall=false
case "${1-}" in
    --uninstall) uninstall=true ;;
    "") ;;
    *) usage ;;
esac

[ -f "$SRC/SKILL.md" ] || { echo "error: $SRC/SKILL.md not found" >&2; exit 1; }

status=0
for dir in $TARGETS; do
    link="$dir/$NAME"
    if $uninstall; then
        if [ -L "$link" ]; then
            rm "$link"
            echo "removed  $link"
        elif [ -e "$link" ]; then
            echo "skipped  $link (not a symlink — remove it by hand)" >&2
            status=1
        fi
        continue
    fi

    if [ -e "$link" ] && [ ! -L "$link" ]; then
        echo "error    $link exists and is not a symlink — refusing to replace it" >&2
        status=1
        continue
    fi
    mkdir -p "$dir"
    ln -sfn "$SRC" "$link"
    echo "linked   $link -> $SRC"
done

if $uninstall || [ $status -ne 0 ]; then exit $status; fi

found=0
echo
echo "Discovered by:"
for h in claude codex pi opencode; do
    command -v "$h" >/dev/null 2>&1 || continue
    found=$((found + 1))
    case $h in
        claude)   where="~/.claude/skills/$NAME" ;;
        codex)    where="~/.agents/skills/$NAME" ;;
        pi)       where="~/.agents/skills/$NAME  (also /skill:$NAME)" ;;
        opencode) where="~/.agents/skills/$NAME" ;;
    esac
    printf '  %-9s %s\n' "$h" "$where"
done

if [ "$found" -eq 0 ]; then
    echo "  nothing yet — looked for claude, codex, pi, opencode on PATH."
    echo
    echo "The links are in place and start working as soon as one is installed;"
    echo "there is no need to re-run this."
fi

# A second copy under another tool's own root makes that tool list the skill twice.
for dup in "$HOME/.codex/skills/$NAME" \
           "$HOME/.pi/agent/skills/$NAME" \
           "$HOME/.config/opencode/skill/$NAME" \
           "$HOME/.config/opencode/skills/$NAME"; do
    [ -e "$dup" ] || continue
    echo
    echo "warning: $NAME also exists at $dup" >&2
    echo "         that tool will see it twice — remove one copy." >&2
done

if [ -f "$HOME/.claude/plugins/installed_plugins.json" ] &&
   grep -q agents-kit "$HOME/.claude/plugins/installed_plugins.json" 2>/dev/null; then
    echo
    echo "warning: agents-kit is also installed as a Claude Code plugin, so Claude Code" >&2
    echo "         will see $NAME twice. Uninstall one of the two routes." >&2
fi

exit $status
