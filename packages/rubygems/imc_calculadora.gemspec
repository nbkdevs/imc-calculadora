require_relative "lib/imc_calculadora/version"

Gem::Specification.new do |spec|
  spec.name = "imc_calculadora"
  spec.version = ImcCalculadora::VERSION
  spec.authors = ["IMC Calculadora"]
  spec.summary = "Calculadora IMC / BMI calculator: WHO classes, healthy-weight range, metric and imperial, ES/EN."
  spec.description = "Adult BMI (IMC) with WHO classes including thinness subclasses, 1-decimal rounding before " \
                     "classifying, healthy-weight range, kg/cm and lb/in input, comma decimals, Spanish and English labels. Library and CLI."
  spec.homepage = "https://imccalculadora.app/"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"
  spec.metadata = {
    "homepage_uri" => spec.homepage,
    "source_code_uri" => "https://github.com/nbkdevs/imc-calculadora/tree/main/packages/rubygems",
    "bug_tracker_uri" => "https://github.com/nbkdevs/imc-calculadora/issues",
    "rubygems_mfa_required" => "true"
  }
  spec.files = Dir["lib/**/*.rb", "exe/*", "README.md", "LICENSE"]
  spec.bindir = "exe"
  spec.executables = ["imc-calculadora"]
  spec.require_paths = ["lib"]
end
