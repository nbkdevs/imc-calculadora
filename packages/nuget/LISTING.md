# NuGet listing: ImcCalculadora

| Field | Value |
|---|---|
| Registry | NuGet |
| Name | `ImcCalculadora` (checked free on NuGet on 2026-10-30) |
| Version | 1.0.0 |
| Licence | MIT |
| Author | IMC Calculadora |
| Homepage | https://imccalculadora.app/ |
| Repository | https://github.com/nbkdevs/imc-calculadora (directory `packages/nuget`) |
| Planned URL | https://www.nuget.org/packages/ImcCalculadora |
| Anchor used | [Calculadora IMC](https://imccalculadora.app/) (README Links section) |

**Short description:** Calculadora IMC / BMI calculator: adult BMI with WHO classes (incl. thinness subclasses), healthy-weight range, metric and imperial input, Spanish and English labels.

**Long description:** see `README.md`.

**Dry-run:** dotnet test (14 pass); dotnet pack.

**Publish (not run, needs the owner's OK):** `cd packages/nuget && dotnet pack src -c Release -o out && dotnet nuget push out/ImcCalculadora.1.0.0.nupkg --source https://api.nuget.org/v3/index.json --api-key $NUGET_API_KEY`
