"""Dựng SVG từ scene có tọa độ hoặc cây mind map; chỉ dùng Python stdlib."""

import math
import textwrap
import xml.etree.ElementTree as ET

NS = "http://www.w3.org/2000/svg"
ET.register_namespace("", NS)
FONT = "Arial, Helvetica, sans-serif"
COLORS = ["#2563eb", "#0f766e", "#9333ea", "#b45309", "#be123c", "#475569"]


def element(parent, tag, text=None, **attrs):
    node = ET.SubElement(parent, "{%s}%s" % (NS, tag), {
        k.replace("_", "-"): str(v) for k, v in attrs.items() if v is not None
    })
    node.text = text
    return node


def number(value, name, minimum=None):
    if isinstance(value, bool) or not isinstance(value, (int, float)) or not math.isfinite(value):
        raise ValueError("%s phải là số hữu hạn" % name)
    if minimum is not None and value < minimum:
        raise ValueError("%s phải >= %s" % (name, minimum))
    return value


def lines(value, width=None):
    if not isinstance(value, str) or not value.strip():
        raise ValueError("Nhãn phải là chuỗi không rỗng")
    result = []
    for line in value.splitlines():
        result.extend(textwrap.wrap(line, width, break_long_words=False,
                                    break_on_hyphens=False) if width else [line])
    return result


def label(parent, value, x, y, size=24, color="#0f172a", anchor="start", bold=False):
    """y là baseline dòng đầu; xuống dòng bằng ký tự newline, không tự cắt nhãn."""
    node = element(parent, "text", x=x, y=y, font_size=size, fill=color,
                   text_anchor=anchor, font_weight="700" if bold else "400")
    for i, line in enumerate(lines(value)):
        element(node, "tspan", line, x=x, dy=0 if i == 0 else size * 1.35)
    return node


def canvas(width, height, title, subtitle=""):
    root = ET.Element("{%s}svg" % NS, {
        "width": str(width), "height": str(height), "viewBox": "0 0 %s %s" % (width, height),
        "font-family": FONT, "role": "img",
    })
    element(root, "title", title)
    element(root, "rect", x=0, y=0, width=width, height=height, fill="#ffffff")
    label(root, title, 40, 52, 30, bold=True)
    if subtitle:
        label(root, subtitle, 40, 86, 18, color="#475569")
    return root


def scene(spec):
    width = number(spec.get("width", 1200), "width", 200)
    height = number(spec.get("height", 700), "height", 160)
    root = canvas(width, height, spec["title"], spec.get("subtitle", ""))
    defs = element(root, "defs")
    for i, item in enumerate(spec["elements"]):
        kind = item["type"]
        color = item.get("color", "#334155")
        if kind in ("rect", "ellipse"):
            x, y = (number(item[k], k, 0) for k in ("x", "y"))
            w, h = (number(item[k], k, 1) for k in ("width", "height"))
            if x + w > width or y + h > height:
                raise ValueError("Phần tử %s vượt canvas" % i)
            attrs = dict(fill=item.get("fill", "#eff6ff"), stroke=color, stroke_width=2)
            if kind == "rect":
                element(root, kind, x=x, y=y, width=w, height=h, rx=item.get("radius", 12), **attrs)
            else:
                element(root, kind, cx=x+w/2, cy=y+h/2, rx=w/2, ry=h/2, **attrs)
            if item.get("text"):
                size = number(item.get("font_size", 24), "font_size", 1)
                count = len(lines(item["text"]))
                label(root, item["text"], x+w/2, y+h/2-(count-1)*size*0.675+size*0.35,
                      size, anchor="middle", bold=item.get("bold", False))
        elif kind == "text":
            label(root, item["text"], number(item["x"], "x"), number(item["y"], "y"),
                  number(item.get("font_size", 24), "font_size", 1), color,
                  item.get("anchor", "start"), item.get("bold", False))
        elif kind in ("arrow", "line"):
            points = item["points"]
            if len(points) < 2 or any(len(p) != 2 for p in points):
                raise ValueError("points cần ít nhất hai cặp [x, y]")
            for point in points:
                for value in point:
                    number(value, "tọa độ points")
            marker_id = "arrow-%s" % i
            if kind == "arrow":
                marker = element(defs, "marker", id=marker_id, viewBox="0 0 10 10",
                                 refX=9, refY=5, markerWidth=9, markerHeight=9,
                                 orient="auto-start-reverse", markerUnits="userSpaceOnUse")
                element(marker, "path", d="M 0 0 L 10 5 L 0 10 Z", fill=color)
            element(root, "polyline", points=" ".join("%s,%s" % tuple(p) for p in points),
                    fill="none", stroke=color, stroke_width=item.get("stroke_width", 3),
                    stroke_dasharray="8 6" if item.get("dashed") else None,
                    marker_end="url(#%s)" % marker_id if kind == "arrow" else None)
        else:
            raise ValueError("Loại phần tử chưa hỗ trợ: %s" % kind)
    return root


def mindmap(spec):
    """Bố trí tự động hai bên; tối đa hai tầng để nhãn còn dễ đọc."""
    branches = spec["branches"]
    if not branches or len(branches) > 8:
        raise ValueError("Mind map cần 1–8 nhánh chính; chia hình nếu nhiều hơn")
    groups = [[], []]
    for i, branch in enumerate(branches):
        main = lines(branch["text"], 24)
        children = [lines(child, 26) for child in branch.get("children", [])]
        child_height = sum(max(48, len(child)*27+18) for child in children)
        height = max(len(main)*30+30, child_height) + 32
        groups[i % 2].append((main, children, height, COLORS[i % len(COLORS)]))
    height = max(460, max(sum(item[2] for item in group) for group in groups) + 150)
    root = canvas(1600, height, spec["title"], spec.get("subtitle", ""))
    cy = (height+110)/2
    center_lines = lines(spec.get("center", spec["title"]), 19)
    center_h = max(96, len(center_lines)*34+28)
    # Vẽ nhánh trước node trung tâm; cạnh cha–con không có mũi tên thời gian.
    for side, group in enumerate(groups):
        top = 120 + (height-150-sum(item[2] for item in group))/2
        sign = -1 if side == 0 else 1
        for main, children, block_h, color in group:
            y = top + block_h/2
            start, end = 800+sign*145, 800+sign*200
            element(root, "path", d="M %s %s C %s %s %s %s %s %s" %
                    (start, cy, (start+end)/2, cy, (start+end)/2, y, end, y),
                    fill="none", stroke=color, stroke_width=3)
            x = 600 if side == 0 else 1000
            label(root, "\n".join(main), x, y-(len(main)-1)*14-12, 21,
                  color, "end" if side == 0 else "start", True)
            edge = 340 if side == 0 else 1260
            element(root, "line", x1=x, y1=y, x2=edge, y2=y, stroke=color, stroke_width=2)
            child_top = y-sum(max(48, len(c)*27+18) for c in children)/2
            for child in children:
                ch = max(48, len(child)*27+18)
                child_y = child_top + ch/2
                leaf_x = 310 if side == 0 else 1290
                element(root, "path", d="M %s %s Q %s %s %s %s" %
                        (edge, y, edge, child_y, leaf_x, child_y),
                        fill="none", stroke=color, stroke_width=2)
                label(root, "\n".join(child), leaf_x, child_y-(len(child)-1)*13.5-7,
                      19, "#334155", "end" if side == 0 else "start")
                child_top += ch
            top += block_h
    element(root, "rect", x=655, y=cy-center_h/2, width=290, height=center_h,
            rx=20, fill="#eff6ff", stroke="#2563eb", stroke_width=3)
    label(root, "\n".join(center_lines), 800, cy-(len(center_lines)-1)*16+8,
          24, anchor="middle", bold=True)
    return root


def build(spec):
    if not isinstance(spec, dict) or spec.get("kind") not in ("concept", "mechanism", "mindmap"):
        raise ValueError("kind phải là concept, mechanism hoặc mindmap")
    root = mindmap(spec) if spec["kind"] == "mindmap" else scene(spec)
    return ET.tostring(root, encoding="utf-8", xml_declaration=True)
