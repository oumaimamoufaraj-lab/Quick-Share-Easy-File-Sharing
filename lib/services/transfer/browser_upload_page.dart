/// Inline HTML served at `GET /` for browser-based uploads.
String buildBrowserUploadPage({
  required String deviceName,
  required String sessionToken,
  required int chunkSize,
  required int chunkThreshold,
}) {
  final escapedName = _escapeHtml(deviceName);
  final escapedToken = Uri.encodeComponent(sessionToken);

  return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>File Share — $escapedName</title>
  <style>
    :root {
      --bg: #f2f2f7;
      --card: #ffffff;
      --text: #1c1c1e;
      --muted: #6c6c70;
      --primary: #007aff;
      --primary-dark: #005ecb;
      --danger: #ff3b30;
      --success: #34c759;
      --border: #e5e5ea;
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
      background: var(--bg);
      color: var(--text);
      padding: 24px 16px 40px;
    }
    .wrap { max-width: 440px; margin: 0 auto; }
    .card {
      background: var(--card);
      border-radius: 18px;
      padding: 22px;
      box-shadow: 0 8px 24px rgba(0,0,0,0.06);
    }
    h1 { font-size: 24px; margin: 0 0 6px; letter-spacing: -0.3px; }
    .subtitle { color: var(--muted); line-height: 1.5; margin: 0 0 18px; font-size: 15px; }
    label { display: block; font-size: 13px; font-weight: 600; margin-bottom: 6px; color: var(--muted); }
    input[type=text], input[type=file] {
      width: 100%;
      padding: 12px 14px;
      border-radius: 12px;
      border: 1px solid var(--border);
      font-size: 16px;
      margin-bottom: 14px;
      background: #fafafa;
    }
    input[type=file] { padding: 10px; background: #fff; }
    button {
      width: 100%;
      border: 0;
      border-radius: 14px;
      padding: 15px 18px;
      font-size: 16px;
      font-weight: 600;
      color: #fff;
      background: var(--primary);
      cursor: pointer;
    }
    button:disabled { opacity: 0.55; cursor: not-allowed; }
    button:not(:disabled):active { background: var(--primary-dark); }
    #fileList { margin: 4px 0 16px; }
    .file-row {
      display: flex;
      justify-content: space-between;
      gap: 12px;
      padding: 10px 0;
      border-bottom: 1px solid var(--border);
      font-size: 14px;
    }
    .file-row:last-child { border-bottom: 0; }
    .file-name { overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
    .file-size { color: var(--muted); flex-shrink: 0; }
    #progressWrap { display: none; margin-top: 16px; }
    .progress-label { font-size: 13px; color: var(--muted); margin-bottom: 8px; }
    .progress-track {
      height: 8px;
      background: var(--border);
      border-radius: 999px;
      overflow: hidden;
    }
    .progress-bar {
      height: 100%;
      width: 0%;
      background: var(--primary);
      transition: width 0.15s ease;
    }
    #msg {
      margin-top: 14px;
      font-size: 14px;
      line-height: 1.45;
      min-height: 20px;
    }
    #msg.error { color: var(--danger); }
    #msg.success { color: var(--success); }
    #msg.info { color: var(--muted); }
  </style>
</head>
<body>
  <div class="wrap">
    <div class="card">
      <h1>Send to $escapedName</h1>
      <p class="subtitle">Enter the 4-digit PIN shown on the receiver, choose files, then upload.</p>

      <label for="pin">Session PIN</label>
      <input id="pin" type="text" inputmode="numeric" maxlength="4" placeholder="1234" autocomplete="one-time-code" />

      <label for="files">Files</label>
      <input id="files" type="file" multiple />
      <div id="fileList"></div>

      <button id="uploadBtn" onclick="upload()">Upload files</button>

      <div id="progressWrap">
        <div class="progress-label" id="progressLabel">Preparing…</div>
        <div class="progress-track"><div class="progress-bar" id="progressBar"></div></div>
      </div>

      <div id="msg" class="info"></div>
    </div>
  </div>

  <script>
    const sessionToken = '$escapedToken';
    const chunkSize = $chunkSize;
    const chunkThreshold = $chunkThreshold;

    const pinInput = document.getElementById('pin');
    const filesInput = document.getElementById('files');
    const fileList = document.getElementById('fileList');
    const uploadBtn = document.getElementById('uploadBtn');
    const progressWrap = document.getElementById('progressWrap');
    const progressLabel = document.getElementById('progressLabel');
    const progressBar = document.getElementById('progressBar');
    const msg = document.getElementById('msg');

    filesInput.addEventListener('change', renderFileList);

    function setMessage(text, type) {
      msg.textContent = text;
      msg.className = type || 'info';
    }

    function formatSize(bytes) {
      if (bytes < 1024) return bytes + ' B';
      if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
      if (bytes < 1024 * 1024 * 1024) return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
      return (bytes / (1024 * 1024 * 1024)).toFixed(1) + ' GB';
    }

    function renderFileList() {
      fileList.innerHTML = '';
      for (const file of filesInput.files) {
        const row = document.createElement('div');
        row.className = 'file-row';
        row.innerHTML = '<span class="file-name"></span><span class="file-size"></span>';
        row.querySelector('.file-name').textContent = file.name;
        row.querySelector('.file-size').textContent = formatSize(file.size);
        fileList.appendChild(row);
      }
    }

    function setProgress(visible, label, fraction) {
      progressWrap.style.display = visible ? 'block' : 'none';
      if (label) progressLabel.textContent = label;
      progressBar.style.width = Math.round((fraction || 0) * 100) + '%';
    }

    async function uploadFile(file, pin, fileIndex, fileCount) {
      const onProgress = (sent, total, chunkIndex, totalChunks) => {
        const filePart = fileCount > 1 ? ' (' + fileIndex + '/' + fileCount + ')' : '';
        if (totalChunks > 1) {
          setProgress(true, 'Uploading ' + file.name + filePart + ' — chunk ' + (chunkIndex + 1) + '/' + totalChunks, sent / total);
        } else {
          setProgress(true, 'Uploading ' + file.name + filePart, sent / total);
        }
      };

      if (file.size <= chunkThreshold) {
        onProgress(0, file.size, 0, 1);
        const url = '/upload?token=' + sessionToken + '&pin=' + encodeURIComponent(pin) + '&filename=' + encodeURIComponent(file.name);
        const res = await fetch(url, { method: 'POST', body: file });
        if (res.status === 403) throw new Error('Wrong PIN or session expired.');
        if (res.status === 410) throw new Error('Receive session expired.');
        if (!res.ok) throw new Error('Upload failed for ' + file.name + ' (' + res.status + ').');
        onProgress(file.size, file.size, 0, 1);
        return;
      }

      const uploadId = crypto.randomUUID();
      const totalChunks = Math.ceil(file.size / chunkSize);
      for (let i = 0; i < totalChunks; i++) {
        const start = i * chunkSize;
        const end = Math.min(start + chunkSize, file.size);
        const chunk = file.slice(start, end);
        const url = '/upload/chunk?token=' + sessionToken
          + '&pin=' + encodeURIComponent(pin)
          + '&uploadId=' + encodeURIComponent(uploadId)
          + '&chunkIndex=' + i
          + '&totalChunks=' + totalChunks
          + '&filename=' + encodeURIComponent(file.name)
          + '&totalSize=' + file.size;
        const res = await fetch(url, { method: 'POST', body: chunk });
        if (res.status === 403) throw new Error('Wrong PIN or session expired.');
        if (res.status === 410) throw new Error('Receive session expired.');
        if (!res.ok) throw new Error('Chunk upload failed for ' + file.name + ' (' + res.status + ').');
        onProgress(end, file.size, i, totalChunks);
      }
    }

    async function upload() {
      const pin = pinInput.value.trim();
      if (!pin || pin.length !== 4) {
        setMessage('Enter the 4-digit PIN shown on the receiver.', 'error');
        return;
      }
      if (!filesInput.files.length) {
        setMessage('Choose at least one file.', 'error');
        return;
      }

      uploadBtn.disabled = true;
      setMessage('Starting upload…', 'info');
      setProgress(true, 'Preparing…', 0);

      try {
        const files = Array.from(filesInput.files);
        for (let i = 0; i < files.length; i++) {
          await uploadFile(files[i], pin, i + 1, files.length);
        }
        setProgress(false);
        setMessage('All files uploaded successfully.', 'success');
        filesInput.value = '';
        renderFileList();
      } catch (error) {
        setProgress(false);
        setMessage(error.message || 'Upload failed.', 'error');
      } finally {
        uploadBtn.disabled = false;
      }
    }
  </script>
</body>
</html>
''';
}

String _escapeHtml(String value) {
  return value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}
