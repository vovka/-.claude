---
name: upload-files-chrome-devtools
description: Upload files to web pages using Chrome DevTools Protocol via Kapture browser automation
allowed-tools: chrome-devtools_upload_file, chrome-devtools_take_snapshot, chrome-devtools_evaluate_script, kapture_elements, grep, read
---

# Upload Files with Chrome DevTools

## When to Use This

- When automating file uploads via browser automation (Kapture)
- When a website's upload button triggers a hidden file input element
- When you need to upload files to multiple upload slots (e.g., multiple photos, digital files)
- Specifically for Etsy listing creation (photos, digital files, videos)

## Core Workflow

### Step 1: Locate the Upload Element

Find the button or input that triggers file upload:

1. **Take a snapshot** of the page: `chrome-devtools_take_snapshot`
2. **Search for keywords** like "Upload an image", "Add file", "Drag and drop"
3. **Use `kapture_elements`** to find hidden file inputs: `kapture_elements` with selector `input[type=file]`
4. **Identify the correct element**:
   - For primary photo: usually the first upload button
   - For additional photos: subsequent upload slots
   - For digital files: separate upload area after selecting "Digital files" radio

### Step 2: Get the Element UID

The `chrome-devtools_upload_file` tool requires a `uid` parameter:

- If the upload button is visible in the snapshot, its UID will be listed (e.g., `uid=3_4`)
- For hidden file inputs, they may not appear in the snapshot but can be referenced by their parent button's UID
- Use `chrome-devtools_evaluate_script` to find the file input's ID: `document.querySelector('input[type=file]').id`

### Step 3: Upload the File

Use `chrome-devtools_upload_file`:

```
chrome-devtools_upload_file(
  tabId: "<tab-id>",
  uid: "<element-uid>",
  filePath: "/absolute/path/to/file.jpg"
)
```

### Step 4: Handle Multiple Uploads

For multiple files (e.g., photos + video):

1. Upload primary photo first
2. Wait for processing (2-3 seconds)
3. Upload additional files to subsequent slots
4. For videos: ensure the file input accepts video MIME types (check `accept` attribute)

### Step 5: Verify Upload

- Take a screenshot to confirm file appears
- Check for error messages
- For digital files, verify the file name appears in the digital files section

## Examples

### Example 1: Upload Primary Photo to Etsy Listing

```
# Take snapshot to find upload button UID
chrome-devtools_take_snapshot(tabId="176737219")

# Found button: uid=3_4 "Upload an image"
chrome-devtools_upload_file(
  tabId="176737219",
  uid="3_4",
  filePath="/home/user/photos/product.jpg"
)
```

### Example 2: Upload Digital File (PDF archive)

```
# After selecting "Digital files" radio, find the "Add file" button
# From snapshot: uid=2_5 "Add file"
chrome-devtools_upload_file(
  tabId="176737219",
  uid="2_5",
  filePath="/home/user/files/product.zip"
)
```

### Example 3: Find Hidden File Input

```
# Use JavaScript to find file input ID
chrome-devtools_evaluate_script(
  tabId="176737219",
  function: "() => document.querySelector('input[type=file]').id"
)
# Returns: "thumbnail-upload-abc123"
# Use that ID as selector for kapture_elements
kapture_elements(
  tabId="176737219",
  selector: "#thumbnail-upload-abc123"
)
```

## Common Pitfalls

1. **Element not found**: The UID may change after page interactions. Re-take snapshot if element not found.
2. **Cannot accept file directly**: Some upload buttons are not directly linked to file inputs. Try using the parent button's UID.
3. **Video upload fails**: Ensure the file input accepts video MIME types (`accept` attribute includes `video/mp4`).
4. **Multiple file inputs**: Etsy creates separate file inputs for each photo slot. Use the correct one (first slot = primary).
5. **Page reload**: After uploading, the page may reload or update dynamically. Wait before next action.

## Etsy-Specific Notes

- **Photo slots**: 10+ file inputs with IDs like `thumbnail-upload-<uuid>`
- **Digital files**: Separate upload area after "Digital files" radio selection
- **Video**: Can be uploaded to any photo slot (Etsy will treat it as video)
- **File size limits**: Photos <1MB recommended, videos <100MB
- **Accepted formats**: JPG, PNG, GIF for photos; MP4, MOV for videos

## References

- Kapture browser automation tool
- Chrome DevTools Protocol documentation
- Etsy listing creation workflow
