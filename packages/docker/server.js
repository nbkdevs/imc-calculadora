'use strict';
// Tiny BMI (IMC) API + bilingual calculator page. No dependencies.
const http = require('node:http');
const fs = require('node:fs');
const path = require('node:path');
let imc;
try { imc = require('imc-calculadora'); } catch { imc = require('../npm/lib'); } // repo checkout fallback

const PAGE = fs.readFileSync(path.join(__dirname, 'public', 'index.html'));
const HELP = 'Try /api/imc?peso=82&altura=175, /api/imc?lb=154&in=69&lang=en or /api/rango?altura=168';

function handle(req, res) {
  const url = new URL(req.url, 'http://x');
  const q = (k) => url.searchParams.get(k);
  const send = (code, body) => {
    res.writeHead(code, { 'content-type': 'application/json; charset=utf-8', 'access-control-allow-origin': '*' });
    res.end(JSON.stringify(body, null, 2));
  };
  try {
    if (url.pathname === '/healthz') return send(200, { ok: true });
    if (url.pathname === '/' || url.pathname === '/index.html') {
      res.writeHead(200, { 'content-type': 'text/html; charset=utf-8' });
      return res.end(PAGE);
    }
    const lang = q('lang') === 'en' ? 'en' : 'es';
    if (url.pathname === '/api/imc' || url.pathname === '/api/bmi') {
      if (q('lb') !== null || q('in') !== null) return send(200, imc.calculate({ weightLb: q('lb'), heightIn: q('in'), lang }));
      if (q('peso') === null || q('altura') === null) return send(400, { error: HELP });
      return send(200, imc.calculate({ weightKg: q('peso'), heightCm: q('altura'), lang }));
    }
    if (url.pathname === '/api/rango' || url.pathname === '/api/range') {
      if (q('altura') === null) return send(400, { error: HELP });
      return send(200, imc.healthyRange(q('altura')));
    }
    if (url.pathname === '/api/clases' || url.pathname === '/api/classes') {
      return send(200, imc.CLASSES.map((c) => ({ ...c, upper: c.upper === Infinity ? null : c.upper })));
    }
    return send(404, { error: `Not found. ${HELP}` });
  } catch (e) { return send(400, { error: e.message }); }
}

if (require.main === module) {
  const port = Number(process.env.PORT) || 8080;
  http.createServer(handle).listen(port, () => console.log(`imc-calculadora listening on :${port}`));
}

module.exports = { handle };
