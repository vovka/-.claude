---
name: x-post
description: Create, attach an image to, and (optionally) schedule a post on X (Twitter) via Claude-in-Chrome. Use for any task that creates or schedules X/Twitter posts, especially ones with an image attachment.
---

# Posting to X (Twitter)

## Prerequisites

Claude-in-Chrome connected, user already logged in to X in the target tab.
For image attachments, this skill invokes the **`paste-image-into-browser`**
skill — don't re-derive that technique here.

## Procedure

1. Navigate to `https://x.com/home`.
2. Click the compose box at the top ("Що відбувається?" / "What's
   happening?") or the compose button in the left nav.
3. Type the post text into `[data-testid="tweetTextarea_0"]` (the extension's
   `type` action works fine).
4. To attach an image: invoke the `paste-image-into-browser` skill, targeting
   `[data-testid="tweetTextarea_0"]`'s rect. Unlike LinkedIn, X's composer is
   plain DOM (no shadow-root obstruction) and a link in the text does not
   need to be dismissed before pasting an image — both can coexist, but
   check the result visually anyway.
5. Screenshot to confirm the text and image preview look right.

## Scheduling

1. Find and click the "Запланувати пост" / "Schedule post" button in the
   composer toolbar — reachable directly via `find` (no shadow-DOM workaround
   needed on X). This opens the "Розклад" (Schedule) dialog.
2. Set the date via the Місяць/День/Рік (Month/Day/Year) dropdowns and time
   via the Година/Хвилина (Hour/Minute) dropdowns — these are real `<select>`
   elements, so use `form_input` with the target value directly (e.g.
   `form_input(ref, "14")` for hour 14), not clicking through option lists.
3. If the dialog shows "Публікацію поста не можна запланувати на час, який
   уже минув" (Cannot schedule a post for a time that has already passed),
   the chosen time is in the past — pick a later time.
4. Click "Підтвердити" (Confirm) to close the date/time dialog. The
   composer's publish button relabels to "Розклад" (Schedule).
5. Click "Розклад" to finalize. A toast confirms: "Ваш пост буде опубліковано
   <date> о <time>" with a "Переглянути" (View) link.

## Verification

1. Open the composer, click "Запланувати пост" again, then find and click
   "Заплановані пости" (Scheduled posts) inside that flow — it lands on
   `x.com/compose/post/unsent/scheduled`, under the "Заплановано" (Scheduled)
   tab (as opposed to "Ненадіслані пости" / Undelivered, which is drafts).
2. Confirm the entry shows the right date/time, text, and image thumbnail.

## Gotchas learned in practice

- `x.com/compose/post/schedule/list` is **not** a valid URL — use the
  in-composer "Заплановані пости" flow above instead.
- X may auto-tag an attached image "Створено за допомогою штучного
  інтелекту" (Created with AI) if it detects AI-generation markers in the
  file — this is automatic/informational, not an error, and doesn't block
  scheduling.
