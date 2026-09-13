#!/bin/sh
# Regression test for rebrand.sh.
#
#   sh brand/rebrand.test.sh
#
# rebrand.sh rewrites minified bundles with sed, which is exactly the kind of
# thing that breaks quietly: a pattern that is slightly too greedy turns a
# working API endpoint into a marketing URL, or renames an i18n key so every
# string under it renders as a raw key name. Both of those happened. The cases
# below are the ones that bit, plus the ones the script is actually for.
set -e

HERE=$(cd "$(dirname "$0")" && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$TMP/static"
cat > "$TMP/static/bundle.js" <<'FIXTURE'
{
"feed":"https://affine.pro/api/worker/releases",
"imageProxy":"https://affine.pro/api/worker/image-proxy",
"linkPreview":"https://app.affine.pro/api/worker/link-preview",
"font":"https://cdn.affine.pro/fonts/Inter-Regular.woff2",
"pricing":"https://affine.pro/pricing",
"download":"https://affine.pro/download",
"privacy":"https://affine.pro/privacy",
"terms":"https://affine.pro/terms#ai",
"selfhost":"https://docs.affine.pro/docs/self-host-affine",
"discord":"https://affine.pro/redirect/discord",
"blog":"https://affine.pro/blog?tag=Release+Note",
"ai":"https://ai.affine.pro",
"root":"https://affine.pro/",
"repo":"https://github.com/toeverything/Zeshan",
"i18nKey":"com.affine.aboutAFFiNE.title",
"flavour":"affine:paragraph",
"display":"About AFFiNE",
"stale":"Zeshan Cloud",
"promo":"Love our app? <1>Star us on GitHub</1> and <2>create issues</2> for your valuable feedback!",
"useCase":"Tell us your use case"
}
FIXTURE

# Run the real script against the fixture instead of /app/static, and stop it
# short of exec'ing the image entrypoint.
sed -e "s|^STATIC=/app/static|STATIC=$TMP/static|" \
    -e "s|^exec docker-entrypoint.sh.*|:|" \
    "$HERE/rebrand.sh" > "$TMP/run.sh"
sh "$TMP/run.sh" > /dev/null

fail=0
check() { # check <label> <expected> <actual>
  if [ "$2" = "$3" ]; then
    printf '  ok   %s\n' "$1"
  else
    printf '  FAIL %s\n       want: %s\n       got:  %s\n' "$1" "$2" "$3"
    fail=1
  fi
}

get() { # get <json key>
  sed -n "s/.*\"$1\":\"\([^\"]*\)\".*/\1/p" "$TMP/static/bundle.js"
}

SITE="https://canvyst.techyst.net/home"

echo "endpoints that must survive untouched:"
check "release feed"   "https://affine.pro/api/worker/releases"          "$(get feed)"
check "image proxy"    "https://affine.pro/api/worker/image-proxy"       "$(get imageProxy)"
check "link preview"   "https://app.affine.pro/api/worker/link-preview"  "$(get linkPreview)"
check "canvas font"    "https://cdn.affine.pro/fonts/Inter-Regular.woff2" "$(get font)"
check "i18n key"       "com.affine.aboutAFFiNE.title"                    "$(get i18nKey)"
check "block flavour"  "affine:paragraph"                                "$(get flavour)"
check "upstream repo"  "https://github.com/toeverything/AFFiNE"          "$(get repo)"

echo "marketing links that must land on a page we serve:"
check "pricing"  "$SITE/support/"    "$(get pricing)"
check "download" "$SITE"             "$(get download)"
check "privacy"  "$SITE/privacy/"    "$(get privacy)"
check "terms"    "$SITE/terms/"      "$(get terms)"
check "selfhost" "$SITE/support/"    "$(get selfhost)"
check "discord"  "$SITE/community/"  "$(get discord)"
check "blog"     "$SITE/changelog/"  "$(get blog)"
check "ai"       "$SITE"             "$(get ai)"
check "root"     "$SITE"             "$(get root)"

echo "branding:"
check "display name" "About Canvyst"  "$(get display)"
check "stale rename" "Canvyst Cloud"  "$(get stale)"
check "promo blanked"    "<1></1><2></2>" "$(get promo)"
check "use case blanked" ""               "$(get useCase)"

echo
if [ "$fail" -eq 0 ]; then
  echo "rebrand.sh: all checks passed"
else
  echo "rebrand.sh: FAILURES above"
  exit 1
fi
