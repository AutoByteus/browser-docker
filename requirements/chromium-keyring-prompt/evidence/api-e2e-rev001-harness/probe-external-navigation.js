// C08 (API-REV-001, temporary): real https websites over the node's DevTools endpoint
// (as agent browser tools do), each within 30 s; then confirm Chromium's cookie store works
// with the built-in key (REQ-004): cookies are readable over CDP.
const http = require('http');
const getJson = (path) => new Promise((resolve, reject) => {
  http.get({host: '127.0.0.1', port: 9223, path}, (res) => {
    let body = '';
    res.on('data', c => body += c);
    res.on('end', () => { try { resolve(JSON.parse(body)); } catch (e) { reject(e); } });
  }).on('error', reject);
});
const sites = [
  {url: 'https://www.wikipedia.org/', title: t => t === 'Wikipedia'},
  {url: 'https://example.com/', title: t => t === 'Example Domain'},
  {url: 'https://github.com/autobyteus', title: t => /autobyteus/i.test(t)},
];
(async () => {
  const pages = (await getJson('/json/list')).filter(p => p.type === 'page');
  const ws = new WebSocket(pages[0].webSocketDebuggerUrl);
  const pending = new Map(); let nextId = 1;
  ws.onmessage = ({data}) => { const m = JSON.parse(data); if (m.id && pending.has(m.id)) { const {resolve, reject} = pending.get(m.id); pending.delete(m.id); m.error ? reject(new Error(JSON.stringify(m.error))) : resolve(m.result); } };
  await new Promise((resolve, reject) => { ws.onopen = resolve; ws.onerror = reject; });
  const send = (method, params = {}) => new Promise((resolve, reject) => { const id = nextId++; pending.set(id, {resolve, reject}); ws.send(JSON.stringify({id, method, params})); });
  await send('Page.enable');
  let failures = 0;
  for (const site of sites) {
    const started = Date.now();
    await send('Page.navigate', {url: site.url});
    let last = null;
    while (Date.now() - started < 30000) {
      try {
        const r = await send('Runtime.evaluate', {expression: 'JSON.stringify({url: location.href, readyState: document.readyState, title: document.title})', returnByValue: true});
        last = JSON.parse(r.result.value);
        if (last.readyState === 'complete' && site.title(last.title)) break;
      } catch (_) { /* context swap during commit */ }
      await new Promise(r => setTimeout(r, 500));
    }
    const ok = last && last.readyState === 'complete' && site.title(last.title);
    if (!ok) failures++;
    console.log(`${ok ? 'PASS' : 'FAIL'}: ${site.url} -> ${JSON.stringify(last)} in ${Date.now() - started} ms (limit 30000)`);
  }
  const cookies = (await send('Storage.getCookies', {})).cookies;
  const domains = [...new Set(cookies.map(c => c.domain))].sort();
  console.log(`INFO: Chromium cookie store holds ${cookies.length} cookies for ${JSON.stringify(domains)}`);
  if (!cookies.length) { failures++; console.log('FAIL: no cookies were stored after visiting real sites'); }
  else console.log('PASS: cookie store is initialised and readable (no keyring needed)');
  ws.close();
  process.exit(failures ? 1 : 0);
})().catch(e => { console.error(`FAIL: ${e.stack || e}`); process.exit(1); });
