'use strict';
/**
 * imc-calculadora: adult BMI (IMC) with WHO classes, healthy-weight range,
 * metric/imperial input and Spanish/English labels. Zero dependencies.
 * The BMI is rounded to 1 decimal BEFORE it is classified, so 24.96 -> 25.0 -> overweight.
 */

const LB_KG = 0.45359237;
const IN_CM = 2.54;

// [key, upper bound (exclusive, on the 1-decimal BMI), es, en, WHO group]
const CLASSES = [
  ['delgadez_severa', 16, 'Delgadez severa', 'Severe thinness', 'bajo'],
  ['delgadez_moderada', 17, 'Delgadez moderada', 'Moderate thinness', 'bajo'],
  ['delgadez_leve', 18.5, 'Delgadez leve', 'Mild thinness', 'bajo'],
  ['normal', 25, 'Peso normal', 'Normal weight', 'normal'],
  ['sobrepeso', 30, 'Sobrepeso', 'Overweight', 'sobrepeso'],
  ['obesidad_1', 35, 'Obesidad grado I', 'Obesity class I', 'obesidad'],
  ['obesidad_2', 40, 'Obesidad grado II', 'Obesity class II', 'obesidad'],
  ['obesidad_3', Infinity, 'Obesidad grado III', 'Obesity class III', 'obesidad'],
];

const DISCLAIMER = {
  es: 'El IMC es una referencia general para adultos y no sustituye el consejo de un profesional de la salud.',
  en: 'BMI is a general guide for adults and is not medical advice.',
};

function round1(x) {
  return Math.floor(x * 10 + 0.5 + 1e-9) / 10;
}

/** Parse "70,5", "70.5" or 70.5 into a number. Throws on anything else. */
function parseNumber(v) {
  if (typeof v === 'number') {
    if (!Number.isFinite(v)) throw new RangeError('not a finite number');
    return v;
  }
  const s = String(v).trim().replace(',', '.');
  if (!/^[+]?\d+(\.\d+)?$|^[+]?\.\d+$/.test(s)) throw new RangeError(`invalid number: ${v}`);
  return Number(s);
}

/** Accept height in cm, or in metres when the value is below 3 (1,75 -> 175). */
function heightCm(h) {
  const n = parseNumber(h);
  return n < 3 ? n * 100 : n;
}

function lang(l) {
  return l === 'en' ? 'en' : 'es';
}

/** WHO class for a BMI. The value is rounded to 1 decimal first. */
function classify(bmiValue, language = 'es') {
  const b = round1(parseNumber(bmiValue));
  const c = CLASSES.find(([, upper]) => b < upper);
  return { key: c[0], label: lang(language) === 'en' ? c[3] : c[2], group: c[4], bmi: b };
}

/** Raw BMI from kg and cm (not rounded). */
function bmi(weightKg, heightCmValue) {
  const w = parseNumber(weightKg);
  const h = heightCm(heightCmValue) / 100;
  if (!(w > 0) || !(h > 0)) throw new RangeError('weight and height must be greater than 0');
  return w / (h * h);
}

/** Raw BMI from pounds and inches: 703 * lb / in^2. */
function bmiImperial(weightLb, heightIn) {
  const w = parseNumber(weightLb);
  const h = parseNumber(heightIn);
  if (!(w > 0) || !(h > 0)) throw new RangeError('weight and height must be greater than 0');
  return (703 * w) / (h * h);
}

/** Healthy-weight range (BMI 18.5 to 24.9) in kg for a height, 1 decimal. */
function healthyRange(heightCmValue) {
  const h = heightCm(heightCmValue) / 100;
  if (!(h > 0)) throw new RangeError('height must be greater than 0');
  return { minKg: round1(18.5 * h * h), maxKg: round1(24.9 * h * h) };
}

function message(cls, diffKg, language) {
  const d = lang(language) === 'en' ? diffKg.toFixed(1) : diffKg.toFixed(1).replace('.', ',');
  if (lang(language) === 'en') {
    if (cls.group === 'normal') return 'Your BMI is in the normal range for your height.';
    if (cls.group === 'bajo') return `Your BMI shows ${cls.label.toLowerCase()}. You are ${d} kg below the normal range.`;
    return `Your BMI shows ${cls.label.toLowerCase()}. You are ${d} kg above the normal range.`;
  }
  if (cls.group === 'normal') return 'Tu IMC está dentro del rango normal para tu estatura.';
  if (cls.group === 'bajo') return `Tu IMC indica ${cls.label.toLowerCase()}. Te faltan ${d} kg para llegar al rango normal.`;
  return `Tu IMC indica ${cls.label.toLowerCase()}. Te sobran ${d} kg respecto al rango normal.`;
}

/**
 * Full result. opts: { weightKg, heightCm } or { weightLb, heightIn }, plus lang 'es' | 'en'.
 */
function calculate(opts = {}) {
  const language = lang(opts.lang);
  let raw, kg, cm;
  if (opts.weightLb != null || opts.heightIn != null) {
    raw = bmiImperial(opts.weightLb, opts.heightIn);
    kg = parseNumber(opts.weightLb) * LB_KG;
    cm = parseNumber(opts.heightIn) * IN_CM;
  } else {
    raw = bmi(opts.weightKg, opts.heightCm);
    kg = parseNumber(opts.weightKg);
    cm = heightCm(opts.heightCm);
  }
  const cls = classify(raw, language);
  const range = healthyRange(cm);
  let diffKg = 0;
  if (cls.group === 'bajo') diffKg = round1(Math.max(0, range.minKg - kg));
  else if (cls.group !== 'normal') diffKg = round1(Math.max(0, kg - range.maxKg));
  return {
    bmi: cls.bmi,
    key: cls.key,
    label: cls.label,
    group: cls.group,
    healthyRange: range,
    diffKg,
    message: message(cls, diffKg, language),
    disclaimer: DISCLAIMER[language],
  };
}

module.exports = {
  calculate, classify, bmi, bmiImperial, healthyRange, parseNumber, heightCm, round1,
  CLASSES: CLASSES.map(([key, upper, es, en, group]) => ({ key, upper, es, en, group })),
  DISCLAIMER, LB_KG, IN_CM,
};
