---
name: linkedin-post
description: Create, attach an image to, and (optionally) schedule a LinkedIn post via Claude-in-Chrome. Use for any task that creates or schedules LinkedIn posts, especially ones with an image attachment.
---

# Posting to LinkedIn

## Prerequisites

Claude-in-Chrome connected, user already logged in to LinkedIn in the target
tab. For image attachments, this skill invokes the
**`paste-image-into-browser`** skill — don't re-derive that technique here.

## Procedure

1. Navigate to `https://www.linkedin.com/feed/`.
2. Open the composer: click the "Почати допис" / "Start a post" field.
3. Click into the text area and type the post text (the extension's `type`
   action works fine for plain text).
4. **If the text contains a URL**, LinkedIn auto-generates a link-preview
   card a moment later. If you intend to attach a custom image instead,
   dismiss the card first (✕ button on the card) — a preview card and a
   manually attached image can coexist visually wrong / confusingly, so
   always dismiss the auto card before pasting your own image.
5. To attach an image: invoke the `paste-image-into-browser` skill, targeting
   the post's contenteditable text/editor area (it lives inside a shadow
   root — search for `.ql-editor` via the recursive shadow-DOM search
   described in that skill). Do **not** try `find`/`read_page` on LinkedIn's
   photo-upload modal ("Редактор") — it renders inside an `interop-outlet`
   shadow root that is invisible to the accessibility tree; there is no
   reachable file-input ref there.
6. Screenshot to confirm both the text and the image preview look right
   before proceeding.

## Scheduling

1. Click the clock icon at the bottom of the composer (bottom-right, next to
   the post/publish button).
2. A "Запланувати допис" dialog opens with Дата (date) and Час (time) fields.
   - Triple-click the date field to select all, then click a day on the
     calendar picker that appears (it shows the current month; use the
     arrows to navigate months if needed).
   - Triple-click the time field; a dropdown of time options appears —
     click the matching one, or if not listed, type the value directly.
3. Click "Далі" (Next). The composer now shows "Опублікувати ср, DD серп. о
   HH:MM" with the button relabeled "Заплановати" (Schedule).
4. Click "Заплановати" to finalize. The composer closes on success.

## Verification

1. Open the composer again ("Почати допис").
2. Click the clock icon, then "Переглянути всі заплановані дописи" (View all
   scheduled posts).
3. Confirm the entry shows the right date/time, text, and image thumbnail.
4. Close the dialog (✕).

## Gotchas learned in practice

- Closing the composer with unsaved text prompts "Зберегти цей допис як
  чернетку?" (Save as draft?) — choose "Відхилити" (discard) to abandon
  cleanly, or "Зберегти як чернетку" to keep a draft.
- `linkedin.com/dashboard/scheduled-posts/` is **not** a valid URL for
  viewing scheduled posts — use the in-composer clock-icon flow above.
- Screen coordinates for date/time picker interactions are stable relative
  to the dialog, but always screenshot before clicking blind — LinkedIn's
  dialog layout can shift slightly depending on content length.
