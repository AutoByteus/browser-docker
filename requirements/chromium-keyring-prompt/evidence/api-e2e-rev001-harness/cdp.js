// Minimal host-side DevTools client for C11 (API-REV-001, temporary).
// Usage: node cdp.js HOSTPORT wait | nav URL TITLE | setcookie NAME VALUE | doccookie | cookies
const [hostport, cmd, ...args] = process.argv.slice(2);
const base = `http://${hostport}`;
const sleep = ms => new Promise(r => setTimeout(r, ms));
async function getJson(path) { const r = await fetch(base + path); if (!r.ok) throw new Error(`${path}: HTTP ${r.status}`); return r.json(); }
async function waitReady(limitMs = 120000) {
  const t0 = Date.now();
  for (;;) {
    try { const pages = (await getJson('/json/list')).filter(p => p.type === 'page'); if (pages.length) return pages; } catch (_) {}
    if (Date.now() - t0 > limitMs) throw new Error(`DevTools not ready at ${base} within ${limitMs} ms`);
    await sleep(1000);
  }
}
async function session() {
  const pages = await waitReady();
  const ws = new WebSocket(pages[0].webSocketDebuggerUrl);
  const pending = new Map(); let id = 0;
  ws.onmessage = ({data}) => { const m = JSON.parse(data); const p = pending.get(m.id); if (p) { pending.delete(m.id); m.error ? p.reject(new Error(JSON.stringify(m.error))) : p.resolve(m.result); } };
  await new Promise((res, rej) => { ws.onopen = res; ws.onerror = rej; });
  const send = (method, params = {}) => new Promise((resolve, reject) => { const i = ++id; pending.set(i, {resolve, reject}); ws.send(JSON.stringify({id: i, method, params})); });
  const evaluate = async expr => (await send('Runtime.evaluate', {expression: expr, returnByValue: true})).result.value;
  return {ws, send, evaluate};
}
(async () => {
  if (cmd === 'wait') { const pages = await waitReady(); console.log(`READY: ${pages.length} page target(s)`); return; }
  const s = await session();
  try {
    if (cmd === 'nav') {
      const [url, title] = args; const t0 = Date.now(); let last = null;
      await s.send('Page.navigate', {url});
      while (Date.now() - t0 < 30000) {
        try { last = JSON.parse(await s.evaluate('JSON.stringify({url: location.href, readyState: document.readyState, title: document.title})')); if (last.readyState === 'complete' && last.title === title) break; } catch (_) {}
        await sleep(500);
      }
      const ok = last && last.readyState === 'complete' && last.title === title;
      console.log(`${ok ? 'PASS' : 'FAIL'}: nav ${url} -> ${JSON.stringify(last)} in ${Date.now() - t0} ms (limit 30000)`);
      if (!ok) process.exitCode = 1;
    } else if (cmd === 'setcookie') {
      const [name, value] = args;
      const v = await s.evaluate(`document.cookie = ${JSON.stringify(`${name}=${value}; max-age=31536000; path=/`)}; document.cookie`);
      console.log(`SET: document.cookie now = ${JSON.stringify(v)}`);
    } else if (cmd === 'doccookie') {
      console.log(`DOC: location=${await s.evaluate('location.href')} document.cookie=${JSON.stringify(await s.evaluate('document.cookie'))}`);
    } else if (cmd === 'cookies') {
      const all = (await s.send('Storage.getCookies', {})).cookies.filter(c => c.name.startsWith('apie2e'));
      console.log(`COOKIES(apie2e*): ${JSON.stringify(all.map(c => ({name: c.name, value: c.value, domain: c.domain})))}`);
    } else throw new Error(`unknown command ${cmd}`);
  } finally { s.ws.close(); }
})().catch(e => { console.error(`FAIL: ${e.message}`); process.exit(1); });
