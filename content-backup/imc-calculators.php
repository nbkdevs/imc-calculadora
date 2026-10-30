<?php
/**
 * Plugin Name: IMC Calculadora - Calculator Shortcodes
 * Description: Registers the calculator widget shortcodes used across IMC Calculadora pages. Markup only; styles are sitewide (Head & Footer Code), logic is per-page (Head & Footer Code).
 * Version: 1.0.0
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

add_shortcode( 'imc_calculadora_adultos', function () {
	ob_start();
	?>
<div class="imc-calc" id="imc-calc-adultos">
  <div class="imc-calc__unit-toggle" role="tablist" aria-label="Unidades">
    <button type="button" class="imc-calc__unit-btn is-active" data-unit="metric" role="tab" aria-selected="true">kg / cm</button>
    <button type="button" class="imc-calc__unit-btn" data-unit="imperial" role="tab" aria-selected="false">lb / ft-in</button>
  </div>
  <div class="imc-calc__fields">
    <div class="imc-calc__field imc-calc__field--metric">
      <label for="imc-peso-kg">Peso (kg)</label>
      <input type="number" id="imc-peso-kg" inputmode="decimal" step="0.1" min="1" placeholder="70">
    </div>
    <div class="imc-calc__field imc-calc__field--metric">
      <label for="imc-estatura-cm">Estatura (cm)</label>
      <input type="number" id="imc-estatura-cm" inputmode="decimal" step="0.1" min="30" placeholder="170">
    </div>
    <div class="imc-calc__field imc-calc__field--imperial" hidden>
      <label for="imc-peso-lb">Peso (lb)</label>
      <input type="number" id="imc-peso-lb" inputmode="decimal" step="0.1" min="1" placeholder="154">
    </div>
    <div class="imc-calc__field imc-calc__field--imperial" hidden>
      <label for="imc-estatura-ft">Estatura</label>
      <div class="imc-calc__ftin">
        <input type="number" id="imc-estatura-ft" inputmode="numeric" min="0" placeholder="5" aria-label="Pies">
        <span>pies</span>
        <input type="number" id="imc-estatura-in" inputmode="decimal" min="0" max="11.9" placeholder="7" aria-label="Pulgadas">
        <span>pulgadas</span>
      </div>
    </div>
    <div class="imc-calc__field">
      <label for="imc-sexo">Sexo (opcional)</label>
      <select id="imc-sexo">
        <option value="">Prefiero no decir</option>
        <option value="mujer">Mujer</option>
        <option value="hombre">Hombre</option>
      </select>
    </div>
  </div>
  <button type="button" class="imc-calc__submit" id="imc-calc-submit">Calcular</button>
  <div class="imc-calc__result" id="imc-calc-result" hidden aria-live="polite">
    <div class="imc-calc__result-number" id="imc-calc-number">0.0</div>
    <div class="imc-calc__result-category" id="imc-calc-category">Peso normal</div>
    <div class="imc-calc__result-message" id="imc-calc-message"></div>
  </div>
  <p class="imc-calc__error" id="imc-calc-error" hidden>Escribe un peso y una estatura válidos.</p>
</div>
	<?php
	return ob_get_clean();
} );

add_shortcode( 'imc_calculadora_ninos', function () {
	ob_start();
	?>
<div class="imc-calc" id="imc-calc-ninos">
  <div class="imc-calc__unit-toggle" role="tablist" aria-label="Unidades">
    <button type="button" class="imc-calc__unit-btn is-active" data-unit="metric" role="tab" aria-selected="true">kg / cm</button>
    <button type="button" class="imc-calc__unit-btn" data-unit="imperial" role="tab" aria-selected="false">lb / ft-in</button>
  </div>
  <div class="imc-calc__fields">
    <div class="imc-calc__field">
      <label for="imc-n-edad-anos">Edad (años)</label>
      <input type="number" id="imc-n-edad-anos" inputmode="numeric" min="2" max="19" step="1" placeholder="8">
    </div>
    <div class="imc-calc__field">
      <label for="imc-n-edad-meses">Edad (meses adicionales)</label>
      <input type="number" id="imc-n-edad-meses" inputmode="numeric" min="0" max="11" step="1" placeholder="0">
    </div>
    <div class="imc-calc__field imc-calc__field--full">
      <label for="imc-n-sexo">Sexo (obligatorio)</label>
      <select id="imc-n-sexo" required>
        <option value="">Selecciona una opción</option>
        <option value="nina">Niña</option>
        <option value="nino">Niño</option>
      </select>
    </div>
    <div class="imc-calc__field imc-calc__field--metric">
      <label for="imc-n-peso-kg">Peso (kg)</label>
      <input type="number" id="imc-n-peso-kg" inputmode="decimal" step="0.1" min="1" placeholder="28">
    </div>
    <div class="imc-calc__field imc-calc__field--metric">
      <label for="imc-n-estatura-cm">Estatura (cm)</label>
      <input type="number" id="imc-n-estatura-cm" inputmode="decimal" step="0.1" min="30" placeholder="128">
    </div>
    <div class="imc-calc__field imc-calc__field--imperial" hidden>
      <label for="imc-n-peso-lb">Peso (lb)</label>
      <input type="number" id="imc-n-peso-lb" inputmode="decimal" step="0.1" min="1" placeholder="62">
    </div>
    <div class="imc-calc__field imc-calc__field--imperial" hidden>
      <label for="imc-n-estatura-ft">Estatura</label>
      <div class="imc-calc__ftin">
        <input type="number" id="imc-n-estatura-ft" inputmode="numeric" min="0" placeholder="4" aria-label="Pies">
        <span>pies</span>
        <input type="number" id="imc-n-estatura-in" inputmode="decimal" min="0" max="11.9" placeholder="2" aria-label="Pulgadas">
        <span>pulgadas</span>
      </div>
    </div>
  </div>
  <button type="button" class="imc-calc__submit" id="imc-n-submit">Calcular</button>
  <div class="imc-calc__result" id="imc-n-result" hidden aria-live="polite">
    <div class="imc-calc__result-number" id="imc-n-number">0.0</div>
    <div class="imc-calc__result-sub">IMC calculado</div>
    <div class="imc-calc__result-category" id="imc-n-category">Percentil</div>
    <div class="imc-calc__percentile-bar" aria-hidden="true">
      <div class="imc-calc__percentile-track">
        <div class="imc-calc__percentile-marker" id="imc-n-marker"></div>
      </div>
      <div class="imc-calc__percentile-scale">
        <span>P5</span><span>P50</span><span>P85</span><span>P95</span>
      </div>
    </div>
    <div class="imc-calc__result-message" id="imc-n-message"></div>
  </div>
  <p class="imc-calc__error" id="imc-n-error" hidden>Revisa los datos: edad (2 a 19 años), sexo, peso y estatura son obligatorios.</p>
  <p class="imc-calc__disclaimer">Esta calculadora es una herramienta de referencia y no reemplaza una evaluación médica. Consulta al pediatra ante cualquier duda.</p>
</div>
	<?php
	return ob_get_clean();
} );

add_shortcode( 'imc_calculadora_peso_ideal', function () {
	ob_start();
	?>
<div class="imc-calc" id="imc-calc-peso-ideal">
  <div class="imc-calc__unit-toggle" role="tablist" aria-label="Unidades">
    <button type="button" class="imc-calc__unit-btn is-active" data-unit="metric" role="tab" aria-selected="true">cm</button>
    <button type="button" class="imc-calc__unit-btn" data-unit="imperial" role="tab" aria-selected="false">ft-in</button>
  </div>
  <div class="imc-calc__fields">
    <div class="imc-calc__field imc-calc__field--metric">
      <label for="imc-p-estatura-cm">Estatura (cm)</label>
      <input type="number" id="imc-p-estatura-cm" inputmode="decimal" step="0.1" min="30" placeholder="170">
    </div>
    <div class="imc-calc__field imc-calc__field--imperial" hidden>
      <label for="imc-p-estatura-ft">Estatura</label>
      <div class="imc-calc__ftin">
        <input type="number" id="imc-p-estatura-ft" inputmode="numeric" min="0" placeholder="5" aria-label="Pies">
        <span>pies</span>
        <input type="number" id="imc-p-estatura-in" inputmode="decimal" min="0" max="11.9" placeholder="7" aria-label="Pulgadas">
        <span>pulgadas</span>
      </div>
    </div>
    <div class="imc-calc__field">
      <label for="imc-p-sexo">Sexo (opcional)</label>
      <select id="imc-p-sexo">
        <option value="">Prefiero no decir</option>
        <option value="mujer">Mujer</option>
        <option value="hombre">Hombre</option>
      </select>
    </div>
  </div>
  <button type="button" class="imc-calc__submit" id="imc-p-submit">Calcular</button>
  <div class="imc-calc__result" id="imc-p-result" hidden aria-live="polite">
    <div class="imc-calc__result-number" id="imc-p-number-kg">0.0 - 0.0 kg</div>
    <div class="imc-calc__result-sub" id="imc-p-number-lb">0.0 - 0.0 lb</div>
    <div class="imc-calc__result-message">Rango de peso normal (IMC 18.5 a 24.9) para tu estatura.</div>
  </div>
  <p class="imc-calc__error" id="imc-p-error" hidden>Escribe una estatura válida.</p>
</div>
	<?php
	return ob_get_clean();
} );

add_shortcode( 'imc_calculadora_embarazo', function () {
	ob_start();
	?>
<div class="imc-calc" id="imc-calc-embarazo">
  <div class="imc-calc__unit-toggle" role="tablist" aria-label="Unidades">
    <button type="button" class="imc-calc__unit-btn is-active" data-unit="metric" role="tab" aria-selected="true">kg / cm</button>
    <button type="button" class="imc-calc__unit-btn" data-unit="imperial" role="tab" aria-selected="false">lb / ft-in</button>
  </div>
  <div class="imc-calc__fields">
    <div class="imc-calc__field imc-calc__field--metric">
      <label for="imc-e-peso-kg">Peso antes del embarazo (kg)</label>
      <input type="number" id="imc-e-peso-kg" inputmode="decimal" step="0.1" min="1" placeholder="62">
    </div>
    <div class="imc-calc__field imc-calc__field--metric">
      <label for="imc-e-estatura-cm">Estatura (cm)</label>
      <input type="number" id="imc-e-estatura-cm" inputmode="decimal" step="0.1" min="30" placeholder="165">
    </div>
    <div class="imc-calc__field imc-calc__field--imperial" hidden>
      <label for="imc-e-peso-lb">Peso antes del embarazo (lb)</label>
      <input type="number" id="imc-e-peso-lb" inputmode="decimal" step="0.1" min="1" placeholder="137">
    </div>
    <div class="imc-calc__field imc-calc__field--imperial" hidden>
      <label for="imc-e-estatura-ft">Estatura</label>
      <div class="imc-calc__ftin">
        <input type="number" id="imc-e-estatura-ft" inputmode="numeric" min="0" placeholder="5" aria-label="Pies">
        <span>pies</span>
        <input type="number" id="imc-e-estatura-in" inputmode="decimal" min="0" max="11.9" placeholder="5" aria-label="Pulgadas">
        <span>pulgadas</span>
      </div>
    </div>
    <div class="imc-calc__field">
      <label for="imc-e-semana">Semana de embarazo</label>
      <input type="number" id="imc-e-semana" inputmode="numeric" min="1" max="42" step="1" placeholder="24">
    </div>
    <div class="imc-calc__field">
      <label for="imc-e-peso-actual">Peso actual (opcional, misma unidad)</label>
      <input type="number" id="imc-e-peso-actual" inputmode="decimal" step="0.1" min="1" placeholder="70">
    </div>
  </div>
  <button type="button" class="imc-calc__submit" id="imc-e-submit">Calcular</button>
  <div class="imc-calc__result" id="imc-e-result" hidden aria-live="polite">
    <div class="imc-calc__result-category" id="imc-e-category">Categoría</div>
    <div class="imc-calc__result-message" id="imc-e-message"></div>
    <div class="imc-calc__result-message" id="imc-e-progress"></div>
  </div>
  <p class="imc-calc__error" id="imc-e-error" hidden>Escribe un peso, una estatura y una semana de embarazo válidos (1 a 42).</p>
  <p class="imc-calc__disclaimer">Calculadora para un embarazo único, con fines informativos. No reemplaza el seguimiento de tu médico u obstetra. Si esperas gemelos o más, consulta a tu médico: los rangos son distintos.</p>
</div>
	<?php
	return ob_get_clean();
} );
