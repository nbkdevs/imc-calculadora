use imc_calculadora::{calculate_imperial, calculate_metric, healthy_range, parse_number, ImcError, Lang};
use std::process::ExitCode;

const HELP: &str = "imc-calculadora: adult BMI (IMC) with WHO classes

Usage:
  imc-calculadora <peso-kg> <altura-cm|m> [--en]
  imc-calculadora --lb <peso-lb> --in <altura-in> [--en]
  imc-calculadora --rango <altura-cm|m> [--en]

Examples: imc-calculadora 82 175 | imc-calculadora 70,5 1,68 --en | imc-calculadora --rango 168";

fn take(args: &mut Vec<String>, flag: &str) -> Option<String> {
    let i = args.iter().position(|a| a == flag)?;
    if i + 1 >= args.len() {
        args.remove(i);
        return Some(String::new());
    }
    let v = args.remove(i + 1);
    args.remove(i);
    Some(v)
}

fn run(mut args: Vec<String>) -> Result<(), ImcError> {
    let en = if let Some(i) = args.iter().position(|a| a == "--en") { args.remove(i); true } else { false };
    let lang = if en { Lang::En } else { Lang::Es };
    let fmt = |n: f64| if en { format!("{n:.1}") } else { format!("{n:.1}").replace('.', ",") };
    let hw = if en { "Healthy weight" } else { "Peso saludable" };
    if let Some(h) = take(&mut args, "--rango") {
        let (lo, hi) = healthy_range(parse_number(&h)?)?;
        println!("{hw}: {} - {} kg", fmt(lo), fmt(hi));
        return Ok(());
    }
    let lb = take(&mut args, "--lb");
    let inch = take(&mut args, "--in");
    let r = if lb.is_some() || inch.is_some() {
        calculate_imperial(parse_number(&lb.unwrap_or_default())?, parse_number(&inch.unwrap_or_default())?, lang)?
    } else {
        let w = args.first().map(String::as_str).unwrap_or("");
        let h = args.get(1).map(String::as_str).unwrap_or("");
        calculate_metric(parse_number(w)?, parse_number(h)?, lang)?
    };
    println!("{} {}: {}", if en { "BMI" } else { "IMC" }, fmt(r.bmi), r.label);
    println!("{}", r.message);
    println!("{hw}: {} - {} kg", fmt(r.min_kg), fmt(r.max_kg));
    println!("{}", r.disclaimer);
    Ok(())
}

fn main() -> ExitCode {
    let args: Vec<String> = std::env::args().skip(1).collect();
    if args.is_empty() || args.iter().any(|a| a == "-h" || a == "--help") {
        println!("{HELP}");
        return ExitCode::SUCCESS;
    }
    match run(args) {
        Ok(()) => ExitCode::SUCCESS,
        Err(e) => {
            eprintln!("error: {e}\n\n{HELP}");
            ExitCode::from(2)
        }
    }
}
