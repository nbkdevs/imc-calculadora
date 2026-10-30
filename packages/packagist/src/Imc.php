<?php

declare(strict_types=1);

namespace ImcCalculadora;

/**
 * Adult BMI (IMC) with WHO classes, healthy-weight range, metric/imperial input
 * and Spanish/English labels. The BMI is rounded to 1 decimal BEFORE it is
 * classified (24.96 -> 25.0 -> overweight).
 */
final class Imc
{
    public const LB_KG = 0.45359237;
    public const IN_CM = 2.54;

    /** @var list<array{key:string, upper:float, es:string, en:string, group:string}> */
    public const CLASSES = [
        ['key' => 'delgadez_severa', 'upper' => 16.0, 'es' => 'Delgadez severa', 'en' => 'Severe thinness', 'group' => 'bajo'],
        ['key' => 'delgadez_moderada', 'upper' => 17.0, 'es' => 'Delgadez moderada', 'en' => 'Moderate thinness', 'group' => 'bajo'],
        ['key' => 'delgadez_leve', 'upper' => 18.5, 'es' => 'Delgadez leve', 'en' => 'Mild thinness', 'group' => 'bajo'],
        ['key' => 'normal', 'upper' => 25.0, 'es' => 'Peso normal', 'en' => 'Normal weight', 'group' => 'normal'],
        ['key' => 'sobrepeso', 'upper' => 30.0, 'es' => 'Sobrepeso', 'en' => 'Overweight', 'group' => 'sobrepeso'],
        ['key' => 'obesidad_1', 'upper' => 35.0, 'es' => 'Obesidad grado I', 'en' => 'Obesity class I', 'group' => 'obesidad'],
        ['key' => 'obesidad_2', 'upper' => 40.0, 'es' => 'Obesidad grado II', 'en' => 'Obesity class II', 'group' => 'obesidad'],
        ['key' => 'obesidad_3', 'upper' => INF, 'es' => 'Obesidad grado III', 'en' => 'Obesity class III', 'group' => 'obesidad'],
    ];

    public const DISCLAIMER = [
        'es' => 'El IMC es una referencia general para adultos y no sustituye el consejo de un profesional de la salud.',
        'en' => 'BMI is a general guide for adults and is not medical advice.',
    ];

    /** Round half up to 1 decimal. */
    public static function round1(float $x): float
    {
        return floor($x * 10 + 0.5 + 1e-9) / 10;
    }

    /** Parse "70,5", "70.5" or a number. */
    public static function parseNumber(int|float|string $v): float
    {
        if (is_int($v) || is_float($v)) {
            if (!is_finite((float) $v)) {
                throw new \InvalidArgumentException('not a finite number');
            }
            return (float) $v;
        }
        $s = preg_replace('/,/', '.', trim($v), 1);
        if (!preg_match('/^\+?(\d+(\.\d+)?|\.\d+)$/', (string) $s)) {
            throw new \InvalidArgumentException("invalid number: $v");
        }
        return (float) $s;
    }

    /** Height in cm; values below 3 are taken as metres (1,75 -> 175). */
    public static function heightCm(int|float|string $h): float
    {
        $n = self::parseNumber($h);
        return $n < 3 ? $n * 100 : $n;
    }

    private static function lang(string $lang): string
    {
        return $lang === 'en' ? 'en' : 'es';
    }

    /**
     * WHO class for a BMI; the value is rounded to 1 decimal first.
     * @return array{key:string, label:string, group:string, bmi:float}
     */
    public static function classify(int|float|string $bmi, string $lang = 'es'): array
    {
        $b = self::round1(self::parseNumber($bmi));
        foreach (self::CLASSES as $c) {
            if ($b < $c['upper']) {
                return ['key' => $c['key'], 'label' => self::lang($lang) === 'en' ? $c['en'] : $c['es'], 'group' => $c['group'], 'bmi' => $b];
            }
        }
        throw new \LogicException('unreachable');
    }

    /** Raw BMI from kg and cm (or m). */
    public static function bmi(int|float|string $weightKg, int|float|string $height): float
    {
        $w = self::parseNumber($weightKg);
        $h = self::heightCm($height) / 100;
        if ($w <= 0 || $h <= 0) {
            throw new \InvalidArgumentException('weight and height must be greater than 0');
        }
        return $w / ($h * $h);
    }

    /** Raw BMI from pounds and inches: 703 * lb / in^2. */
    public static function bmiImperial(int|float|string $weightLb, int|float|string $heightIn): float
    {
        $w = self::parseNumber($weightLb);
        $h = self::parseNumber($heightIn);
        if ($w <= 0 || $h <= 0) {
            throw new \InvalidArgumentException('weight and height must be greater than 0');
        }
        return 703 * $w / ($h * $h);
    }

    /**
     * Healthy-weight range (BMI 18.5 to 24.9) in kg, 1 decimal.
     * @return array{min_kg:float, max_kg:float}
     */
    public static function healthyRange(int|float|string $height): array
    {
        $h = self::heightCm($height) / 100;
        if ($h <= 0) {
            throw new \InvalidArgumentException('height must be greater than 0');
        }
        return ['min_kg' => self::round1(18.5 * $h * $h), 'max_kg' => self::round1(24.9 * $h * $h)];
    }

    /** 1-decimal format: comma for Spanish, dot for English. */
    public static function format(float $n, string $lang = 'es'): string
    {
        $s = number_format($n, 1, '.', '');
        return self::lang($lang) === 'en' ? $s : str_replace('.', ',', $s);
    }

    /**
     * Full result. Pass weightKg + height, or weightLb + heightIn.
     * @return array{bmi:float, key:string, label:string, group:string, min_kg:float, max_kg:float, diff_kg:float, message:string, disclaimer:string}
     */
    public static function calculate(
        int|float|string|null $weightKg = null,
        int|float|string|null $height = null,
        string $lang = 'es',
        int|float|string|null $weightLb = null,
        int|float|string|null $heightIn = null,
    ): array {
        $lang = self::lang($lang);
        if ($weightLb !== null || $heightIn !== null) {
            $raw = self::bmiImperial($weightLb ?? '', $heightIn ?? '');
            $kg = self::parseNumber($weightLb ?? '') * self::LB_KG;
            $cm = self::parseNumber($heightIn ?? '') * self::IN_CM;
        } else {
            $raw = self::bmi($weightKg ?? '', $height ?? '');
            $kg = self::parseNumber($weightKg ?? '');
            $cm = self::heightCm($height ?? '');
        }
        $c = self::classify($raw, $lang);
        $r = self::healthyRange($cm);
        $diff = match ($c['group']) {
            'bajo' => self::round1(max(0.0, $r['min_kg'] - $kg)),
            'normal' => 0.0,
            default => self::round1(max(0.0, $kg - $r['max_kg'])),
        };
        return $c + $r + ['diff_kg' => $diff, 'message' => self::message($c, $diff, $lang), 'disclaimer' => self::DISCLAIMER[$lang]];
    }

    /** @param array{key:string, label:string, group:string, bmi:float} $c */
    private static function message(array $c, float $diff, string $lang): string
    {
        $d = self::format($diff, $lang);
        $low = mb_strtolower($c['label']);
        if ($lang === 'en') {
            return match ($c['group']) {
                'normal' => 'Your BMI is in the normal range for your height.',
                'bajo' => "Your BMI shows $low. You are $d kg below the normal range.",
                default => "Your BMI shows $low. You are $d kg above the normal range.",
            };
        }
        return match ($c['group']) {
            'normal' => 'Tu IMC está dentro del rango normal para tu estatura.',
            'bajo' => "Tu IMC indica $low. Te faltan $d kg para llegar al rango normal.",
            default => "Tu IMC indica $low. Te sobran $d kg respecto al rango normal.",
        };
    }
}
