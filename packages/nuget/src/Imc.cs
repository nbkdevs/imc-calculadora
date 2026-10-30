using System;
using System.Collections.Generic;
using System.Linq;
using System.Globalization;
using System.Text.RegularExpressions;

namespace ImcCalculadora;

/// <summary>Output language.</summary>
public enum Lang { Es, En }

/// <summary>One WHO adult class.</summary>
public sealed record ImcClass(string Key, double Upper, string Es, string En, string Group);

/// <summary>A classified BMI (rounded to 1 decimal).</summary>
public sealed record ImcCategory(string Key, string Label, string Group, double Bmi);

/// <summary>Full result.</summary>
public sealed record ImcResult(double Bmi, string Key, string Label, string Group, double MinKg, double MaxKg,
    double DiffKg, string Message, string Disclaimer);

/// <summary>
/// Adult BMI (IMC) with WHO classes, healthy-weight range, metric/imperial input and Spanish/English labels.
/// The BMI is rounded to 1 decimal before it is classified (24.96 -> 25.0 -> overweight).
/// </summary>
public static class Imc
{
    /// <summary>Kilograms per pound.</summary>
    public const double LbKg = 0.45359237;
    /// <summary>Centimetres per inch.</summary>
    public const double InCm = 2.54;

    /// <summary>WHO adult classes, including the three thinness subclasses.</summary>
    public static readonly IReadOnlyList<ImcClass> Classes = new[]
    {
        new ImcClass("delgadez_severa", 16, "Delgadez severa", "Severe thinness", "bajo"),
        new ImcClass("delgadez_moderada", 17, "Delgadez moderada", "Moderate thinness", "bajo"),
        new ImcClass("delgadez_leve", 18.5, "Delgadez leve", "Mild thinness", "bajo"),
        new ImcClass("normal", 25, "Peso normal", "Normal weight", "normal"),
        new ImcClass("sobrepeso", 30, "Sobrepeso", "Overweight", "sobrepeso"),
        new ImcClass("obesidad_1", 35, "Obesidad grado I", "Obesity class I", "obesidad"),
        new ImcClass("obesidad_2", 40, "Obesidad grado II", "Obesity class II", "obesidad"),
        new ImcClass("obesidad_3", double.PositiveInfinity, "Obesidad grado III", "Obesity class III", "obesidad"),
    };

    /// <summary>Not-medical-advice note.</summary>
    public static string Disclaimer(Lang lang) => lang == Lang.En
        ? "BMI is a general guide for adults and is not medical advice."
        : "El IMC es una referencia general para adultos y no sustituye el consejo de un profesional de la salud.";

    /// <summary>Round half up to 1 decimal.</summary>
    public static double Round1(double x) => Math.Floor(x * 10 + 0.5 + 1e-9) / 10;

    private static readonly Regex Num = new(@"^\+?(\d+(\.\d+)?|\.\d+)$", RegexOptions.Compiled);

    /// <summary>Parse "70,5" or "70.5".</summary>
    public static double ParseNumber(string s)
    {
        var t = (s ?? "").Trim();
        var i = t.IndexOf(',');
        if (i >= 0) t = t[..i] + "." + t[(i + 1)..];
        if (!Num.IsMatch(t)) throw new FormatException($"invalid number: {s}");
        return double.Parse(t, CultureInfo.InvariantCulture);
    }

    /// <summary>Height in cm; values below 3 are taken as metres (1.75 -> 175).</summary>
    public static double HeightCm(double h) => h < 3 ? h * 100 : h;

    /// <summary>WHO class for a BMI; the value is rounded to 1 decimal first.</summary>
    public static ImcCategory Classify(double bmi, Lang lang = Lang.Es)
    {
        var b = Round1(bmi);
        var c = Classes.First(c => b < c.Upper);
        return new ImcCategory(c.Key, lang == Lang.En ? c.En : c.Es, c.Group, b);
    }

    /// <summary>Raw BMI from kg and cm (or m).</summary>
    public static double Bmi(double weightKg, double height)
    {
        var h = HeightCm(height) / 100;
        if (!(weightKg > 0) || !(h > 0)) throw new ArgumentOutOfRangeException(nameof(weightKg), "weight and height must be greater than 0");
        return weightKg / (h * h);
    }

    /// <summary>Raw BMI from pounds and inches: 703 * lb / in^2.</summary>
    public static double BmiImperial(double weightLb, double heightIn)
    {
        if (!(weightLb > 0) || !(heightIn > 0)) throw new ArgumentOutOfRangeException(nameof(weightLb), "weight and height must be greater than 0");
        return 703 * weightLb / (heightIn * heightIn);
    }

    /// <summary>Healthy-weight range (BMI 18.5 to 24.9) in kg, 1 decimal.</summary>
    public static (double MinKg, double MaxKg) HealthyRange(double height)
    {
        var h = HeightCm(height) / 100;
        if (!(h > 0)) throw new ArgumentOutOfRangeException(nameof(height), "height must be greater than 0");
        return (Round1(18.5 * h * h), Round1(24.9 * h * h));
    }

    /// <summary>Full result from kg and cm (or m).</summary>
    public static ImcResult CalculateMetric(double weightKg, double height, Lang lang = Lang.Es) =>
        Build(Bmi(weightKg, height), weightKg, HeightCm(height), lang);

    /// <summary>Full result from pounds and inches.</summary>
    public static ImcResult CalculateImperial(double weightLb, double heightIn, Lang lang = Lang.Es) =>
        Build(BmiImperial(weightLb, heightIn), weightLb * LbKg, heightIn * InCm, lang);

    /// <summary>Format with 1 decimal: comma for Spanish, dot for English.</summary>
    public static string Format(double n, Lang lang) =>
        n.ToString("0.0", lang == Lang.En ? CultureInfo.InvariantCulture : CultureInfo.GetCultureInfo("es-ES"));

    private static ImcResult Build(double raw, double kg, double cm, Lang lang)
    {
        var c = Classify(raw, lang);
        var (lo, hi) = HealthyRange(cm);
        var diff = c.Group switch
        {
            "bajo" => Round1(Math.Max(0, lo - kg)),
            "normal" => 0,
            _ => Round1(Math.Max(0, kg - hi)),
        };
        return new ImcResult(c.Bmi, c.Key, c.Label, c.Group, lo, hi, diff, Message(c, diff, lang), Disclaimer(lang));
    }

    private static string Message(ImcCategory c, double diff, Lang lang)
    {
        var d = Format(diff, lang);
        var low = c.Label.ToLowerInvariant();
        if (lang == Lang.En)
            return c.Group switch
            {
                "normal" => "Your BMI is in the normal range for your height.",
                "bajo" => $"Your BMI shows {low}. You are {d} kg below the normal range.",
                _ => $"Your BMI shows {low}. You are {d} kg above the normal range.",
            };
        return c.Group switch
        {
            "normal" => "Tu IMC está dentro del rango normal para tu estatura.",
            "bajo" => $"Tu IMC indica {low}. Te faltan {d} kg para llegar al rango normal.",
            _ => $"Tu IMC indica {low}. Te sobran {d} kg respecto al rango normal.",
        };
    }
}
