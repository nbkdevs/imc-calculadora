# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/imc_calculadora"

class TestImcCalculadora < Minitest::Test
  I = ImcCalculadora

  def test_overweight_example
    r = I.calculate(weight_kg: 82, height: 175)
    assert_equal [26.8, "sobrepeso", "Sobrepeso", 5.7], [r.bmi, r.key, r.label, r.diff_kg]
    assert_includes r.message, "5,7 kg"
  end

  def test_rounds_before_classifying
    assert_equal "sobrepeso", I.classify(24.96).key
    assert_equal "normal", I.classify(24.94).key
    assert_equal "normal", I.classify(18.46).key
    assert_equal "obesidad_1", I.classify(29.96).key
  end

  def test_who_classes
    keys = [45, 48, 50, 70, 100, 110, 120].map { |w| I.calculate(weight_kg: w, height: 170).key }
    assert_equal %w[delgadez_severa delgadez_moderada delgadez_leve normal obesidad_1 obesidad_2 obesidad_3], keys
  end

  def test_range_and_underweight
    assert_equal [52.2, 70.3], I.healthy_range(168)
    r = I.calculate(weight_kg: 50, height: 170, lang: "en")
    assert_equal 3.5, r.diff_kg
    assert_includes r.message, "3.5 kg below"
  end

  def test_imperial_comma_metres_errors
    assert_equal 22.7, I.round1(I.bmi_imperial(154, 69))
    assert_equal 25.0, I.calculate(weight_kg: "70,5", height: "1,68").bmi
    assert_raises(ArgumentError) { I.calculate(weight_kg: 0, height: 170) }
    assert_raises(ArgumentError) { I.parse_number("abc") }
  end
end
