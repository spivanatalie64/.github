#!/bin/sh
# codeberg-shrink — Create an ultra-compressed Codeberg mirror
# Usage: codeberg-shrink REPO_NAME GITHUB_USER CODEBERG_TOKEN
# Produces a /tmp/codeberg-mirror/ directory ready to push

REPO="${1:-$GITHUB_REPOSITORY#*/}"
USER="${2:-spivanatalie64}"
TOKEN="${3:-$CODEBERG_TOKEN}"

[ -z "$REPO" ] && echo "Usage: codeberg-shrink REPO_NAME [USER] [TOKEN]" && exit 1

MIRROR_DIR="/tmp/codeberg-mirror"
rm -rf "$MIRROR_DIR"
mkdir -p "$MIRROR_DIR"

# Create the ultra-compressed mirror (just a pointer + Makefile + README)
cat > "$MIRROR_DIR/setup.sh" << 'EOF'
#!/bin/sh
# UltraMirror — pointer to canonical GitHub source
echo "Full source: https://github.com/USER/REPO"
git clone --depth=1 https://github.com/USER/REPO.git . 2>/dev/null || echo "Already here"
EOF
sed -i "s/USER/$USER/g; s/REPO/$REPO/g" "$MIRROR_DIR/setup.sh"
chmod +x "$MIRROR_DIR/setup.sh"

echo "# $REPO — Codeberg UltraMirror" > "$MIRROR_DIR/README.md"
echo "" >> "$MIRROR_DIR/README.md"
echo "Canonical source: https://github.com/$USER/$REPO" >> "$MIRROR_DIR/README.md"
echo "" >> "$MIRROR_DIR/README.md"
echo '```sh' >> "$MIRROR_DIR/README.md"
echo "make fetch" >> "$MIRROR_DIR/README.md"
echo '```' >> "$MIRROR_DIR/README.md"

echo "all: fetch" > "$MIRROR_DIR/Makefile"
echo "fetch:" >> "$MIRROR_DIR/Makefile"
echo -e "\tgit clone --depth=1 https://github.com/$USER/$REPO.git ." >> "$MIRROR_DIR/Makefile"

# Init git and push
cd "$MIRROR_DIR"
git init -b main 2>/dev/null
git config user.email "natalie@acreetionos.org"
git config user.name "Natalie Spiva"
git add -A && git commit -m "$REPO — Codeberg UltraMirror" --quiet 2>/dev/null

echo "✅ UltraMirror created: $MIRROR_DIR ($(du -sh . | cut -f1))"
echo "Compression ratio: INFINITE (source is on GitHub)"
