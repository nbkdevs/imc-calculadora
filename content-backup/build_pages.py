#!/usr/bin/env python3
"""Rebuild IMC Calculadora pages as Kadence sections, preserving visible copy."""

import json
import re
from html.parser import HTMLParser
from pathlib import Path

ROOT = Path(__file__).resolve().parent
PAGES = [12, 21, 25, 29, 30, 31, 32]

INK = "#1A2421"
ACCENT = "#0E5C52"
ACCENT_DARK = "#0A473F"
WHITE = "#FFFFFF"


def parse_blocks(src: str):
    blocks = []
    i = 0
    length = len(src)
    while True:
        start = src.find("<!-- wp:", i)
        if start < 0:
            break
        name_start = start + len("<!-- wp:")
        name_end = name_start
        while name_end < length and src[name_end] not in " \t\r\n{>":
            name_end += 1
        raw_name = src[name_start:name_end]
        name = raw_name if "/" in raw_name else f"core/{raw_name}"
        k = name_end
        while k < length and src[k] in " \t\r\n":
            k += 1
        attrs = {}
        if k < length and src[k] == "{":
            depth = 0
            attr_start = k
            while k < length:
                if src[k] == "{":
                    depth += 1
                elif src[k] == "}":
                    depth -= 1
                    if depth == 0:
                        k += 1
                        break
                k += 1
            attrs = json.loads(src[attr_start:k])
        end_comment = src.find("-->", k)
        if end_comment < 0:
            break
        self_closing = src[k:end_comment].rstrip().endswith("/")
        i = end_comment + 3
        if self_closing:
            blocks.append({"name": name, "attrs": attrs, "html": "", "inner": []})
            continue
        close = f"<!-- /wp:{raw_name} -->"
        open_mark = f"<!-- wp:{raw_name}"
        depth = 1
        pos = i
        inner_end = None
        while pos < length:
            next_open = src.find(open_mark, pos)
            next_close = src.find(close, pos)
            if next_close < 0:
                raise RuntimeError(f"Unclosed block {name}")
            if next_open != -1 and next_open < next_close:
                boundary = next_open + len(open_mark)
                if boundary >= length or src[boundary] in " \t\r\n{>/":
                    depth += 1
                    pos = boundary
                    continue
            depth -= 1
            if depth == 0:
                inner_end = next_close
                break
            pos = next_close + len(close)
        inner_src = src[i:inner_end]
        i = inner_end + len(close)
        blocks.append(
            {
                "name": name,
                "attrs": attrs,
                "html": inner_src,
                "inner": parse_blocks(inner_src),
            }
        )
    return blocks


def inner_markup(html: str, tag: str) -> str:
    match = re.search(rf"<{tag}\b[^>]*>(.*)</{tag}>", html, re.S)
    if not match:
        return re.sub(r"<!--.*?-->", "", html, flags=re.S).strip()
    return match.group(1).strip()


def visible_text(value: str) -> str:
    text = re.sub(r"<[^>]+>", " ", value or "")
    text = text.replace("&nbsp;", " ").replace("&#8211;", "–").replace("&amp;", "&")
    text = text.replace("&#8217;", "'").replace("&quot;", '"')
    return re.sub(r"\s+", " ", text).strip()


class TableParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.section = None
        self.rows = {"head": [], "body": []}
        self.current = None
        self.cell = None
        self.buf = []

    def handle_starttag(self, tag, attrs):
        if tag in ("thead", "tbody"):
            self.section = "head" if tag == "thead" else "body"
        elif tag == "tr":
            self.current = []
        elif tag in ("td", "th"):
            self.cell = tag
            self.buf = []

    def handle_endtag(self, tag):
        if tag in ("td", "th") and self.current is not None:
            self.current.append(
                {"content": "".join(self.buf).strip(), "tag": "th" if tag == "th" else "td"}
            )
            self.cell = None
        elif tag == "tr" and self.current is not None:
            bucket = "head" if self.section == "head" else "body"
            self.rows[bucket].append({"cells": self.current})
            self.current = None

    def handle_data(self, data):
        if self.cell:
            self.buf.append(data)


def heading_spec(text: str, level: int, hero: bool = False):
    sizes = {
        1: [52, 40, 34],
        2: [32, 28, 26],
        3: [24, 22, 20],
    }
    return {
        "name": "kadence/advancedheading",
        "attributes": {
            "content": text,
            "level": level,
            "htmlTag": f"h{level}",
            "align": "center" if hero and level == 1 else "left",
            "color": INK,
            "typography": "Space Grotesk",
            "googleFont": True,
            "loadGoogleFont": True,
            "fontWeight": "600",
            "fontStyle": "normal",
            "fontSize": sizes.get(level, [24, 22, 20]),
            "fontHeight": [1.15, 1.2, 1.25],
            "fontHeightType": "",
            "margin": [0, 0, 16 if level == 1 else 12, 0],
            "marginType": "px",
        },
        "innerBlocks": [],
    }


def paragraph_spec(html: str):
    return {
        "name": "core/paragraph",
        "attributes": {"content": inner_markup(html, "p")},
        "innerBlocks": [],
    }


def list_spec(block):
    ordered = block["attrs"].get("ordered", False)
    items = []
    for child in block["inner"]:
        if child["name"] != "core/list-item":
            continue
        items.append(
            {
                "name": "core/list-item",
                "attributes": {"content": inner_markup(child["html"], "li")},
                "innerBlocks": [],
            }
        )
    return {
        "name": "core/list",
        "attributes": {"ordered": bool(ordered)},
        "innerBlocks": items,
    }


def table_spec(html: str):
    parser = TableParser()
    parser.feed(html)
    return {
        "name": "core/table",
        "attributes": {
            "hasFixedLayout": False,
            "head": parser.rows["head"],
            "body": parser.rows["body"],
        },
        "innerBlocks": [],
    }


def shortcode_spec(html: str, attrs: dict):
    text = attrs.get("text")
    if not text:
        match = re.search(r"\[[^\]]+\]", html)
        text = match.group(0) if match else html.strip()
    return {"name": "core/shortcode", "attributes": {"text": text.strip()}, "innerBlocks": []}


def button_attrs(text: str, link: str, primary: bool):
    attrs = {
        "text": text,
        "link": link,
        "sizePreset": "medium",
        "padding": [14, 22, 14, 22],
        "paddingUnit": "px",
        "borderRadius": [6, 6, 6, 6],
        "borderRadiusUnit": "px",
        "color": WHITE if primary else ACCENT,
        "background": ACCENT if primary else WHITE,
        "colorHover": WHITE if primary else WHITE,
        "backgroundHover": ACCENT_DARK if primary else ACCENT,
    }
    if not primary:
        attrs["borderStyle"] = [
            {
                "top": ["1", "solid", ACCENT],
                "right": ["1", "solid", ACCENT],
                "bottom": ["1", "solid", ACCENT],
                "left": ["1", "solid", ACCENT],
                "unit": "px",
            }
        ]
    return attrs


def button_from_single(block, primary: bool):
    text = block["attrs"].get("text", "")
    link = block["attrs"].get("link", "")
    return {
        "name": "kadence/advancedbtn",
        "attributes": {"hAlign": "left"},
        "innerBlocks": [
            {
                "name": "kadence/singlebtn",
                "attributes": button_attrs(text, link, primary),
                "innerBlocks": [],
            }
        ],
    }


def button_from_core(block, primary: bool):
    html = block["html"]
    match = re.search(r'<a\b[^>]*href="([^"]*)"[^>]*>(.*?)</a>', html, re.S)
    if not match:
        return None
    return {
        "name": "kadence/advancedbtn",
        "attributes": {"hAlign": "center" if primary else "left"},
        "innerBlocks": [
            {
                "name": "kadence/singlebtn",
                "attributes": button_attrs(
                    visible_text(match.group(2)), match.group(1), primary
                ),
                "innerBlocks": [],
            }
        ],
    }


def details_to_pane(block, index: int):
    summary = inner_markup(block["html"], "summary")
    paragraphs = []
    for child in block["inner"]:
        if child["name"] == "core/paragraph":
            paragraphs.append(paragraph_spec(child["html"]))
    if not paragraphs:
        body = re.sub(r"<summary\b[^>]*>.*?</summary>", "", block["html"], flags=re.S)
        content = inner_markup(body, "p")
        if content:
            paragraphs.append(
                {"name": "core/paragraph", "attributes": {"content": content}, "innerBlocks": []}
            )
    return {
        "name": "kadence/pane",
        "attributes": {"id": index, "title": summary, "titleTag": "div"},
        "innerBlocks": paragraphs,
    }


def convert_flow(blocks, primary_button: bool):
    specs = []
    i = 0
    while i < len(blocks):
        block = blocks[i]
        name = block["name"]
        if name == "core/details":
            panes = []
            while i < len(blocks) and blocks[i]["name"] == "core/details":
                panes.append(details_to_pane(blocks[i], len(panes) + 1))
                i += 1
            specs.append(
                {
                    "name": "kadence/accordion",
                    "attributes": {
                        "paneCount": len(panes),
                        "startCollapsed": True,
                        "linkPaneCollapse": True,
                        "openPane": 0,
                        "faqSchema": True,
                        "showPresets": False,
                        "iconStyle": "basic",
                        "iconColor": {"standard": ACCENT, "active": ACCENT, "hover": ACCENT_DARK},
                        "titleStyles": [
                            {
                                "size": ["", "", ""],
                                "sizeType": "px",
                                "lineHeight": ["", "", ""],
                                "lineType": "",
                                "letterSpacing": "",
                                "family": "IBM Plex Sans",
                                "google": True,
                                "style": "normal",
                                "weight": "600",
                                "variant": "",
                                "subset": "",
                                "loadGoogle": True,
                                "padding": [16, 18, 16, 18],
                                "marginTop": 0,
                                "color": INK,
                                "background": WHITE,
                                "border": ["", "", "", ""],
                                "borderRadius": ["", "", "", ""],
                                "borderWidth": ["", "", "", ""],
                                "colorHover": INK,
                                "backgroundHover": "#F4F6F5",
                                "borderHover": ["", "", "", ""],
                                "colorActive": INK,
                                "backgroundActive": WHITE,
                                "borderActive": ["", "", "", ""],
                                "textTransform": "",
                                "paddingTablet": ["", "", "", ""],
                                "paddingMobile": ["", "", "", ""],
                                "paddingType": "px",
                            }
                        ],
                    },
                    "innerBlocks": panes,
                }
            )
            continue
        if name in ("core/heading", "kadence/advancedheading"):
            level = int(block["attrs"].get("level") or 2)
            if name == "kadence/advancedheading":
                text = inner_markup(block["html"], f"h{level}") or block["attrs"].get("content", "")
            else:
                text = inner_markup(block["html"], f"h{level}")
            specs.append(heading_spec(text, level, hero=level == 1))
        elif name == "core/paragraph":
            specs.append(paragraph_spec(block["html"]))
        elif name == "core/list":
            specs.append(list_spec(block))
        elif name == "core/table":
            specs.append(table_spec(block["html"]))
        elif name == "core/shortcode":
            specs.append(shortcode_spec(block["html"], block["attrs"]))
        elif name == "kadence/advancedbtn":
            for child in block["inner"]:
                if child["name"] == "kadence/singlebtn":
                    specs.append(button_from_single(child, primary=False))
        elif name == "core/buttons":
            for child in block["inner"]:
                if child["name"] == "core/button":
                    converted = button_from_core(child, primary=primary_button)
                    if converted:
                        specs.append(converted)
        elif name == "kadence/rowlayout":
            specs.append(convert_row(block, tools=True))
        i += 1
    return specs


def column_children(row):
    children = []
    for column in row["inner"]:
        if column["name"] == "kadence/column":
            children.extend(column["inner"])
    return children


def convert_row(row, tools: bool):
    columns = []
    for column in row["inner"]:
        if column["name"] != "kadence/column":
            continue
        columns.append(
            {
                "name": "kadence/column",
                "attributes": {"borderWidth": ["", "", "", ""]},
                "innerBlocks": convert_flow(column["inner"], primary_button=False),
            }
        )
    count = len(columns) or 1
    attrs = {
        "columns": count,
        "colLayout": "equal",
        "htmlTag": "div",
        "align": "wide" if tools else "none",
        "blockAlignment": "wide" if tools else "none",
        "inheritMaxWidth": True,
        "padding": [8, 0, 8, 0],
        "paddingUnit": "px",
        "columnGutter": "custom",
        "customGutter": [20, "", ""],
        "gutterType": "px",
        "verticalAlignment": "top",
    }
    if tools:
        attrs["className"] = "imc-tools"
    return {"name": "kadence/rowlayout", "attributes": attrs, "innerBlocks": columns}


def section(inner, kind: str):
    hero = kind == "hero"
    alt = kind == "alt"
    attrs = {
        "columns": 1,
        "colLayout": "equal",
        "htmlTag": "section",
        "align": "full",
        "blockAlignment": "full",
        "inheritMaxWidth": True,
        "bgColor": "palette8" if hero or alt else "palette9",
        "bgColorClass": "palette8" if hero or alt else "palette9",
        "padding": [72, 24, 28, 24] if hero else [28, 24, 36, 24],
        "mobilePadding": [40, 16, 20, 16] if hero else [20, 16, 28, 16],
        "paddingUnit": "px",
        "verticalAlignment": "top",
        "className": "imc-hero" if hero else "imc-section",
    }
    return {
        "name": "kadence/rowlayout",
        "attributes": attrs,
        "innerBlocks": [
            {
                "name": "kadence/column",
                "attributes": {"borderWidth": ["", "", "", ""]},
                "innerBlocks": inner,
            }
        ],
    }


def is_heading(block, level=None):
    if block["name"] not in ("core/heading", "kadence/advancedheading"):
        return False
    found = int(block["attrs"].get("level") or (1 if block["name"] == "kadence/advancedheading" else 2))
    if block["name"] == "core/heading" and "level" not in block["attrs"]:
        match = re.search(r"<h([1-6])", block["html"])
        found = int(match.group(1)) if match else 2
    return found == level if level else True


def heading_level(block):
    if "level" in block["attrs"]:
        return int(block["attrs"]["level"])
    match = re.search(r"<h([1-6])", block["html"])
    return int(match.group(1)) if match else 2


def stream_of(blocks):
    if blocks and blocks[0]["name"] == "kadence/rowlayout":
        return column_children(blocks[0]) + blocks[1:]
    return blocks


def build_page(blocks):
    stream = stream_of(blocks)
    prelude = []
    sections = []
    current = None
    for block in stream:
        if is_heading(block) and heading_level(block) == 2:
            current = [block]
            sections.append(current)
            continue
        if current is None:
            prelude.append(block)
        else:
            current.append(block)
    output = []
    if prelude:
        output.append(section(convert_flow(prelude, primary_button=True), "hero"))
    for index, group in enumerate(sections):
        pieces = convert_flow(group, primary_button=False)
        prose = [piece for piece in pieces if piece["name"] != "kadence/rowlayout"]
        rows = [piece for piece in pieces if piece["name"] == "kadence/rowlayout"]
        kind = "alt" if index % 2 else "base"
        if prose:
            output.append(section(prose, kind))
        output.extend(rows)
    return output


def collect_text(node, bag):
    if isinstance(node, dict):
        name = node.get("name")
        attrs = node.get("attributes") or {}
        if name in ("core/paragraph", "core/list-item", "kadence/advancedheading"):
            bag.append(visible_text(attrs.get("content", "")))
        elif name == "kadence/pane":
            bag.append(visible_text(attrs.get("title", "")))
        elif name == "kadence/singlebtn":
            bag.append(visible_text(attrs.get("text", "")))
        elif name == "core/shortcode":
            bag.append(visible_text(attrs.get("text", "")))
        elif name == "core/table":
            for part in ("head", "body"):
                for row in attrs.get(part) or []:
                    for cell in row.get("cells") or []:
                        bag.append(visible_text(cell.get("content", "")))
        for child in node.get("innerBlocks") or []:
            collect_text(child, bag)
    elif isinstance(node, list):
        for child in node:
            collect_text(child, bag)


def original_text(html: str):
    cleaned = re.sub(r"<!--.*?-->", " ", html, flags=re.S)
    cleaned = re.sub(r"<script\b[^>]*>.*?</script>", " ", cleaned, flags=re.S)
    return visible_text(cleaned)


def main():
    report = []
    for page_id in PAGES:
        matches = list(ROOT.glob(f"page-{page_id}-*.html"))
        html = matches[0].read_text()
        spec = build_page(parse_blocks(html))
        built = []
        collect_text(spec, built)
        source = original_text(html)
        built_text = re.sub(r"\s+", " ", " ".join(part for part in built if part)).strip()
        ok = built_text == source
        out = ROOT / f"spec-{page_id}.json"
        out.write_text(json.dumps(spec, ensure_ascii=False))
        report.append(
            {
                "id": page_id,
                "ok": ok,
                "source_len": len(source),
                "built_len": len(built_text),
                "blocks": len(spec),
            }
        )
        if not ok:
            # show first mismatch window
            for index, (a, b) in enumerate(zip(source, built_text)):
                if a != b:
                    report[-1]["diff_at"] = index
                    report[-1]["source_snip"] = source[max(0, index - 40) : index + 80]
                    report[-1]["built_snip"] = built_text[max(0, index - 40) : index + 80]
                    break
            else:
                report[-1]["source_tail"] = source[-120:]
                report[-1]["built_tail"] = built_text[-120:]
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
