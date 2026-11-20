export async function api(path, options = {}) {
  const response = await fetch(path, {
    method: options.method ?? "GET",
    headers: options.body ? { "Content-Type": "application/json" } : undefined,
    body: options.body,
  });
  if (response.status === 204) {
    return null;
  }
  const text = await response.text();
  let body = null;
  if (text) {
    try {
      body = JSON.parse(text);
    } catch {
      body = { message: text };
    }
  }
  if (!response.ok) {
    const error = new Error(body?.detail || body?.message || body?.error
      || `Запрос не выполнен (HTTP ${response.status})`);
    error.status = response.status;
    if (response.status === 401 && options.notifyUnauthorized !== false) {
      window.dispatchEvent(new CustomEvent("app:session-expired"));
    }
    throw error;
  }
  return body;
}
