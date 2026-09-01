#!/bin/sh
# One-shot installer. Fetches agents-kit and puts the init-agents skill where
# each tool looks for it.
#
#   curl -fsSL https://raw.githubusercontent.com/TOoSmOotH/agents-kit/main/get.sh | sh
#   curl -fsSL https://raw.githubusercontent.com/TOoSmOotH/agents-kit/main/get.sh | sh -s -- --project
set -eu

REPO_URL=https://github.com/TOoSmOotH/agents-kit.git
TARBALL=https://codeload.github.com/TOoSmOotH/agents-kit/tar.gz/refs/heads/main
NAME=init-agents
mode=user

for arg in "$@"; do
    case "$arg" in
        --project|-p) mode=project ;;
        --user|-u)    mode=user ;;
        -h|--help)
            echo "usage: get.sh [--user|--project]"
            echo "  --user     (default) install once for every project on this machine"
            echo "  --project  vendor into the current repo so the team gets it on clone"
            exit 0 ;;
        *) echo "get.sh: unknown option '$arg'" >&2; exit 2 ;;
    esac
done

have() { command -v "$1" >/dev/null 2>&1; }

fetch_tarball_into() {
    # $1 = destination directory for the repo contents
    have curl || { echo "get.sh: needs curl or git" >&2; exit 1; }
    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT
    curl -fsSL "$TARBALL" | tar -xzf - -C "$tmp"
    src=$(find "$tmp" -maxdepth 1 -type d -name 'agents-kit-*' | head -1)
    [ -n "$src" ] || { echo "get.sh: unexpected archive layout" >&2; exit 1; }
    rm -rf "$1"
    mkdir -p "$(dirname "$1")"
    mv "$src" "$1"
}

if [ "$mode" = user ]; then
    DEST=${AGENTS_KIT_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/agents-kit}
    if have git; then
        if [ -d "$DEST/.git" ]; then
            echo "updating $DEST"
            git -C "$DEST" pull --ff-only -q
        else
            echo "cloning into $DEST"
            mkdir -p "$(dirname "$DEST")"
            git clone -q --depth 1 "$REPO_URL" "$DEST"
        fi
    else
        echo "downloading into $DEST"
        fetch_tarball_into "$DEST"
    fi
    sh "$DEST/install.sh"
    exit $?
fi

# --project: vendor a real copy into this repo so it travels with a clone.
[ -d .git ] || echo "get.sh: note — no .git here; installing into $(pwd) anyway" >&2

vendor=.agents/skills/$NAME
echo "downloading into $vendor"
tmpkit=$(mktemp -d)
trap 'rm -rf "$tmpkit"' EXIT
if have git; then
    git clone -q --depth 1 "$REPO_URL" "$tmpkit/kit"
else
    fetch_tarball_into "$tmpkit/kit"
fi
[ -f "$tmpkit/kit/skills/$NAME/SKILL.md" ] || { echo "get.sh: skill not found in download" >&2; exit 1; }

mkdir -p .agents/skills
rm -rf "$vendor"
cp -R "$tmpkit/kit/skills/$NAME" "$vendor"
echo "vendored  $vendor"

# Claude Code does not read .agents/skills, so point its own path at the same copy.
mkdir -p .claude/skills
link=.claude/skills/$NAME
if [ -e "$link" ] && [ ! -L "$link" ]; then
    echo "warning  $link exists and is not a symlink — left alone" >&2
elif ln -sfn ../../"$vendor" "$link" 2>/dev/null; then
    echo "linked    $link -> ../../$vendor"
else
    cp -R "$vendor" "$link"
    echo "copied    $link (symlink unsupported here)"
fi

echo
here=""
for h in claude codex pi opencode; do
    have "$h" && here="$here $h"
done
if [ -n "$here" ]; then
    echo "On this machine:$here will pick it up here."
else
    echo "No agent found on PATH here — that is fine, the paths are for whoever clones."
fi
echo "Both paths are installed regardless of what is on this machine, because they are"
echo "committed for teammates whose tools differ from yours."

if have pi; then
    echo
    echo "pi note: project-local skills load only after you trust the project. It asks once"
    echo "         interactively; for 'pi -p' runs, pass --approve."
fi

echo
echo "Commit both paths so the team gets the skill on clone:"
echo "  git add .agents/skills .claude/skills"
