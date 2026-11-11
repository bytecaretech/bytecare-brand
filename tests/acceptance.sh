#!/usr/bin/env bash
# Acceptance check for the bytecare brand extension.
# Renders example.qmd as an HTML page and as a reveal.js presentation,
# then checks that both outputs carry the brand's fonts and logo.
set -uo pipefail

cd "$(dirname "$0")/.."

failures=0
fail() { echo "FAIL: $*"; failures=$((failures + 1)); }
pass() { echo "ok:   $*"; }

log=$(mktemp)
trap 'rm -f "$log"' EXIT

rm -rf example.html example-slides.html example_files

if quarto render example.qmd >"$log" 2>&1; then
  pass "quarto render example.qmd"
else
  cat "$log"
  fail "quarto render example.qmd"
  exit 1
fi

for out in example.html example-slides.html; do
  [[ -f "$out" ]] && pass "$out rendered" || fail "$out missing"
done

# CSS linked from a page, concatenated on one line.
linked_css() {
  grep -o 'href="[^"]*\.css"' "$1" | sed 's/^href="//; s/"$//' |
    while read -r f; do cat "$f"; done | tr '\n' ' '
}

for page in example example-slides; do
  css=$(linked_css "${page}.html")

  # Fonts load from Bunny Fonts, and from nowhere else.
  for family in Poppins Roboto JetBrains-Mono; do
    if grep -Eq "@import[[:space:]]*(url\()?['\"]?https://fonts\.bunny\.net/css\?family=${family}:" <<<"$css"; then
      pass "$page loads $family from Bunny Fonts"
    else
      fail "$page does not load $family from Bunny Fonts"
    fi
  done
  if grep -Eq 'fonts\.googleapis|fonts\.gstatic' "${page}.html" <<<"$css"; then
    fail "$page references Google Fonts"
  else
    pass "$page does not reference Google Fonts"
  fi

  # The logo appears, and the image it points to exists.
  logos=$(grep -o '[^"]*logo-medium\.png' "${page}.html" | sort -u)
  if [[ -z "$logos" ]]; then
    fail "$page does not show the logo"
  else
    ok=1
    for l in $logos; do [[ -f "$l" ]] || { echo "  missing logo $l"; ok=0; }; done
    [[ $ok -eq 1 ]] && pass "$page shows the logo" || fail "$page logo path broken"
  fi
done

# Each pattern must match the CSS a page links to.
expect_css() {
  local page=$1 description=$2 pattern=$3
  if grep -Eiq -- "$pattern" <<<"$(linked_css "${page}.html")"; then
    pass "$page: $description"
  else
    fail "$page: $description"
  fi
}

# HTML page: Bootstrap variables and heading rule.
expect_css example "body font is Roboto"         '--bs-body-font-family:[[:space:]]*Roboto'
expect_css example "headings use Poppins"        'h1,[^{]*\{[^}]*font-family:[[:space:]]*Poppins'
expect_css example "primary colour is purple"    '--bs-primary:[[:space:]]*#6755D3'
expect_css example "links are purple"            '--bs-link-color:[[:space:]]*#6755D3'
expect_css example "light background is grey"    '--bs-body-bg:[[:space:]]*#F5F5F5'

# reveal.js presentation: theme variables.
expect_css example-slides "body font is Roboto"      '--r-main-font:[[:space:]]*Roboto'
expect_css example-slides "headings use Poppins"     '--r-heading-font:[[:space:]]*Poppins'
expect_css example-slides "headings are purple"      '--r-heading-color:[[:space:]]*#6755D3'
expect_css example-slides "links are purple"         '--r-link-color:[[:space:]]*#6755D3'
expect_css example-slides "background is grey"       '--r-background-color:[[:space:]]*#F5F5F5'

echo
if [[ $failures -eq 0 ]]; then
  echo "All checks passed."
else
  echo "$failures check(s) failed."
  exit 1
fi
