using ImcCalculadora;

const string Help = """
imc-calculadora: adult BMI (IMC) with WHO classes

Usage:
  imc-calculadora <peso-kg> <altura-cm|m> [--en]
  imc-calculadora --lb <peso-lb> --in <altura-in> [--en]
  imc-calculadora --rango <altura-cm|m> [--en]
""";

var a = args.ToList();
if (a.Count == 0 || a.Contains("-h") || a.Contains("--help")) { Console.WriteLine(Help); return 0; }
var lang = a.Remove("--en") ? Lang.En : Lang.Es;
string? Take(string f)
{
    var i = a.IndexOf(f);
    if (i < 0) return null;
    var v = i + 1 < a.Count ? a[i + 1] : "";
    a.RemoveRange(i, i + 1 < a.Count ? 2 : 1);
    return v;
}
var hw = lang == Lang.En ? "Healthy weight" : "Peso saludable";
try
{
    var rango = Take("--rango");
    if (rango is not null)
    {
        var (lo, hi) = Imc.HealthyRange(Imc.ParseNumber(rango));
        Console.WriteLine($"{hw}: {Imc.Format(lo, lang)} - {Imc.Format(hi, lang)} kg");
        return 0;
    }
    var lb = Take("--lb");
    var inch = Take("--in");
    var r = lb is not null || inch is not null
        ? Imc.CalculateImperial(Imc.ParseNumber(lb ?? ""), Imc.ParseNumber(inch ?? ""), lang)
        : Imc.CalculateMetric(Imc.ParseNumber(a.ElementAtOrDefault(0) ?? ""), Imc.ParseNumber(a.ElementAtOrDefault(1) ?? ""), lang);
    Console.WriteLine($"{(lang == Lang.En ? "BMI" : "IMC")} {Imc.Format(r.Bmi, lang)}: {r.Label}");
    Console.WriteLine(r.Message);
    Console.WriteLine($"{hw}: {Imc.Format(r.MinKg, lang)} - {Imc.Format(r.MaxKg, lang)} kg");
    Console.WriteLine(r.Disclaimer);
    return 0;
}
catch (Exception e) when (e is FormatException or ArgumentException)
{
    Console.Error.WriteLine($"error: {e.Message}\n\n{Help}");
    return 2;
}
