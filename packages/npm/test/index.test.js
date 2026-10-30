'use strict';
const test = require('node:test');
const assert = require('node:assert');
const imc = require('../lib/index.js');

test('82 kg / 175 cm is 26.8 overweight', () => {
  const r = imc.calculate({ weightKg: 82, heightCm: 175 });
  assert.strictEqual(r.bmi, 26.8);
  assert.strictEqual(r.key, 'sobrepeso');
  assert.strictEqual(r.label, 'Sobrepeso');
  assert.strictEqual(r.diffKg, 5.7);
});

test('rounds to 1 decimal before classifying', () => {
  assert.strictEqual(imc.classify(24.96).key, 'sobrepeso');
  assert.strictEqual(imc.classify(24.94).key, 'normal');
  assert.strictEqual(imc.classify(18.46).key, 'normal');
  assert.strictEqual(imc.classify(29.96).key, 'obesidad_1');
});

test('WHO classes incl. thinness subclasses', () => {
  const k = (w) => imc.calculate({ weightKg: w, heightCm: 170 }).key;
  assert.strictEqual(k(45), 'delgadez_severa');
  assert.strictEqual(k(48), 'delgadez_moderada');
  assert.strictEqual(k(50), 'delgadez_leve');
  assert.strictEqual(k(70), 'normal');
  assert.strictEqual(k(100), 'obesidad_1');
  assert.strictEqual(k(110), 'obesidad_2');
  assert.strictEqual(k(120), 'obesidad_3');
});

test('healthy range and underweight difference', () => {
  assert.deepStrictEqual(imc.healthyRange(168), { minKg: 52.2, maxKg: 70.3 });
  const r = imc.calculate({ weightKg: 50, heightCm: 170, lang: 'en' });
  assert.strictEqual(r.diffKg, 3.5);
  assert.match(r.message, /3\.5 kg below/);
});

test('imperial, comma decimals and metres', () => {
  assert.strictEqual(imc.round1(imc.bmiImperial(154, 69)), 22.7);
  assert.strictEqual(imc.calculate({ weightKg: '70,5', heightCm: '1,68' }).bmi, 25);
  assert.strictEqual(imc.parseNumber('70,5'), 70.5);
  assert.throws(() => imc.calculate({ weightKg: 0, heightCm: 170 }));
  assert.throws(() => imc.parseNumber('abc'));
});
