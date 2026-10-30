# frozen_string_literal: true

require_relative "imc_calculadora/version"

# Adult BMI (IMC) with WHO classes, healthy-weight range, metric/imperial input
# and Spanish/English labels. The BMI is rounded to 1 decimal BEFORE it is
# classified (24.96 -> 25.0 -> overweight).
module ImcCalculadora
  LB_KG = 0.45359237
  IN_CM = 2.54

  ImcClass = Struct.new(:key, :upper, :es, :en, :group)
  Category = Struct.new(:key, :label, :group, :bmi)
  Result = Struct.new(:bmi, :key, :label, :group, :min_kg, :max_kg, :diff_kg, :message, :disclaimer, keyword_init: true)

  CLASSES = [
    ImcClass.new("delgadez_severa", 16.0, "Delgadez severa", "Severe thinness", "bajo"),
    ImcClass.new("delgadez_moderada", 17.0, "Delgadez moderada", "Moderate thinness", "bajo"),
    ImcClass.new("delgadez_leve", 18.5, "Delgadez leve", "Mild thinness", "bajo"),
    ImcClass.new("normal", 25.0, "Peso normal", "Normal weight", "normal"),
    ImcClass.new("sobrepeso", 30.0, "Sobrepeso", "Overweight", "sobrepeso"),
    ImcClass.new("obesidad_1", 35.0, "Obesidad grado I", "Obesity class I", "obesidad"),
    ImcClass.new("obesidad_2", 40.0, "Obesidad grado II", "Obesity class II", "obesidad"),
    ImcClass.new("obesidad_3", Float::INFINITY, "Obesidad grado III", "Obesity class III", "obesidad")
  ].freeze

  DISCLAIMER = {
    "es" => "El IMC es una referencia general para adultos y no sustituye el consejo de un profesional de la salud.",
    "en" => "BMI is a general guide for adults and is not medical advice."
  }.freeze

  NUM = /\A\+?(\d+(\.\d+)?|\.\d+)\z/

  module_function

  # Round half up to 1 decimal.
  def round1(x)
    ((x * 10) + 0.5 + 1e-9).floor / 10.0
  end

  # Parse "70,5", "70.5" or a Numeric. Raises ArgumentError otherwise.
  def parse_number(v)
    return v.to_f if v.is_a?(Numeric) && v.to_f.finite?

    s = v.to_s.strip.sub(",", ".")
    raise ArgumentError, "invalid number: #{v}" unless NUM.match?(s)

    s.to_f
  end

  # Height in cm; values below 3 are taken as metres (1,75 -> 175).
  def height_cm(h)
    n = parse_number(h)
    n < 3 ? n * 100 : n
  end

  def lang_of(lang)
    lang.to_s == "en" ? "en" : "es"
  end

  # WHO class for a BMI; the value is rounded to 1 decimal first.
  def classify(bmi, lang: "es")
    b = round1(parse_number(bmi))
    c = CLASSES.find { |k| b < k.upper }
    Category.new(c.key, lang_of(lang) == "en" ? c.en : c.es, c.group, b)
  end

  # Raw BMI from kg and cm (or m).
  def bmi(weight_kg, height)
    w = parse_number(weight_kg)
    h = height_cm(height) / 100.0
    raise ArgumentError, "weight and height must be greater than 0" unless w.positive? && h.positive?

    w / (h * h)
  end

  # Raw BMI from pounds and inches: 703 * lb / in^2.
  def bmi_imperial(weight_lb, height_in)
    w = parse_number(weight_lb)
    h = parse_number(height_in)
    raise ArgumentError, "weight and height must be greater than 0" unless w.positive? && h.positive?

    703 * w / (h * h)
  end

  # Healthy-weight range (BMI 18.5 to 24.9) in kg, 1 decimal: [min, max].
  def healthy_range(height)
    h = height_cm(height) / 100.0
    raise ArgumentError, "height must be greater than 0" unless h.positive?

    [round1(18.5 * h * h), round1(24.9 * h * h)]
  end

  def format(n, lang)
    s = Kernel.format("%.1f", n)
    lang_of(lang) == "en" ? s : s.tr(".", ",")
  end

  def message(cat, diff, lang)
    d = format(diff, lang)
    low = cat.label.downcase
    if lang == "en"
      return "Your BMI is in the normal range for your height." if cat.group == "normal"

      side = cat.group == "bajo" ? "below" : "above"
      return "Your BMI shows #{low}. You are #{d} kg #{side} the normal range."
    end
    return "Tu IMC está dentro del rango normal para tu estatura." if cat.group == "normal"
    return "Tu IMC indica #{low}. Te faltan #{d} kg para llegar al rango normal." if cat.group == "bajo"

    "Tu IMC indica #{low}. Te sobran #{d} kg respecto al rango normal."
  end

  # Full result from weight_kg + height (cm or m), or weight_lb + height_in.
  def calculate(weight_kg: nil, height: nil, weight_lb: nil, height_in: nil, lang: "es")
    lang = lang_of(lang)
    if weight_lb || height_in
      raw = bmi_imperial(weight_lb, height_in)
      kg = parse_number(weight_lb) * LB_KG
      cm = parse_number(height_in) * IN_CM
    else
      raw = bmi(weight_kg, height)
      kg = parse_number(weight_kg)
      cm = height_cm(height)
    end
    cat = classify(raw, lang: lang)
    lo, hi = healthy_range(cm)
    diff = case cat.group
           when "bajo" then round1([lo - kg, 0].max)
           when "normal" then 0.0
           else round1([kg - hi, 0].max)
           end
    Result.new(bmi: cat.bmi, key: cat.key, label: cat.label, group: cat.group, min_kg: lo, max_kg: hi,
               diff_kg: diff, message: message(cat, diff, lang), disclaimer: DISCLAIMER[lang])
  end
end
