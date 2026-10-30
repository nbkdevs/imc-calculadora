class UnitConversion {
  static double kgFromLb(double lb) => lb * 0.45359237;
  static double mFromCm(double cm) => cm / 100;
  static double mFromFtIn(double ft, double inch) => ((ft * 12) + inch) * 0.0254;
  static double lbFromKg(double kg) => kg / 0.45359237;
}
