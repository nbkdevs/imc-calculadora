#!/usr/bin/env python3
"""Featured and in-article images for the IMC Calculadora blog.

Every number and label is taken from the published post. Nothing is added.
"""

import shutil
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent
FONT = ROOT / "fonts"
OUT = ROOT / "images" / "blog"
OUT.mkdir(parents=True, exist_ok=True)

INK = (26, 36, 33)
MUTED = (59, 91, 109)
TEAL = (14, 92, 82)
BORDER = (220, 227, 225)
WHITE = (255, 255, 255)
CANVAS = (244, 246, 245)
GOLD = (201, 138, 31)
ORANGE = (193, 89, 31)
RED = (168, 58, 42)
DARKRED = (122, 36, 32)

W = 1080
FW, FH = 1200, 630


def font(name, size):
    return ImageFont.truetype(str(FONT / name), size)


SG = lambda s: font("SpaceGrotesk-SemiBold.ttf", s)
SGM = lambda s: font("SpaceGrotesk-Medium.ttf", s)
PLEX = lambda s: font("IBMPlexSans-Regular.ttf", s)
PLEXM = lambda s: font("IBMPlexSans-Medium.ttf", s)


def text_w(fnt, s):
    b = fnt.getbbox(s)
    return b[2] - b[0]


def wrap(text, fnt, max_w):
    lines, cur = [], ""
    for word in text.split():
        trial = word if not cur else f"{cur} {word}"
        if text_w(fnt, trial) <= max_w:
            cur = trial
        else:
            if cur:
                lines.append(cur)
            cur = word
    if cur:
        lines.append(cur)
    return lines or [""]


def save(im, name):
    path = OUT / name
    im.save(path, "WEBP", quality=82, method=6)
    size = path.stat().st_size
    if size >= 100 * 1024:
        for q in (70, 60, 50):
            im.save(path, "WEBP", quality=q, method=6)
            size = path.stat().st_size
            if size < 100 * 1024:
                break
    print(f"{name} {im.size[0]}x{im.size[1]} {size}")
    if size >= 100 * 1024:
        raise SystemExit(f"{name} is {size} bytes")
    return path


def new(w, h):
    im = Image.new("RGB", (w, h), CANVAS)
    return im, ImageDraw.Draw(im)


def card(d, box, radius=6):
    d.rounded_rectangle(box, radius=radius, fill=WHITE, outline=BORDER, width=1)


def center(d, text, y, fnt, fill, width, x0=0):
    d.text((x0 + (width - text_w(fnt, text)) / 2, y), text, font=fnt, fill=fill)


def featured(title, lines, big, caption):
    im, d = new(FW, FH)
    card(d, (48, 48, FW - 48, FH - 48))
    d.text((88, 88), title, font=SG(28), fill=MUTED)
    y = 150
    for line in lines:
        center(d, line, y, SG(54), INK, FW - 176, 88)
        y += 68
    y += 8
    center(d, big, y, SG(72), TEAL, FW - 176, 88)
    y += 100
    for line in wrap(caption, PLEX(22), FW - 220):
        center(d, line, y, PLEX(22), MUTED, FW - 176, 88)
        y += 32
    return im


def section_title(d, title, y=40):
    d.text((48, y), title, font=SG(32), fill=INK)
    return y + 52


# --- 142 BMI Prime ---

def bmi_prime_featured():
    return featured(
        "Qué es el BMI Prime",
        ["BMI Prime = IMC ÷ 25"],
        "27.5 da 1.1",
        "25 es el límite superior del rango normal. Un IMC de 27.5 da un BMI Prime de 1.1.",
    )


def bmi_prime_table():
    im, d = new(W, 560)
    y = section_title(d, "BMI Prime según el IMC")
    d.text((48, y), "BMI Prime = tu IMC ÷ 25", font=PLEX(20), fill=MUTED)
    y += 44
    rows = [
        ("18.5", "0.74", "Límite inferior del rango normal"),
        ("22.0", "0.88", "Dentro del rango normal"),
        ("25.0", "1.00", "Justo en el límite superior"),
        ("30.0", "1.20", "20% por encima del límite"),
        ("40.0", "1.60", "60% por encima del límite"),
    ]
    card(d, (48, y, W - 48, y + 64 + len(rows) * 64))
    d.text((80, y + 20), "IMC", font=PLEXM(18), fill=MUTED)
    d.text((240, y + 20), "BMI Prime", font=PLEXM(18), fill=MUTED)
    d.text((460, y + 20), "Interpretación", font=PLEXM(18), fill=MUTED)
    yy = y + 64
    for imc, prime, label in rows:
        d.line((72, yy, W - 72, yy), fill=BORDER, width=1)
        d.text((80, yy + 18), imc, font=SG(26), fill=INK)
        d.text((240, yy + 18), prime, font=SG(26), fill=TEAL)
        d.text((460, yy + 22), label, font=PLEX(20), fill=INK)
        yy += 64
    return im


def bmi_prime_example():
    im, d = new(W, 320)
    y = section_title(d, "Ejemplo de BMI Prime")
    card(d, (48, y, W - 48, y + 180))
    center(d, "IMC 27.5  ÷  25", y + 36, SG(40), INK, W - 96, 48)
    center(d, "1.1", y + 96, SG(56), TEAL, W - 96, 48)
    return im


# --- 140 obesidad ---

def obesidad_featured():
    im, d = new(FW, FH)
    card(d, (48, 48, FW - 48, FH - 48))
    d.text((88, 84), "Grados de obesidad según el IMC", font=SG(28), fill=MUTED)
    cols = [
        (GOLD, "Grado 1", "30 a 34.9"),
        (ORANGE, "Grado 2", "35 a 39.9"),
        (DARKRED, "Grado 3", "40 o más"),
    ]
    x = 88
    for color, name, band in cols:
        card(d, (x, 180, x + 320, 470))
        d.rounded_rectangle((x + 28, 212, x + 68, 252), radius=6, fill=color)
        d.text((x + 28, 280), name, font=SG(32), fill=INK)
        d.text((x + 28, 340), band, font=SG(40), fill=TEAL)
        x += 344
    center(d, "Asociación de población. No es un diagnóstico individual.", 510, PLEX(22), MUTED, FW - 176, 88)
    return im


def obesidad_asociaciones():
    im, d = new(W, 700)
    y = section_title(d, "Qué asocia la evidencia a cada grado")
    d.text((48, y), "Estudios de población, no un destino individual.", font=PLEX(18), fill=MUTED)
    y += 40
    rows = [
        (GOLD, "Grado 1, 30 a 34.9", "Diabetes tipo 2 e hipertensión, con asociación más consistente que en sobrepeso."),
        (ORANGE, "Grado 2, 35 a 39.9", "Las mismas condiciones, con una asociación mayor. Umbral que se considera en cirugía bariátrica si hay condiciones asociadas."),
        (DARKRED, "Grado 3, 40 o más", "La mayor asociación. Incluye problemas articulares y apnea del sueño, además de las condiciones anteriores."),
    ]
    for color, title, body in rows:
        lines = wrap(body, PLEX(18), W - 180)
        h = 36 + 28 + len(lines) * 26 + 16
        card(d, (48, y, W - 48, y + h))
        d.rounded_rectangle((72, y + 28, 96, y + 52), radius=4, fill=color)
        d.text((112, y + 24), title, font=SG(22), fill=INK)
        yy = y + 60
        for line in lines:
            d.text((112, yy), line, font=PLEX(18), fill=INK)
            yy += 26
        y += h + 16
    return im.crop((0, 0, W, y + 8))


def obesidad_factores():
    im, d = new(W, 360)
    y = section_title(d, "Qué pesa además del número de IMC")
    items = ["Alimentación", "Actividad física", "Sueño", "Estrés", "Antecedentes familiares"]
    x, yy = 48, y
    for item in items:
        tw = text_w(PLEXM(22), item)
        if x + tw + 48 > W - 48:
            x = 48
            yy += 72
        card(d, (x, yy, x + tw + 40, yy + 56))
        d.text((x + 20, yy + 14), item, font=PLEXM(22), fill=INK)
        x += tw + 56
    return im.crop((0, 0, W, yy + 88))


# --- 141 grasa corporal ---

def grasa_featured():
    im, d = new(FW, FH)
    card(d, (48, 48, FW - 48, FH - 48))
    d.text((88, 84), "Otras formas de medir la grasa corporal", font=SG(28), fill=MUTED)
    steps = [
        ("1", "Cintura", "Acceso alto"),
        ("2", "Pliegues", "Acceso medio"),
        ("3", "Bioimpedancia", "Medio a alto"),
        ("4", "DEXA", "Referencia"),
    ]
    x = 88
    for n, name, note in steps:
        card(d, (x, 190, x + 240, 470))
        d.text((x + 24, 220), n, font=SG(28), fill=TEAL)
        d.text((x + 24, 280), name, font=SG(28), fill=INK)
        for i, line in enumerate(wrap(note, PLEX(18), 190)):
            d.text((x + 24, 350 + i * 26), line, font=PLEX(18), fill=MUTED)
        x += 256
    center(d, "De menor a mayor precisión, y en general de menor a mayor costo.", 510, PLEX(20), MUTED, FW - 176, 88)
    return im


def grasa_comparacion():
    im, d = new(W, 480)
    y = section_title(d, "Precisión y acceso")
    rows = [
        ("Circunferencia de cintura", "Básica, útil como referencia", "Alto"),
        ("Pliegues cutáneos", "Media, depende de la técnica", "Medio"),
        ("Bioimpedancia", "Media a alta, según el equipo", "Medio"),
        ("DEXA", "Alta, estándar de referencia", "Bajo"),
    ]
    card(d, (48, y, W - 48, y + 64 + len(rows) * 72))
    d.text((72, y + 18), "Método", font=PLEXM(16), fill=MUTED)
    d.text((460, y + 18), "Precisión", font=PLEXM(16), fill=MUTED)
    d.text((860, y + 18), "Acceso", font=PLEXM(16), fill=MUTED)
    yy = y + 64
    for method, precision, access in rows:
        d.line((72, yy, W - 72, yy), fill=BORDER, width=1)
        d.text((72, yy + 22), method, font=SG(22), fill=INK)
        d.text((460, yy + 24), precision, font=PLEX(18), fill=INK)
        d.text((860, yy + 22), access, font=SG(22), fill=TEAL)
        yy += 72
    return im


# --- 139 bariátrica ---

def bariatrica_featured():
    im, d = new(FW, FH)
    card(d, (48, 48, FW - 48, FH - 48))
    d.text((88, 84), "IMC para cirugía bariátrica", font=SG(28), fill=MUTED)
    card(d, (88, 180, 560, 470))
    d.text((120, 214), "IMC 40", font=SG(56), fill=TEAL)
    for i, line in enumerate(wrap("Referencia habitual, sin exigir una condición asociada.", PLEX(22), 400)):
        d.text((120, 300 + i * 32), line, font=PLEX(22), fill=INK)
    card(d, (600, 180, 1112, 470))
    d.text((632, 214), "IMC 35", font=SG(56), fill=TEAL)
    for i, line in enumerate(wrap("Si hay condiciones asociadas, como diabetes tipo 2, hipertensión o apnea del sueño.", PLEX(22), 430)):
        d.text((632, 300 + i * 32), line, font=PLEX(22), fill=INK)
    center(d, "Punto de partida, no una regla universal.", 510, PLEX(22), MUTED, FW - 176, 88)
    return im


def bariatrica_criterios():
    im, d = new(W, 340)
    y = section_title(d, "Criterios de IMC más usados")
    card(d, (48, y, 500, y + 200))
    d.text((80, y + 28), "Sin condición asociada", font=PLEXM(18), fill=MUTED)
    d.text((80, y + 70), "IMC 40", font=SG(48), fill=TEAL)
    card(d, (528, y, W - 48, y + 200))
    d.text((560, y + 28), "Con condición asociada", font=PLEXM(18), fill=MUTED)
    d.text((560, y + 70), "IMC 35", font=SG(48), fill=TEAL)
    return im


def bariatrica_factores():
    im, d = new(W, 460)
    y = section_title(d, "Qué se evalúa además del IMC")
    items = [
        "Intentos previos de pérdida de peso con dieta, actividad física o medicamentos.",
        "Condiciones asociadas: diabetes tipo 2, hipertensión, apnea del sueño.",
        "Evaluación psicológica, para confirmar que la persona comprende los cambios.",
        "Evaluación nutricional y, en algunos casos, estudios según el historial.",
    ]
    for item in items:
        lines = wrap(item, PLEX(20), W - 160)
        h = 28 + len(lines) * 28
        card(d, (48, y, W - 48, y + h))
        d.ellipse((72, y + 18, 88, y + 34), fill=TEAL)
        yy = y + 12
        for line in lines:
            d.text((108, yy), line, font=PLEX(20), fill=INK)
            yy += 28
        y += h + 14
    return im.crop((0, 0, W, y + 8))


# --- 137 atletas ---

def atletas_featured():
    im, d = new(FW, FH)
    card(d, (48, 48, FW - 48, FH - 48))
    d.text((88, 80), "IMC en atletas y personas musculosas", font=SG(28), fill=MUTED)
    center(d, "1.80 m    90 kg    IMC 27.8", 150, SG(40), TEAL, FW - 176, 88)
    card(d, (88, 240, 560, 500))
    d.text((116, 268), "Misma cifra", font=PLEXM(18), fill=MUTED)
    for i, line in enumerate(wrap("Persona sedentaria, con poca masa muscular.", PLEX(24), 400)):
        d.text((116, 320 + i * 34), line, font=PLEX(24), fill=INK)
    card(d, (600, 240, 1112, 500))
    d.text((628, 268), "Misma cifra", font=PLEXM(18), fill=MUTED)
    for i, line in enumerate(wrap("Entrena fuerza y tiene un porcentaje de grasa corporal bajo.", PLEX(24), 440)):
        d.text((628, 320 + i * 34), line, font=PLEX(24), fill=INK)
    center(d, "El IMC no distingue músculo de grasa.", 530, PLEX(22), MUTED, FW - 176, 88)
    return im


def atletas_calculo():
    im, d = new(W, 360)
    y = section_title(d, "El ejemplo: mismo IMC, distinta situación")
    card(d, (48, y, W - 48, y + 220))
    center(d, "90 kg  ÷  (1.80 × 1.80)", y + 28, SG(36), INK, W - 96, 48)
    center(d, "IMC 27.8, sobrepeso", y + 100, SG(40), TEAL, W - 96, 48)
    center(d, "El número es idéntico. La composición corporal, no.", y + 164, PLEX(20), MUTED, W - 96, 48)
    return im


def atletas_medidas():
    im, d = new(W, 300)
    y = section_title(d, "Medidas que sí miran la composición")
    items = ["Porcentaje de grasa corporal", "Circunferencia de cintura", "Bioimpedancia", "DEXA"]
    x, yy = 48, y
    for item in items:
        tw = text_w(PLEXM(22), item)
        if x + tw + 48 > W - 48:
            x = 48
            yy += 72
        card(d, (x, yy, x + tw + 40, yy + 56))
        d.text((x + 20, yy + 14), item, font=PLEXM(22), fill=INK)
        x += tw + 56
    return im.crop((0, 0, W, yy + 88))


# --- 138 poblaciones ---

def poblaciones_featured():
    im, d = new(FW, FH)
    card(d, (48, 48, FW - 48, FH - 48))
    d.text((88, 84), "Puntos de corte estándar de la OMS", font=SG(28), fill=MUTED)
    marks = [("18.5", "Bajo peso / normal"), ("25", "Normal / sobrepeso"), ("30", "Inicio de la obesidad")]
    x = 88
    for num, label in marks:
        card(d, (x, 190, x + 320, 460))
        center(d, num, 250, SG(64), TEAL, 320, x)
        for i, line in enumerate(wrap(label, PLEX(22), 260)):
            center(d, line, 360 + i * 30, PLEX(22), INK, 320, x)
        x += 344
    center(d, "Esta calculadora usa estos límites en todos los casos.", 510, PLEX(22), MUTED, FW - 176, 88)
    return im


def poblaciones_alternativos():
    im, d = new(W, 340)
    y = section_title(d, "Puntos de corte alternativos")
    card(d, (48, y, W - 48, y + 200))
    lines = wrap(
        "La OMS documentó, para algunas poblaciones de origen asiático, un umbral clínico de sobrepeso más bajo que 25. Es de uso clínico. No es un ajuste para aplicar por cuenta propia.",
        PLEX(22),
        W - 160,
    )
    yy = y + 28
    for line in lines:
        d.text((80, yy), line, font=PLEX(22), fill=INK)
        yy += 34
    return im


def poblaciones_latam():
    im, d = new(W, 300)
    y = section_title(d, "Latinoamérica usa el corte estándar")
    items = ["México", "Colombia", "Argentina", "Chile", "Perú"]
    x = 48
    for item in items:
        tw = text_w(SG(26), item)
        card(d, (x, y, x + tw + 40, y + 64))
        d.text((x + 20, y + 16), item, font=SG(26), fill=INK)
        x += tw + 56
    d.text((48, y + 88), "Puntos de corte estándar de la OMS para la población general.", font=PLEX(20), fill=MUTED)
    return im.crop((0, 0, W, y + 140))


# --- 136 no confiable ---

def excepciones_featured():
    im, d = new(FW, FH)
    card(d, (48, 48, FW - 48, FH - 48))
    d.text((88, 84), "Cuándo el IMC no se lee igual", font=SG(28), fill=MUTED)
    items = ["Embarazo", "Niños", "Mayores de 65", "Atletas", "Amputación"]
    x, yy = 88, 200
    for item in items:
        tw = text_w(SG(32), item)
        if x + tw + 48 > FW - 88:
            x = 88
            yy += 100
        card(d, (x, yy, x + tw + 48, yy + 76))
        d.text((x + 24, yy + 18), item, font=SG(32), fill=INK)
        x += tw + 68
    center(d, "La tabla estándar de cuatro categorías no aplica igual en estos casos.", 500, PLEX(22), MUTED, FW - 176, 88)
    return im


def excepciones_imc18():
    im, d = new(W, 340)
    y = section_title(d, "Un IMC de 18 no significa lo mismo")
    card(d, (48, y, 500, y + 200))
    d.text((80, y + 28), "Niño de 8 años", font=PLEXM(20), fill=MUTED)
    d.text((80, y + 72), "Puede ser bajo", font=SG(36), fill=INK)
    card(d, (528, y, W - 48, y + 200))
    d.text((560, y + 28), "Adolescente", font=PLEXM(20), fill=MUTED)
    d.text((560, y + 72), "Puede ser normal", font=SG(36), fill=TEAL)
    return im


def excepciones_que_usar():
    im, d = new(W, 420)
    y = section_title(d, "Qué usar cuando el IMC estándar no aplica")
    rows = [
        ("Embarazo", "Seguimiento del médico u obstetra."),
        ("Niños", "Percentil de IMC por edad y sexo."),
        ("Músculo o personas mayores", "Cintura o porcentaje de grasa corporal."),
    ]
    for title, body in rows:
        card(d, (48, y, W - 48, y + 88))
        d.text((72, y + 14), title, font=SG(22), fill=TEAL)
        d.text((72, y + 46), body, font=PLEX(20), fill=INK)
        y += 104
    return im.crop((0, 0, W, y + 8))


def main():
    jobs = {
        "bmi-prime-imc-dividido-entre-25.webp": bmi_prime_featured(),
        "tabla-bmi-prime-segun-el-imc.webp": bmi_prime_table(),
        "ejemplo-bmi-prime-imc-27-5.webp": bmi_prime_example(),
        "grados-de-obesidad-imc-30-35-40.webp": obesidad_featured(),
        "riesgos-asociados-por-grado-de-obesidad.webp": obesidad_asociaciones(),
        "factores-que-pesan-ademas-del-imc.webp": obesidad_factores(),
        "metodos-para-medir-grasa-corporal.webp": grasa_featured(),
        "comparacion-precision-y-acceso-grasa-corporal.webp": grasa_comparacion(),
        "imc-para-cirugia-bariatrica-35-y-40.webp": bariatrica_featured(),
        "criterios-de-imc-cirugia-bariatrica.webp": bariatrica_criterios(),
        "evaluacion-ademas-del-imc-cirugia-bariatrica.webp": bariatrica_factores(),
        "imc-27-8-mismo-peso-distinta-composicion.webp": atletas_featured(),
        "ejemplo-imc-1-80-m-y-90-kg.webp": atletas_calculo(),
        "medidas-de-composicion-corporal-ademas-del-imc.webp": atletas_medidas(),
        "puntos-de-corte-imc-oms-18-5-25-30.webp": poblaciones_featured(),
        "puntos-de-corte-imc-mas-bajos-que-25.webp": poblaciones_alternativos(),
        "puntos-de-corte-imc-en-latinoamerica.webp": poblaciones_latam(),
        "cuando-el-imc-estandar-no-aplica.webp": excepciones_featured(),
        "imc-18-nino-de-8-anos-y-adolescente.webp": excepciones_imc18(),
        "que-usar-si-el-imc-no-aplica.webp": excepciones_que_usar(),
    }
    for name, im in jobs.items():
        save(im, name)
    src = ROOT / "images" / "circunferencia-de-cintura-y-el-imc.webp"
    dst = OUT / "medir-circunferencia-de-cintura-grasa-abdominal.webp"
    shutil.copyfile(src, dst)
    print(f"{dst.name} {Image.open(dst).size} {dst.stat().st_size}")


if __name__ == "__main__":
    main()
