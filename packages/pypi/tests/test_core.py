import pytest

import imc_calculadora as imc
from imc_calculadora.cli import main


def test_overweight_example():
    r = imc.calculate(82, 175)
    assert (r.bmi, r.key, r.label, r.diff_kg) == (26.8, "sobrepeso", "Sobrepeso", 5.7)
    assert "5,7 kg" in r.message


def test_rounds_before_classifying():
    assert imc.classify(24.96).key == "sobrepeso"
    assert imc.classify(24.94).key == "normal"
    assert imc.classify(18.46).key == "normal"
    assert imc.classify(29.96).key == "obesidad_1"


@pytest.mark.parametrize("w,key", [(45, "delgadez_severa"), (48, "delgadez_moderada"), (50, "delgadez_leve"),
                                   (70, "normal"), (100, "obesidad_1"), (110, "obesidad_2"), (120, "obesidad_3")])
def test_who_classes(w, key):
    assert imc.calculate(w, 170).key == key


def test_range_and_underweight():
    assert imc.healthy_range(168) == (52.2, 70.3)
    r = imc.calculate(50, 170, lang="en")
    assert r.diff_kg == 3.5 and "3.5 kg below" in r.message


def test_imperial_comma_metres_and_errors():
    assert imc.round1(imc.bmi_imperial(154, 69)) == 22.7
    assert imc.calculate("70,5", "1,68").bmi == 25.0
    assert imc.parse_number("70,5") == 70.5
    with pytest.raises(ValueError):
        imc.calculate(0, 170)
    with pytest.raises(ValueError):
        imc.parse_number("abc")


def test_cli(capsys):
    assert main(["82", "175"]) == 0
    assert "IMC 26,8: Sobrepeso" in capsys.readouterr().out
    assert main(["--rango", "168", "--en"]) == 0
    assert "52.2 - 70.3 kg" in capsys.readouterr().out
