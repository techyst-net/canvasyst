#!/bin/sh
# Rebrands the AFFiNE bundles as Canvyst, at container start.
#
# Done at startup rather than by mounting patched files because the asset
# filenames are content-hashed: a mount pinned to today's hash would silently
# stop applying the moment the image is updated, and the upstream name would
# reappear with nothing to indicate why. Patching in place adapts to whatever
# the current build happens to be named.
#
# This is an overlay over the published image. The source tree in this repo
# carries the same changes properly — components deleted, links repointed — so
# a build from source needs none of this. What the overlay cannot do is remove
# DOM: the two promotional surfaces below are blanked rather than deleted.
#
# Only display strings and outbound links are touched. The lowercase `affine.`
# i18n keys and module identifiers are deliberately left alone: they are code,
# and renaming them would break lookups. So are cdn.affine.pro asset URLs —
# they serve the editor's canvas fonts and PDF export fonts, and rewriting them
# breaks both.
set -e

STATIC=/app/static
BRAND="Canvyst"
SITE="https://canvyst.techyst.net/home"

if [ -d "$STATIC" ]; then

  # --- Outbound links ------------------------------------------------------
  #
  # Upstream marketing paths (/download, /blog, /terms, …) do not exist here.
  # Rather than collapsing every one of them to the product page, each maps to
  # the page that actually answers it. Longest patterns first: a bare host
  # replacement would strip the host and leave the path behind.
  #
  # cdn.affine.pro is excluded — see the note above. So is anything under
  # /api/worker/: the release feed, the image proxy and the link-preview
  # service are endpoints the app calls, and the catch-all below would
  # otherwise rewrite them into the marketing site and break all three. They
  # are parked behind a sentinel for the duration of this pass.
  grep -rlE 'https://(www\.|app\.|ai\.|docs\.)?affine\.pro' "$STATIC" 2>/dev/null \
  | while read -r f; do
      sed -i -E \
        -e 's#https://(www\.|app\.)?affine\.pro/api/worker/#@@WORKER\1END@@#g' \
        -e "s|https://docs\.affine\.pro/docs/self-host-affine|$SITE/support/|g" \
        -e "s|https://(www\.)?affine\.pro/pricing[a-zA-Z0-9/?=&._#-]*|$SITE/support/|g" \
        -e "s|https://(www\.)?affine\.pro/blog\?tag=Release\+Note|$SITE/changelog/|g" \
        -e "s|https://(www\.)?affine\.pro/redirect/discord|$SITE/community/|g" \
        -e "s|https://(www\.)?affine\.pro/teamhub|$SITE/support/|g" \
        -e "s|https://(www\.)?affine\.pro/privacy|$SITE/privacy/|g" \
        -e "s|https://(www\.)?affine\.pro/terms[a-zA-Z0-9#-]*|$SITE/terms/|g" \
        -e "s|https://(www\.)?affine\.pro/blog[a-zA-Z0-9/?=&+._-]*|$SITE/changelog/|g" \
        -e "s|https://(www\.)?affine\.pro/download[a-zA-Z0-9/-]*|$SITE|g" \
        -e "s|https://docs\.affine\.pro[a-zA-Z0-9/?=&._%-]*|$SITE/support/|g" \
        -e "s|https://ai\.affine\.pro[a-zA-Z0-9/?=&._-]*|$SITE|g" \
        -e "s|https://(www\.)?affine\.pro/[a-zA-Z0-9/?=&._#+-]*|$SITE|g" \
        -e "s|https://(www\.)?affine\.pro|$SITE|g" \
        -e 's#@@WORKER([a-z.]*)END@@#https://\1affine.pro/api/worker/#g' \
        "$f" || true
    done


  # --- Promotional surfaces ------------------------------------------------
  #
  # "Love our app? Star us on GitHub…" in the settings footer, and the "Tell us
  # your use case" Typeform row on the billing and licence pages. Both are
  # upstream's own asks and have no place in this product. The overlay can only
  # blank the strings; the source tree deletes the components outright.
  grep -rl 'Love our app' "$STATIC" 2>/dev/null | while read -r f; do
    sed -i 's|Love our app?[^"]*|<1></1><2></2>|g' "$f" || true
  done
  grep -rl 'Tell us your use case' "$STATIC" 2>/dev/null | while read -r f; do
    sed -i 's|Tell us your use case||g' "$f" || true
    sed -i 's|Please tell us more about your use case, to make [A-Za-z]* better\.||g' "$f" || true
  done

  # --- Display name --------------------------------------------------------
  #
  # Capitalised "AFFiNE" is the brand token; the lowercase "affine" used in
  # keys and paths is left untouched. "Canvyst" is the residue of an earlier
  # rename that used a person's name instead of the product's.
  #
  # Two things contain "AFFiNE" and must survive the rename, so they are parked
  # behind sentinels first and restored afterwards:
  #
  #   * i18n keys — `com.affine.aboutAFFiNE.*` is a lookup key, not a label.
  #     Renaming it means every string under it resolves to nothing and the
  #     About page renders raw key names.
  #   * the upstream repository URL, which is a real address we link to
  #     deliberately. An earlier rename had pointed it at `toeverything/Canvyst`,
  #     which does not exist.
  grep -rlE 'AFFiNE|Canvyst' "$STATIC" 2>/dev/null | while read -r f; do
    sed -i \
      -e 's|com\.affine\.aboutAFFiNE|@@I18NKEY@@|g' \
      -e 's|toeverything/AFFiNE|@@UPSTREAM@@|g' \
      -e 's|toeverything/Canvyst|@@UPSTREAM@@|g' \
      -e "s|AFFiNE|$BRAND|g" \
      -e "s|Canvyst|$BRAND|g" \
      -e 's|@@I18NKEY@@|com.affine.aboutAFFiNE|g' \
      -e 's|@@UPSTREAM@@|toeverything/AFFiNE|g' \
      "$f" || true
  done

  echo "[rebrand] applied $BRAND branding to $STATIC"
fi

exec docker-entrypoint.sh "$@"
