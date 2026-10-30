using ImcCalculadora;
using Xunit;

public class ImcTests
{
    [Fact]
    public void OverweightExample()
    {
        var r = Imc.CalculateMetric(82, 175);
        Assert.Equal((26.8, "sobrepeso", "Sobrepeso", 5.7), (r.Bmi, r.Key, r.Label, r.DiffKg));
        Assert.Contains("5,7 kg", r.Message);
    }

    [Theory]
    [InlineData(24.96, "sobrepeso")]
    [InlineData(24.94, "normal")]
    [InlineData(18.46, "normal")]
    [InlineData(29.96, "obesidad_1")]
    public void RoundsBeforeClassifying(double bmi, string key) => Assert.Equal(key, Imc.Classify(bmi).Key);

    [Theory]
    [InlineData(45, "delgadez_severa")]
    [InlineData(48, "delgadez_moderada")]
    [InlineData(50, "delgadez_leve")]
    [InlineData(70, "normal")]
    [InlineData(100, "obesidad_1")]
    [InlineData(110, "obesidad_2")]
    [InlineData(120, "obesidad_3")]
    public void WhoClasses(double w, string key) => Assert.Equal(key, Imc.CalculateMetric(w, 170).Key);

    [Fact]
    public void RangeAndUnderweight()
    {
        Assert.Equal((52.2, 70.3), Imc.HealthyRange(168));
        var r = Imc.CalculateMetric(50, 170, Lang.En);
        Assert.Equal(3.5, r.DiffKg);
        Assert.Contains("3.5 kg below", r.Message);
    }

    [Fact]
    public void ImperialCommaMetresErrors()
    {
        Assert.Equal(22.7, Imc.Round1(Imc.BmiImperial(154, 69)));
        Assert.Equal(25.0, Imc.CalculateMetric(Imc.ParseNumber("70,5"), Imc.ParseNumber("1,68")).Bmi);
        Assert.Throws<ArgumentOutOfRangeException>(() => Imc.CalculateMetric(0, 170));
        Assert.Throws<FormatException>(() => Imc.ParseNumber("abc"));
    }
}
