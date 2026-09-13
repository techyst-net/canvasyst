#!/usr/bin/env python3
"""Rebuilds onboarding.zip — the workspace every new Canvyst user starts in.

Upstream's "Getting Started" document is a marketing piece for AFFiNE: it
opens with "Welcome to AFFiNE!", embeds a YouTube promo, bookmarks affine.pro
and carries seventeen images, most of them AFFiNE logos. None of that belongs
in a product called Canvyst, and the snapshot is a generated file nobody
would hand-edit — so it is generated here instead.

The second document in the archive ("How to use folder and Tags") is upstream's
and is kept as-is; it teaches the feature without branding it. Only the two
image assets it references are carried over.

    python3 build-getting-started.py

Writes onboarding.zip next to this script.
"""
import json
import pathlib
import shutil
import time
import zipfile

HERE = pathlib.Path(__file__).parent
ZIP = HERE / "onboarding.zip"
DOC_ID = "F-TNy6Tt3t"
TITLE = "Getting Started"

# Stable ids keep the snapshot byte-identical between runs, so rebuilding it
# does not show up as a spurious diff.
_counter = iter(range(1, 10_000))


def _id(prefix="b"):
    return f"{prefix}{next(_counter):04d}"


def _text(*parts):
    """A rich-text value. A part is either a string or (string, link)."""
    delta = []
    for p in parts:
        if isinstance(p, tuple):
            delta.append({"insert": p[0], "attributes": {"link": p[1]}})
        elif p:
            delta.append({"insert": p})
    return {"$blocksuite:internal:text$": True, "delta": delta}


TS = 1757721600000  # fixed timestamp; see _id() for why


def _block(flavour, props, children=(), version=1):
    props = dict(props)
    props.setdefault("meta:createdAt", TS)
    props.setdefault("meta:updatedAt", TS)
    return {
        "type": "block",
        "id": _id(),
        "flavour": flavour,
        "version": version,
        "props": props,
        "children": list(children),
    }


def para(*parts, type="text"):
    return _block("affine:paragraph",
                  {"type": type, "text": _text(*parts), "collapsed": False})


def h(level, text):
    return para(text, type=f"h{level}")


def quote(*parts):
    return para(*parts, type="quote")


def bullet(*parts):
    return _block("affine:list", {
        "type": "bulleted", "text": _text(*parts),
        "checked": False, "collapsed": False, "order": None,
    })


def todo(*parts):
    return _block("affine:list", {
        "type": "todo", "text": _text(*parts),
        "checked": False, "collapsed": False, "order": None,
    })


def divider():
    return _block("affine:divider", {})


SITE = "https://canvyst.techyst.net/home"

BODY = [
    para("Canvyst is a place to write things down and a place to draw them "
         "out — the same page, two ways of looking at it. This document is "
         "yours: edit it, break it, delete it."),

    h(2, "Two views of one document"),
    para("Every document has a Page view and an Edgeless view. Use the toggle "
         "at the top left to switch between them."),
    bullet("Page is the block editor — headings, lists, tables, code, images."),
    bullet("Edgeless is an infinite canvas. The same content becomes cards you "
           "can move, connect and draw around."),
    para("Nothing is duplicated between them. An edit in one view is an edit "
         "in the other."),

    h(2, "Writing"),
    para("Press Enter for a new block. A few things worth knowing early:"),
    bullet("Type / to open the block menu — headings, lists, code, tables, "
           "images, embeds."),
    bullet("Type @ to link another document. Backlinks appear at the bottom of "
           "whatever you linked to."),
    bullet("Select text to format it, or turn it into a different kind of "
           "block."),
    bullet("Drag the handle at the left of a block to move it."),

    h(2, "Drawing"),
    para("Switch to Edgeless when prose stops being the right shape for the "
         "idea. Pen, shapes, connectors, sticky notes and frames are in the "
         "toolbar at the bottom. Documents you drop onto the canvas stay live "
         "— editing the card edits the document."),

    h(2, "Finding things again"),
    bullet("Folders group documents the way a filesystem would."),
    bullet("Tags cut across folders, so one document can sit in several places "
           "without copies."),
    bullet("Journals give you a dated page per day for running notes."),
    bullet("All docs is the full list, and search is in the sidebar."),
    para("There is a second document in this workspace, "
         "How to use folder and Tags, that walks through this properly."),

    h(2, "Working with other people"),
    para("Invite people from Settings → Members. Edits sync as they happen and "
         "you will see other people's cursors. There is no save button."),

    h(2, "Your data"),
    para("Documents are stored on Techyst infrastructure, not shared with the "
         "upstream project, and product analytics are off. Any document "
         "exports to Markdown, HTML, PDF or a snapshot from the ⋯ menu."),
    para("The details are on the ",
         ("privacy page", f"{SITE}/privacy/"), "."),

    h(2, "Try it now"),
    todo("Switch this document to Edgeless and move something."),
    todo("Type / on a new line and insert a table."),
    todo("Create a document and link to it from here with @."),
    todo("Put a tag on this document."),

    divider(),
    quote("Stuck, or something looks wrong? ",
          ("Support", f"{SITE}/support/"), " · ",
          ("Community", f"{SITE}/community/"), " · ",
          ("What's changed", f"{SITE}/changelog/")),
]


def build_snapshot():
    note = _block("affine:note", {
        "xywh": "[0,0,800,1200]",
        "background": {"dark": "#000000", "light": "#ffffff"},
        "index": "a0",
        "lockedBySelf": False,
        "hidden": False,
        "displayMode": "both",
        "edgeless": {"style": {
            "borderRadius": 8, "borderSize": 4,
            "borderStyle": "none", "shadowType": "--affine-note-shadow-box",
        }},
    }, BODY)

    surface = _block("affine:surface", {"elements": {}}, version=5)

    page = {
        "type": "block",
        "id": _id("p"),
        "flavour": "affine:page",
        "version": 2,
        "props": {"title": _text(TITLE)},
        "children": [surface, note],
    }

    return {
        "type": "page",
        "meta": {"id": DOC_ID, "title": TITLE,
                 "createDate": TS, "tags": []},
        "blocks": page,
    }


def main():
    if not ZIP.exists():
        raise SystemExit(f"{ZIP} not found — nothing to rebuild from")

    with zipfile.ZipFile(ZIP) as z:
        names = z.namelist()
        keep_doc = next(n for n in names if n.startswith("How to use folder"))
        keep_bytes = {keep_doc: z.read(keep_doc)}
        # Only the assets the retained document actually references survive;
        # the rest were illustrations for upstream's marketing copy.
        other = json.loads(keep_bytes[keep_doc])
        wanted = set()

        def walk(n):
            if n.get("flavour") == "affine:image":
                wanted.add(n["props"].get("sourceId"))
            for c in n.get("children", []):
                walk(c)

        walk(other["blocks"])
        for n in names:
            if n.startswith("assets/") and any(w in n for w in wanted if w):
                keep_bytes[n] = z.read(n)

    snapshot = json.dumps(build_snapshot(), indent=2, ensure_ascii=False)

    tmp = ZIP.with_suffix(".zip.new")
    with zipfile.ZipFile(tmp, "w", zipfile.ZIP_DEFLATED) as z:
        z.writestr("assets/", b"")
        for name, data in keep_bytes.items():
            z.writestr(name, data)
        z.writestr(f"{TITLE} -{DOC_ID}.snapshot.json", snapshot)
    shutil.move(tmp, ZIP)

    kept = len([k for k in keep_bytes if k.startswith("assets/")])
    print(f"wrote {ZIP} — 2 documents, {kept} assets "
          f"(was 17 assets, a YouTube embed and an affine.pro bookmark)")


if __name__ == "__main__":
    main()
