(function () {
  const toastEl = document.getElementById("toast");

  function toast(msg) {
    toastEl.textContent = msg;
    toastEl.classList.add("show");
    setTimeout(() => toastEl.classList.remove("show"), 1600);
  }

  function showResult(el, html) {
    el.innerHTML = html;
    el.classList.add("show");
  }

  function resultShell(valueHtml, badge, message, shareText, type, summary) {
    return `
      <div class="value">${valueHtml}</div>
      ${badge ? `<span class="badge" style="background:${badge.color}">${badge.label}</span>` : ""}
      <p class="msg">${message}</p>
      <div class="actions">
        <button type="button" class="ghost btn-save" data-type="${type}" data-summary="${encodeURIComponent(summary)}">Guardar</button>
        <button type="button" class="ghost btn-copy" data-text="${encodeURIComponent(shareText)}">Copiar</button>
      </div>
    `;
  }

  document.querySelectorAll(".tabs button").forEach((btn) => {
    btn.addEventListener("click", () => {
      document.querySelectorAll(".tabs button").forEach((b) => b.classList.remove("active"));
      document.querySelectorAll(".panel").forEach((p) => p.classList.remove("active"));
      btn.classList.add("active");
      document.getElementById(`panel-${btn.dataset.tab}`).classList.add("active");
      if (btn.dataset.tab === "history") renderHistory();
    });
  });

  document.getElementById("form-adult").addEventListener("submit", async (e) => {
    e.preventDefault();
    const fd = new FormData(e.target);
    const weightKg = Number(fd.get("weight"));
    const heightM = Number(fd.get("height")) / 100;
    const r = ImcCalc.calculateAdult(weightKg, heightM);
    if (!r) return;
    const share =
      `IMC Calculadora — Adultos\nIMC: ${r.bmiText}\nCategoría: ${r.category.label}\n${r.message}\nhttps://imccalculadora.app/`;
    const summary = `Adultos · IMC ${r.bmiText} · ${r.category.label}`;
    showResult(
      document.getElementById("result-adult"),
      resultShell(r.bmiText, r.category, r.message, share, "adult", summary)
    );
  });

  document.getElementById("form-child").addEventListener("submit", async (e) => {
    e.preventDefault();
    const fd = new FormData(e.target);
    const calc = await ImcCalc.loadChildCalculator();
    const r = calc.calculate(
      Number(fd.get("years")),
      Number(fd.get("months") || 0),
      String(fd.get("sex")),
      Number(fd.get("weight")),
      Number(fd.get("height")) / 100
    );
    if (!r) {
      toast("Revisa edad (2–19), sexo, peso y estatura.");
      return;
    }
    const share =
      `IMC Calculadora — Niños\nIMC: ${r.bmiText}\nPercentil: ${r.percentileText}\n` +
      `Categoría: ${r.category.label}\n${r.message}\nhttps://imccalculadora.app/`;
    const summary = `Niños · P${r.percentileText} · IMC ${r.bmiText} · ${r.category.label}`;
    showResult(
      document.getElementById("result-child"),
      resultShell(
        `${r.bmiText} <span style="font-size:14px;color:#3b5b6d">· P${r.percentileText}</span>`,
        r.category,
        r.message,
        share,
        "child",
        summary
      )
    );
  });

  document.getElementById("form-ideal").addEventListener("submit", (e) => {
    e.preventDefault();
    const fd = new FormData(e.target);
    const r = ImcCalc.calculateIdeal(Number(fd.get("height")) / 100);
    if (!r) return;
    const share =
      `IMC Calculadora — Peso ideal\nRango: ${r.kgText} (${r.lbText})\nhttps://imccalculadora.app/`;
    const summary = `Peso ideal · ${r.kgText}`;
    showResult(
      document.getElementById("result-ideal"),
      resultShell(r.kgText, null, `Equivalente aproximado: ${r.lbText}. Rango OMS IMC 18.5–24.9.`, share, "ideal", summary)
    );
  });

  document.getElementById("form-pregnancy").addEventListener("submit", (e) => {
    e.preventDefault();
    const fd = new FormData(e.target);
    const current = fd.get("currentWeight");
    const r = ImcCalc.calculatePregnancy(
      Number(fd.get("preWeight")),
      Number(fd.get("height")) / 100,
      Number(fd.get("week")),
      current ? Number(current) : null
    );
    if (!r) {
      toast("Revisa peso, estatura y semana (1–42).");
      return;
    }
    const range = `${r.totalGainMinKg.toFixed(1)}–${r.totalGainMaxKg.toFixed(1)} kg`;
    const share =
      `IMC Calculadora — Embarazo\nIMC previo: ${r.preBmi.toFixed(1)} (${r.category.label})\n` +
      `Aumento total: ${range}\n${r.message}\n${r.progressMessage}\nhttps://imccalculadora.app/`;
    const summary = `Embarazo · sem ${r.week} · ${range}`;
    showResult(
      document.getElementById("result-pregnancy"),
      resultShell(
        range,
        r.category,
        `${r.message}<br><br>${r.progressMessage}`,
        share,
        "pregnancy",
        summary
      )
    );
  });

  document.body.addEventListener("click", async (e) => {
    const copyBtn = e.target.closest(".btn-copy");
    if (copyBtn) {
      const text = decodeURIComponent(copyBtn.dataset.text || "");
      try {
        await navigator.clipboard.writeText(text);
        toast("Copiado");
      } catch {
        toast("No se pudo copiar");
      }
      return;
    }
    const saveBtn = e.target.closest(".btn-save");
    if (saveBtn) {
      await ImcHistory.add({
        type: saveBtn.dataset.type,
        summary: decodeURIComponent(saveBtn.dataset.summary || ""),
      });
      toast("Guardado en historial");
    }
  });

  async function renderHistory() {
    const list = document.getElementById("history-list");
    const empty = document.getElementById("history-empty");
    const entries = await ImcHistory.load();
    list.innerHTML = "";
    if (!entries.length) {
      empty.style.display = "block";
      return;
    }
    empty.style.display = "none";
    entries.forEach((item) => {
      const li = document.createElement("li");
      const when = new Date(item.at);
      li.innerHTML = `<strong>${item.summary}</strong><div class="meta">${when.toLocaleString()}</div>`;
      list.appendChild(li);
    });
  }

  document.getElementById("clear-history").addEventListener("click", async () => {
    await ImcHistory.clear();
    renderHistory();
    toast("Historial borrado");
  });
})();
