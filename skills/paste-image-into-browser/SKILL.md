---
name: paste-image-into-browser
description: Attach a local image file to any focused web input (post composer, form, editor) via Claude-in-Chrome, when the site's native file-upload UI cannot be automated directly. Invoked by other skills (e.g. linkedin-post, x-post) — rarely used standalone.
---

# Paste a local image into a browser input

## When to use this

Only when the direct route is blocked. Try `find` / `read_page` +
`file_upload` or `upload_image` first — if a real `<input type="file">`
element is reachable, use that; it's simpler and doesn't require this
workaround.

Reach for this skill when the file-upload UI is unreachable — e.g. rendered
inside a JS shadow root invisible to the accessibility tree, or the only path
is a native OS file picker (which cannot be automated: never click "Upload
from computer" / "Browse" buttons expecting to interact with what opens).

## Why the workaround is needed

- The site's composer may render inside a shadow root with no accessibility
  refs — `find`/`read_page` return nothing, so `file_upload`/`upload_image`
  have no ref to target.
- Site CSP typically blocks fetching image bytes from a local server
  (`connect-src`), so you can't smuggle bytes in via `fetch()`.
- Extension-synthesized `Ctrl+V` (via the `computer` tool) does **not**
  trigger Chrome's native paste — it must be a real X11 keystroke.
- Chrome's certificate-warning interstitial (for a self-signed local HTTPS
  workaround) cannot be automated at all.

The reliable method: put the image on the **system clipboard**, physically
click the target input for real window focus, then send a **real** paste
keystroke.

## Preconditions

X11 session (check `echo $DISPLAY`, typically `:1`), `xclip` and `xdotool`
installed, Claude-in-Chrome connected to the target tab.

## Procedure

1. Get the target input's on-screen CSS rect via `javascript_tool`:
   `el.getBoundingClientRect()` (find `el` by whatever selector fits — e.g.
   `[contenteditable=true]`, `[data-testid=...]`; search shadow roots too if
   needed — see `find_editable` helper pattern below).
2. Calibrate the CSS→physical coordinate mapping for the current window
   (do this once per session/window; recalibrate if the window moves,
   resizes, or zoom changes):
   ```js
   window.__c = null;
   addEventListener('mousedown', e => { if (e.isTrusted) window.__c = {x: e.clientX, y: e.clientY} }, true);
   ```
   Then `xdotool mousemove <px> <py> click 1` at a safe, known point (empty
   page area), read back `window.__c`, and solve:
   `zoom = window.devicePixelRatio` (per-axis, usually equal),
   `offset = phys - css*zoom`.
   Sanity-check against a second point before trusting it.
3. Compute the physical (px, py) for the target input's rect center (or any
   safe point inside it) using that mapping.
4. Run: `scripts/paste-image.sh <image-file> <phys_x> <phys_y>`
   This copies the image to the clipboard (verifying the MIME type landed),
   physically clicks the given point, and sends a real Ctrl+V.
5. Screenshot to confirm the image preview appeared. If it didn't, the most
   likely causes are: click landed outside the actual input (recheck the
   rect/mapping), or the input wasn't focused/editable at that point.

### Finding a contenteditable inside shadow DOM

If the target editor lives inside a shadow root (common for rich composers),
locate it with a recursive search rather than `document.querySelector`:

```js
function findEditable(root, out=[]) {
  for (const el of root.querySelectorAll('*')) {
    if (el.isContentEditable) out.push(el);
    if (el.shadowRoot) findEditable(el.shadowRoot, out);
  }
  return out;
}
```

## Notes

- Original image files are used as-is — no resizing/re-encoding needed for
  clipboard paste (unlike a hypothetical base64/data-URL route, which is
  prohibitively expensive token-wise and not needed here).
- `xclip` forks and stays resident to serve the clipboard; no cleanup
  required between pastes, just re-run for the next image.
- One physical click per paste is the reliable pattern — extension clicks set
  DOM focus but Chrome won't deliver real key events without genuine window
  focus.
