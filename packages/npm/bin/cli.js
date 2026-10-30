#!/usr/bin/env node
'use strict';
const imc = require('../lib/index.js');

const HELP = `imc-calculadora: adult BMI (IMC) with WHO classes

Usage:
  imc-calculadora <peso-kg> <altura-cm|m> [--en] [--json]
  imc-calculadora --lb <peso-lb> --in <altura-in> [--en] [--json]
  imc-calculadora --rango <altura-cm|m>          healthy-weight range

Examples:
  imc-calculadora 82 175          -> IMC 26,8 Sobrepeso
  imc-calculadora 70,5 1,68 --en
  imc-calculadora --lb 154 --in 69
  imc-calculadora --rango 168     -> 52,2 - 70,3 kg`;

function main(argv) {
  const args = argv.slice(2);
  const flag = (f) => { const i = args.indexOf(f); if (i < 0) return false; args.splice(i, 1); return true; };
  const opt = (f) => { const i = args.indexOf(f); if (i < 0) return undefined; const v = args[i + 1]; args.splice(i, 2); return v; };
  if (flag('-h') || flag('--help') || args.length === 0) { console.log(HELP); return 0; }
  const en = flag('--en');
  const json = flag('--json');
  const language = en ? 'en' : 'es';
  const fmt = (n) => (en ? n.toFixed(1) : n.toFixed(1).replace('.', ','));
  try {
    const rango = opt('--rango');
    if (rango !== undefined) {
      const r = imc.healthyRange(rango);
      if (json) console.log(JSON.stringify(r));
      else console.log(`${en ? 'Healthy weight' : 'Peso saludable'}: ${fmt(r.minKg)} - ${fmt(r.maxKg)} kg`);
      return 0;
    }
    const lb = opt('--lb');
    const inch = opt('--in');
    const res = lb !== undefined || inch !== undefined
      ? imc.calculate({ weightLb: lb, heightIn: inch, lang: language })
      : imc.calculate({ weightKg: args[0], heightCm: args[1], lang: language });
    if (json) { console.log(JSON.stringify(res, null, 2)); return 0; }
    console.log(`${en ? 'BMI' : 'IMC'} ${fmt(res.bmi)}: ${res.label}`);
    console.log(res.message);
    console.log(`${en ? 'Healthy weight' : 'Peso saludable'}: ${fmt(res.healthyRange.minKg)} - ${fmt(res.healthyRange.maxKg)} kg`);
    console.log(res.disclaimer);
    return 0;
  } catch (e) {
    console.error(`error: ${e.message}\n\n${HELP}`);
    return 2;
  }
}

process.exitCode = main(process.argv);
