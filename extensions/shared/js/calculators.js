/* IMC Calculadora — calculator logic (mirrors Flutter app) */
(function (global) {
  const COLORS = {
    bajo: "#3B7DD8",
    normal: "#0E5C52",
    sobrepeso: "#C98A1F",
    obesidad1: "#C1591F",
    obesidad2: "#A83A2A",
    obesidad3: "#7A2420",
  };

  function adultCategory(imc) {
    if (imc < 18.5) return { key: "bajo", label: "Bajo peso", color: COLORS.bajo };
    if (imc < 25) return { key: "normal", label: "Peso normal", color: COLORS.normal };
    if (imc < 30) return { key: "sobrepeso", label: "Sobrepeso", color: COLORS.sobrepeso };
    if (imc < 35) return { key: "obesidad1", label: "Obesidad grado 1", color: COLORS.obesidad1 };
    if (imc < 40) return { key: "obesidad2", label: "Obesidad grado 2", color: COLORS.obesidad2 };
    return { key: "obesidad3", label: "Obesidad grado 3 (mórbida)", color: COLORS.obesidad3 };
  }

  function adultMessage(cat, heightM, weightKg) {
    const lowerKg = 18.5 * heightM * heightM;
    const upperKg = 24.9 * heightM * heightM;
    if (cat.key === "normal") {
      return "Tu IMC está dentro del rango normal para tu estatura.";
    }
    if (cat.key === "bajo") {
      const faltan = (lowerKg - weightKg).toFixed(1);
      return `Tu IMC indica bajo peso. Te faltan ${faltan} kg para llegar al rango normal.`;
    }
    const sobran = (weightKg - upperKg).toFixed(1);
    if (cat.key === "sobrepeso") {
      return `Tu IMC indica sobrepeso. Te sobran ${sobran} kg respecto al rango normal.`;
    }
    return `Tu IMC indica ${cat.label.toLowerCase()}. Te sobran ${sobran} kg respecto al rango normal.`;
  }

  function calculateAdult(weightKg, heightM) {
    if (!(weightKg > 0) || !(heightM > 0)) return null;
    const bmi = weightKg / (heightM * heightM);
    const category = adultCategory(bmi);
    return {
      bmi,
      bmiText: bmi.toFixed(1),
      category,
      message: adultMessage(category, heightM, weightKg),
      weightKg,
      heightM,
    };
  }

  function calculateIdeal(heightM) {
    if (!(heightM > 0)) return null;
    const h2 = heightM * heightM;
    const lowerKg = 18.5 * h2;
    const upperKg = 24.9 * h2;
    const lb = (kg) => kg / 0.45359237;
    return {
      lowerKg,
      upperKg,
      heightM,
      kgText: `${lowerKg.toFixed(1)} - ${upperKg.toFixed(1)} kg`,
      lbText: `${lb(lowerKg).toFixed(1)} - ${lb(upperKg).toFixed(1)} lb`,
    };
  }

  function iomBand(bmi) {
    if (bmi < 18.5) return { minTotal: 12.5, maxTotal: 18, minWeekly: 0.44, maxWeekly: 0.58 };
    if (bmi < 25) return { minTotal: 11.5, maxTotal: 16, minWeekly: 0.35, maxWeekly: 0.5 };
    if (bmi < 30) return { minTotal: 7, maxTotal: 11.5, minWeekly: 0.23, maxWeekly: 0.33 };
    return { minTotal: 5, maxTotal: 9, minWeekly: 0.17, maxWeekly: 0.27 };
  }

  function calculatePregnancy(preWeightKg, heightM, week, currentWeightKg) {
    if (!(preWeightKg > 0) || !(heightM > 0) || week < 1 || week > 42) return null;
    const preBmi = preWeightKg / (heightM * heightM);
    const category = adultCategory(preBmi);
    const band = iomBand(preBmi);
    let recMin;
    let recMax;
    if (week <= 13) {
      const t = (week - 1) / 12;
      recMin = 0.5 * t;
      recMax = 0.5 + (2.0 - 0.5) * t;
    } else {
      const weeksAfter = week - 13;
      recMin = Math.min(Math.max(0.5 + weeksAfter * band.minWeekly, 0), band.minTotal);
      recMax = Math.min(Math.max(2.0 + weeksAfter * band.maxWeekly, 0), band.maxTotal);
    }
    const message =
      `Según tu IMC antes del embarazo (${preBmi.toFixed(1)}, ${category.label.toLowerCase()}), ` +
      `el aumento recomendado en un embarazo único es de ` +
      `${band.minTotal.toFixed(1)} a ${band.maxTotal.toFixed(1)} kg en total.`;

    let progressMessage;
    if (currentWeightKg != null && currentWeightKg > 0) {
      const gained = currentWeightKg - preWeightKg;
      progressMessage =
        `En la semana ${week} llevas ${gained.toFixed(1)} kg de aumento. ` +
        `La referencia orientativa para esta semana es ` +
        `${recMin.toFixed(1)} a ${recMax.toFixed(1)} kg. ` +
        `Habla con tu médico u obstetra si quedas fuera del rango.`;
    } else {
      progressMessage =
        `En la semana ${week}, la referencia orientativa de aumento es ` +
        `${recMin.toFixed(1)} a ${recMax.toFixed(1)} kg ` +
        `(0.5 a 2 kg en el primer trimestre; la mayor parte en el segundo y el tercero).`;
    }

    return {
      preBmi,
      category,
      totalGainMinKg: band.minTotal,
      totalGainMaxKg: band.maxTotal,
      recommendedMinAtWeek: recMin,
      recommendedMaxAtWeek: recMax,
      week,
      message,
      progressMessage,
    };
  }

  function erf(x) {
    const sign = x < 0 ? -1 : 1;
    x = Math.abs(x);
    const a1 = 0.254829592;
    const a2 = -0.284496736;
    const a3 = 1.421413741;
    const a4 = -1.453152027;
    const a5 = 1.061405429;
    const p = 0.3275911;
    const t = 1 / (1 + p * x);
    const y = 1 - (((((a5 * t + a4) * t) + a3) * t + a2) * t + a1) * t * Math.exp(-x * x);
    return sign * y;
  }

  function normalCdf(z) {
    return 0.5 * (1 + erf(z / Math.SQRT2));
  }

  function childCategory(pct) {
    if (pct < 5) return { key: "bajo", label: "Bajo peso", color: COLORS.bajo };
    if (pct < 85) return { key: "saludable", label: "Peso saludable", color: COLORS.normal };
    if (pct < 95) return { key: "sobrepeso", label: "Sobrepeso", color: COLORS.sobrepeso };
    return { key: "obesidad", label: "Obesidad", color: COLORS.obesidad2 };
  }

  function childMessage(cat) {
    switch (cat.key) {
      case "bajo":
        return "El percentil indica bajo peso para la edad y el sexo. Consulta al pediatra, sobre todo si es un cambio reciente.";
      case "saludable":
        return "El percentil está dentro del rango de peso saludable para la edad y el sexo.";
      case "sobrepeso":
        return "El percentil indica sobrepeso para la edad y el sexo. Un percentil alto de forma aislada no es un diagnóstico: habla con el pediatra.";
      default:
        return "El percentil indica obesidad para la edad y el sexo. Habla con el pediatra para una evaluación completa.";
    }
  }

  class ChildBmiCalculator {
    constructor(boys, girls) {
      this.boys = boys;
      this.girls = girls;
    }

    interpolate(rows, ageMonths) {
      if (ageMonths <= rows[0][0]) return rows[0];
      if (ageMonths >= rows[rows.length - 1][0]) return rows[rows.length - 1];
      for (let i = 0; i < rows.length - 1; i++) {
        const a = rows[i];
        const b = rows[i + 1];
        if (ageMonths >= a[0] && ageMonths <= b[0]) {
          const frac = b[0] === a[0] ? 0 : (ageMonths - a[0]) / (b[0] - a[0]);
          return a.map((v, k) => (k === 0 ? ageMonths : v + frac * (b[k] - v)));
        }
      }
      return rows[rows.length - 1];
    }

    percentile(sexKey, ageMonths, bmi) {
      const table = sexKey === "nino" ? this.boys : this.girls;
      const row = this.interpolate(table, ageMonths);
      const l = row[1];
      const m = row[2];
      const s = row[3];
      const p95 = row[4];
      const sigma = row[5];
      let pct;
      if (bmi <= p95) {
        const z = l !== 0 ? (Math.pow(bmi / m, l) - 1) / (l * s) : Math.log(bmi / m) / s;
        pct = normalCdf(z) * 100;
      } else {
        pct = 90 + 10 * normalCdf((bmi - p95) / sigma);
      }
      if (pct < 0.1) pct = 0.1;
      if (pct > 99.9) pct = 99.9;
      return pct;
    }

    calculate(years, extraMonths, sexKey, weightKg, heightM) {
      if (years < 2 || years > 19) return null;
      if (sexKey !== "nino" && sexKey !== "nina") return null;
      if (!(weightKg > 0) || !(heightM > 0)) return null;
      const ageMonths = years * 12 + extraMonths;
      const bmi = weightKg / (heightM * heightM);
      const percentile = this.percentile(sexKey, ageMonths, bmi);
      const category = childCategory(percentile);
      return {
        bmi,
        bmiText: bmi.toFixed(1),
        percentile,
        percentileText: String(Math.round(percentile)),
        category,
        message: childMessage(category),
      };
    }
  }

  let childLoader = null;
  function loadChildCalculator() {
    if (childLoader) return childLoader;
    const url =
      (typeof chrome !== "undefined" && chrome.runtime && chrome.runtime.getURL)
        ? chrome.runtime.getURL("data/cdc_bmi_lms.json")
        : "data/cdc_bmi_lms.json";
    childLoader = fetch(url)
      .then((r) => {
        if (!r.ok) throw new Error("LMS load failed");
        return r.json();
      })
      .then((json) => new ChildBmiCalculator(json.boys, json.girls));
    return childLoader;
  }

  global.ImcCalc = {
    COLORS,
    calculateAdult,
    calculateIdeal,
    calculatePregnancy,
    loadChildCalculator,
    adultCategory,
  };
})(typeof globalThis !== "undefined" ? globalThis : window);
