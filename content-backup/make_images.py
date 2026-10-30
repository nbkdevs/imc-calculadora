#!/usr/bin/env python3
"""Clinical Precision infographics for IMC Calculadora. Numbers match the published pages."""

from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parent
FONT = ROOT / "fonts"
OUT = ROOT / "images"
OUT.mkdir(exist_ok=True)

INK = (26, 36, 33)
MUTED = (59, 91, 109)
TEAL = (14, 92, 82)
BORDER = (220, 227, 225)
WHITE = (255, 255, 255)
CANVAS = (244, 246, 245)
BLUE = (59, 125, 216)
GOLD = (201, 138, 31)
ORANGE = (193, 89, 31)
RED = (168, 58, 42)
DARKRED = (122, 36, 32)

W = 1080


def font(name, size):
    return ImageFont.truetype(str(FONT / name), size)


SG = lambda s: font("SpaceGrotesk-SemiBold.ttf", s)
SGM = lambda s: font("SpaceGrotesk-Medium.ttf", s)
PLEX = lambda s: font("IBMPlexSans-Regular.ttf", s)
PLEXM = lambda s: font("IBMPlexSans-Medium.ttf", s)
PLEXS = lambda s: font("IBMPlexSans-SemiBold.ttf", s)


def text_w(fnt, s):
    b = fnt.getbbox(s)
    return b[2] - b[0]


def text_h(fnt, s="Ag"):
    b = fnt.getbbox(s)
    return b[3] - b[1]


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


class Board:
    def __init__(self, height):
        self.im = Image.new("RGB", (W, height), CANVAS)
        self.d = ImageDraw.Draw(self.im)

    def paste_height(self, used):
        cropped = self.im.crop((0, 0, W, used))
        self.im = cropped
        self.d = ImageDraw.Draw(self.im)

    def save(self, name):
        path = OUT / name
        # Flat color art stays well under 100 KB at high quality.
        self.im.save(path, "WEBP", quality=82, method=6)
        size = path.stat().st_size
        if size >= 100 * 1024:
            for q in (70, 60, 50):
                self.im.save(path, "WEBP", quality=q, method=6)
                size = path.stat().st_size
                if size < 100 * 1024:
                    break
        print(f"{name} {self.im.size[0]}x{self.im.size[1]} {size} bytes")
        return path


def header(board, title, subtitle, y=36):
    board.d.text((40, y), title, font=SG(30), fill=INK)
    y += 44
    if subtitle:
        for line in wrap(subtitle, PLEX(16), W - 80):
            board.d.text((40, y), line, font=PLEX(16), fill=MUTED)
            y += 24
        y += 8
    return y


def formula():
    b = Board(520)
    y = header(
        b,
        "Fórmula del IMC",
        "Ejemplo publicado: 75 kg y 1.75 m.",
    )
    steps = [
        ("1", "Peso", "75 kg"),
        ("2", "Estatura", "1.75 m"),
        ("3", "Estatura al cuadrado", "1.75 × 1.75 = 3.0625"),
    ]
    x = 40
    box_w = 320
    gap = 20
    for n, label, value in steps:
        b.d.rounded_rectangle((x, y, x + box_w, y + 132), 6, fill=WHITE, outline=BORDER, width=1)
        b.d.rounded_rectangle((x + 16, y + 16, x + 44, y + 44), 4, fill=TEAL)
        tw = text_w(SGM(16), n)
        b.d.text((x + 30 - tw / 2, y + 22), n, font=SGM(16), fill=WHITE)
        b.d.text((x + 56, y + 22), label, font=PLEXM(16), fill=MUTED)
        b.d.text((x + 16, y + 72), value, font=SG(26), fill=INK)
        x += box_w + gap
    y += 156
    b.d.rounded_rectangle((40, y, W - 40, y + 108), 6, fill=WHITE, outline=BORDER, width=1)
    b.d.text((64, y + 18), "75 ÷ 3.0625", font=PLEX(18), fill=MUTED)
    b.d.text((64, y + 48), "IMC = 24.5", font=SG(36), fill=INK)
    b.d.rounded_rectangle((W - 280, y + 36, W - 64, y + 76), 6, fill=TEAL)
    label = "Peso normal"
    lw = text_w(PLEXS(16), label)
    b.d.text((W - 172 - lw / 2, y + 46), label, font=PLEXS(16), fill=WHITE)
    b.paste_height(y + 140)
    b.save("formula-imc-ejemplo-75-kg-175-cm.webp")


def adult_scale():
    """Proportional bands from 15 to 45 so open ends stay visible."""
    b = Board(460)
    y = header(
        b,
        "Categorías de IMC en adultos",
        "Escala proporcional entre 15 y 45. Clasificación de la OMS usada en la tabla de esta página.",
    )
    bands = [
        (15.0, 18.5, "Menos de 18.5", "Bajo peso", BLUE),
        (18.5, 24.9, "18.5 – 24.9", "Peso normal", TEAL),
        (25.0, 29.9, "25 – 29.9", "Sobrepeso", GOLD),
        (30.0, 34.9, "30 – 34.9", "Obesidad grado 1", ORANGE),
        (35.0, 39.9, "35 – 39.9", "Obesidad grado 2", RED),
        (40.0, 45.0, "40 o más", "Obesidad grado 3", DARKRED),
    ]
    left, right = 40, W - 40
    span = right - left
    scale = 45 - 15
    top = y + 36
    bar_h = 28
    b.d.rounded_rectangle((left, top, right, top + bar_h), 4, fill=BORDER)
    for start, end, _rng, _name, color in bands:
        x0 = left + (start - 15) / scale * span
        x1 = left + (end - 15) / scale * span
        b.d.rectangle((x0, top, x1, top + bar_h), fill=color)
    # Example marker at 24.5
    mx = left + (24.5 - 15) / scale * span
    b.d.polygon([(mx, top - 10), (mx - 7, top - 22), (mx + 7, top - 22)], fill=INK)
    b.d.line((mx, top - 8, mx, top + bar_h + 8), fill=INK, width=2)
    note = "Ejemplo de la página: 24.5"
    b.d.text((mx + 10, top - 28), note, font=PLEXM(14), fill=INK)
    y = top + bar_h + 28
    col_w = (W - 80) / 3
    for i, (_s, _e, rng, name, color) in enumerate(bands):
        col = i % 3
        row = i // 3
        x = 40 + col * col_w
        yy = y + row * 72
        b.d.rounded_rectangle((x, yy + 6, x + 14, yy + 20), 2, fill=color)
        b.d.text((x + 22, yy), rng, font=PLEXS(16), fill=INK)
        b.d.text((x + 22, yy + 24), name, font=PLEX(15), fill=MUTED)
    b.paste_height(y + 160)
    b.save("categorias-imc-adultos-oms.webp")


def child_compare():
    b = Board(420)
    y = header(
        b,
        "El mismo IMC no se lee igual en niños",
        "En niños el IMC se compara con la curva de su edad y su sexo, no con los cortes de adultos.",
    )
    cards = [
        ("8 años", "IMC 18", "Puede ser bajo", BLUE),
        ("15 años", "IMC 18", "Puede ser normal", TEAL),
    ]
    x = 40
    cw = (W - 100) / 2
    for age, value, reading, color in cards:
        b.d.rounded_rectangle((x, y, x + cw, y + 180), 6, fill=WHITE, outline=BORDER, width=1)
        b.d.rectangle((x, y, x + 6, y + 180), fill=color)
        b.d.text((x + 28, y + 24), age, font=PLEXM(16), fill=MUTED)
        b.d.text((x + 28, y + 56), value, font=SG(40), fill=INK)
        b.d.text((x + 28, y + 120), reading, font=PLEXS(20), fill=color)
        x += cw + 20
    y += 204
    b.d.text(
        (40, y),
        "Por eso la calculadora infantil pide edad y sexo, y devuelve un percentil.",
        font=PLEX(16),
        fill=MUTED,
    )
    b.paste_height(y + 48)
    b.save("imc-18-ninos-8-anos-y-15-anos.webp")


def percentiles():
    b = Board(640)
    y = header(
        b,
        "Percentil de IMC en niños de 2 a 19 años",
        "Categorías de los CDC citadas en esta página. P50 es la mediana, no un corte de categoría.",
    )
    # Bar 0–100 with markers
    left, right = 40, W - 40
    top = y + 28
    b.d.rounded_rectangle((left, top, right, top + 22), 4, fill=BORDER)
    cuts = [
        (0, 5, BLUE),
        (5, 85, TEAL),
        (85, 95, GOLD),
        (95, 100, RED),
    ]
    span = right - left
    for a, c, color in cuts:
        b.d.rectangle((left + a / 100 * span, top, left + c / 100 * span, top + 22), fill=color)
    for mark, label in ((5, "P5"), (50, "P50"), (85, "P85"), (95, "P95")):
        mx = left + mark / 100 * span
        b.d.line((mx, top - 6, mx, top + 28), fill=INK, width=2)
        lw = text_w(PLEXS(13), label)
        b.d.text((mx - lw / 2, top + 34), label, font=PLEXS(13), fill=INK)
    rows = [
        (BLUE, "Menos del percentil 5", "Bajo peso"),
        (TEAL, "Percentil 5 a 84", "Peso saludable"),
        (GOLD, "Percentil 85 a 94", "Sobrepeso"),
        (RED, "Percentil 95 o más", "Obesidad"),
    ]
    y = top + 72
    for color, rng, name in rows:
        b.d.rounded_rectangle((40, y, W - 40, y + 48), 6, fill=WHITE, outline=BORDER, width=1)
        b.d.rectangle((40, y, 48, y + 48), fill=color)
        b.d.text((68, y + 12), rng, font=PLEX(16), fill=MUTED)
        nw = text_w(PLEXS(16), name)
        b.d.text((W - 64 - nw, y + 12), name, font=PLEXS(16), fill=INK)
        y += 58
    b.paste_height(y + 16)
    b.save("percentil-imc-ninos-categorias-cdc.webp")


def peso_ideal():
    b = Board(520)
    y = header(
        b,
        "Peso normal según la estatura",
        "Rango de IMC 18.5 a 24.9 convertido a kilogramos. Las cifras son las de la tabla de esta página.",
    )
    rows = [
        ("1.50 m", 41.6, 56.0),
        ("1.60 m", 47.4, 63.7),
        ("1.70 m", 53.5, 72.0),
        ("1.80 m", 59.9, 80.7),
        ("1.90 m", 66.8, 89.9),
    ]
    lo, hi = 40, 95
    axis_l, axis_r = 160, W - 200
    span = axis_r - axis_l
    for i, (label, a, c) in enumerate(rows):
        yy = y + i * 58
        b.d.text((40, yy + 8), label, font=PLEXS(16), fill=INK)
        b.d.rounded_rectangle((axis_l, yy + 14, axis_r, yy + 28), 3, fill=BORDER)
        x0 = axis_l + (a - lo) / (hi - lo) * span
        x1 = axis_l + (c - lo) / (hi - lo) * span
        b.d.rounded_rectangle((x0, yy + 10, x1, yy + 32), 3, fill=TEAL)
        b.d.text((axis_r + 16, yy + 6), f"{a:.1f} a {c:.1f} kg", font=PLEX(15), fill=MUTED)
    y = y + len(rows) * 58 + 8
    b.d.text((40, y), "El rango crece con la estatura. No es un peso único.", font=PLEX(15), fill=MUTED)
    b.paste_height(y + 44)
    b.save("peso-ideal-por-estatura-imc-normal.webp")


def embarazo_gain():
    b = Board(480)
    y = header(
        b,
        "Aumento de peso recomendado en el embarazo",
        "Embarazo único. Rangos para todo el embarazo según el IMC de antes, no por mes.",
    )
    rows = [
        ("Menos de 18.5", "Bajo peso", 12.5, 18, BLUE),
        ("18.5 a 24.9", "Peso normal", 11.5, 16, TEAL),
        ("25 a 29.9", "Sobrepeso", 7, 11.5, GOLD),
        ("30 o más", "Obesidad", 5, 9, RED),
    ]
    lo, hi = 0, 18
    axis_l, axis_r = 250, W - 180
    span = axis_r - axis_l
    for i, (rng, name, a, c, color) in enumerate(rows):
        yy = y + i * 72
        b.d.text((40, yy), name, font=PLEXS(16), fill=INK)
        b.d.text((40, yy + 22), rng, font=PLEX(14), fill=MUTED)
        b.d.rounded_rectangle((axis_l, yy + 16, axis_r, yy + 30), 3, fill=BORDER)
        x0 = axis_l + a / hi * span
        x1 = axis_l + c / hi * span
        b.d.rounded_rectangle((x0, yy + 12, x1, yy + 34), 3, fill=color)
        label = f"{a:g} a {c:g} kg"
        b.d.text((axis_r + 14, yy + 10), label, font=PLEXS(15), fill=INK)
    b.paste_height(y + len(rows) * 72 + 8)
    b.save("aumento-de-peso-embarazo-segun-imc.webp")


def trimestre():
    b = Board(420)
    y = header(
        b,
        "El aumento no es igual en cada trimestre",
        "En el primero el aumento suele ser pequeño. La mayor parte ocurre después.",
    )
    # Visual weight: small first trimester, larger rest. Widths are illustrative of "pequeño" vs "mayor parte",
    # and the only number printed is the one on the page: 0.5 a 2 kg.
    cards = [
        (280, "Trimestre 1", "0.5 a 2 kg en total", "Aumento pequeño"),
        (W - 360, "Trimestres 2 y 3", "La mayor parte del aumento", "El ritmo semanal depende del IMC previo"),
    ]
    x = 40
    for width, title, value, note in cards:
        b.d.rounded_rectangle((x, y, x + width, y + 168), 6, fill=WHITE, outline=BORDER, width=1)
        b.d.rectangle((x, y, x + width, y + 8), fill=TEAL)
        b.d.text((x + 20, y + 28), title, font=PLEXM(15), fill=MUTED)
        for i, line in enumerate(wrap(value, SG(26), width - 40)):
            b.d.text((x + 20, y + 58 + i * 34), line, font=SG(26), fill=INK)
        b.d.text((x + 20, y + 128), note, font=PLEX(14), fill=MUTED)
        x += width + 20
    b.paste_height(y + 204)
    b.save("aumento-de-peso-embarazo-por-trimestre.webp")


def redondeo():
    b = Board(360)
    y = header(
        b,
        "Cómo se muestra el resultado",
        "La calculadora redondea a un decimal. El cálculo interno no cambia.",
    )
    boxes = [
        ("Cálculo", "24.549", MUTED),
        ("Se muestra", "24.5", TEAL),
    ]
    x = 40
    cw = 470
    for label, value, color in boxes:
        b.d.rounded_rectangle((x, y, x + cw, y + 140), 6, fill=WHITE, outline=BORDER, width=1)
        b.d.text((x + 24, y + 20), label, font=PLEXM(16), fill=MUTED)
        b.d.text((x + 24, y + 56), value, font=SG(48), fill=color)
        x += cw + 20
    # arrow between is tight; the two cards are the point
    y += 160
    b.d.text((40, y), "24.549 se muestra como 24.5. Es presentación, no otra fórmula.", font=PLEX(16), fill=MUTED)
    b.paste_height(y + 48)
    b.save("redondeo-imc-a-un-decimal.webp")


def seedo():
    b = Board(640)
    y = header(
        b,
        "Clasificación SEEDO en España",
        "Más detallada que la tabla general de la OMS: dos grados de sobrepeso y cuatro tipos de obesidad.",
    )
    rows = [
        ("Menos de 18.5", "Peso insuficiente", BLUE),
        ("18.5 a 24.9", "Normopeso", TEAL),
        ("25 a 26.9", "Sobrepeso grado I", GOLD),
        ("27 a 29.9", "Sobrepeso grado II (preobesidad)", GOLD),
        ("30 a 34.9", "Obesidad tipo I", ORANGE),
        ("35 a 39.9", "Obesidad tipo II", RED),
        ("40 a 49.9", "Obesidad tipo III (mórbida)", DARKRED),
        ("50 o más", "Obesidad tipo IV (extrema)", DARKRED),
    ]
    for rng, name, color in rows:
        b.d.rounded_rectangle((40, y, W - 40, y + 44), 6, fill=WHITE, outline=BORDER, width=1)
        b.d.rectangle((40, y, 48, y + 44), fill=color)
        b.d.text((64, y + 11), rng, font=PLEXS(16), fill=INK)
        nw = text_w(PLEX(16), name)
        b.d.text((W - 64 - nw, y + 11), name, font=PLEX(16), fill=MUTED)
        y += 52
    b.paste_height(y + 12)
    b.save("clasificacion-imc-seedo-espana.webp")


def verificacion():
    b = Board(420)
    y = header(
        b,
        "Cómo se verifica cada cifra",
        "No se publica una cifra médica si no está en una fuente primaria.",
    )
    steps = [
        ("1", "Cifra médica", "Puntos de corte del IMC o rangos de peso en el embarazo."),
        ("2", "Fuente primaria", "OMS, CDC, IOM, NOM-008-SSA3-2017, IMSS o SEEDO."),
        ("3", "Publicación", "Si no se confirma, no se publica como un hecho."),
    ]
    x = 40
    cw = 320
    for n, title, body in steps:
        b.d.rounded_rectangle((x, y, x + cw, y + 210), 6, fill=WHITE, outline=BORDER, width=1)
        b.d.rounded_rectangle((x + 18, y + 18, x + 50, y + 50), 4, fill=TEAL)
        tw = text_w(SGM(16), n)
        b.d.text((x + 34 - tw / 2, y + 24), n, font=SGM(16), fill=WHITE)
        b.d.text((x + 18, y + 66), title, font=SG(22), fill=INK)
        yy = y + 108
        for line in wrap(body, PLEX(15), cw - 36):
            b.d.text((x + 18, yy), line, font=PLEX(15), fill=MUTED)
            yy += 22
        x += cw + 20
    b.paste_height(y + 246)
    b.save("verificacion-de-fuentes-imc-calculadora.webp")


def app_compare():
    b = Board(460)
    y = header(
        b,
        "Sitio web y app de IMC Calculadora",
        "La app está en beta. Usa la misma fórmula. El historial se queda en el teléfono.",
    )
    headers = ["", "Sitio web", "App"]
    rows = [
        ("Calcular el IMC", "Sí", "Sí, también sin conexión"),
        ("Guardar historial", "No", "Sí, solo en el teléfono"),
        ("Compartir el resultado", "No", "Sí"),
        ("Calculadoras", "Adultos, niños y peso ideal", "Las mismas tres"),
    ]
    cols = [40, 420, 720]
    b.d.text((cols[1], y), "Sitio web", font=PLEXS(16), fill=MUTED)
    b.d.text((cols[2], y), "App", font=PLEXS(16), fill=TEAL)
    y += 36
    for i, (feature, web, app) in enumerate(rows):
        bg = WHITE if i % 2 == 0 else CANVAS
        b.d.rectangle((40, y, W - 40, y + 52), fill=WHITE)
        b.d.line((40, y + 51, W - 40, y + 51), fill=BORDER, width=1)
        b.d.text((56, y + 15), feature, font=PLEXS(16), fill=INK)
        b.d.text((cols[1], y + 15), web, font=PLEX(16), fill=MUTED)
        b.d.text((cols[2], y + 15), app, font=PLEXS(16), fill=INK)
        y += 52
    b.paste_height(y + 28)
    b.save("app-imc-calculadora-sitio-y-telefono.webp")


if __name__ == "__main__":
    formula()
    adult_scale()
    child_compare()
    percentiles()
    peso_ideal()
    embarazo_gain()
    trimestre()
    redondeo()
    seedo()
    verificacion()
    app_compare()
