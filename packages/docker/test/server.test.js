'use strict';
const test = require('node:test');
const assert = require('node:assert');
const http = require('node:http');
const { handle } = require('../server');

function get(server, p) {
  return new Promise((resolve) => http.get({ port: server.address().port, path: p }, (res) => {
    let b = ''; res.on('data', (c) => (b += c)); res.on('end', () => resolve({ code: res.statusCode, body: b }));
  }));
}

test('api', async () => {
  const s = http.createServer(handle).listen(0);
  const r = await get(s, '/api/imc?peso=82&altura=175');
  assert.strictEqual(r.code, 200);
  assert.strictEqual(JSON.parse(r.body).bmi, 26.8);
  assert.strictEqual(JSON.parse((await get(s, '/api/imc?lb=154&in=69&lang=en')).body).label, 'Normal weight');
  assert.deepStrictEqual(JSON.parse((await get(s, '/api/rango?altura=168')).body), { minKg: 52.2, maxKg: 70.3 });
  assert.strictEqual(JSON.parse((await get(s, '/api/clases')).body).length, 8);
  assert.strictEqual((await get(s, '/healthz')).code, 200);
  assert.strictEqual((await get(s, '/')).code, 200);
  assert.strictEqual((await get(s, '/api/imc?peso=0&altura=170')).code, 400);
  s.close();
});
