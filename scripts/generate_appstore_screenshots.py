#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
根据给定目录下的 JSON 配置与截图，批量生成适配 App Store 的展示图片。

用法示例：
  python scripts/generate_appstore_screenshots.py \
    --input-dir /path/to/folder \
    --config config.json \
    --output-dir /path/to/output

目录结构要求：
  input-dir/
    ├── config.json             // JSON 配置文件（名称可通过 --config 覆盖）
    ├── screenshot1.png         // 截图文件
    └── screenshot2.jpg

JSON 配置示例（字段命名大小写不敏感，以下为参考）：
{
  "styleConfig": {
    "width": 1242,
    "height": 2688,
    "backgroundColor": "#FFFFFF",
    "titleColor": "#000000",
    "subtitleColor": "#333333",
    "titleFontSize": 72,
    "subtitleFontSize": 40,
    "titleFontPath": "/System/Library/Fonts/PingFang.ttc",
    "subtitleFontPath": "/System/Library/Fonts/PingFang.ttc",
    "padding": 48,
    "lineSpacing": 10,
    "maxTextWidthRatio": 0.9,
    "textAlign": "center",            // center/left/right
    "screenshotMode": "fit",           // fit/fill（目前仅支持 fit）
    "screenshotMaxHeightRatio": 0.72,   // 截图在成品图中占比的最大高度
    "screenshotTopOffset": null         // 可选，像素偏移（覆盖自动布局）
  },
  "configs": [
    { "title": "标题", "subtitle": "副标题", "screenshot": "screenshot1.png", "outputName": "01.png" }
  ]
}

注意：
- 不在代码中硬编码任何业务 mock 数据；如未提供样式字段，将采用通用安全默认值。
- 文本排版按最大宽度自动换行，且支持居中/左/右对齐。
"""

from __future__ import annotations

import argparse
import json
import logging
import os
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple

from PIL import Image, ImageColor, ImageDraw, ImageFont, ImageFilter


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="根据 JSON 配置批量生成 App Store 截图展示图")
    parser.add_argument("--input-dir", required=True, help="输入目录，包含 JSON 配置与原始截图")
    parser.add_argument("--config", default="config.json", help="配置文件名（位于输入目录下），默认 config.json")
    parser.add_argument("--output-dir", default=None, help="输出目录，默认为输入目录下的 output 子目录")
    # 字体策略：始终使用开源字体（Noto/思源 等）。该参数保留但不再生效。
    parser.add_argument("--verbose", action="store_true", help="输出详细日志")
    return parser.parse_args()


def ensure_dir(path: Path) -> None:
    path.mkdir(parents=True, exist_ok=True)


def load_json(path: Path) -> Dict[str, Any]:
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)


def normalize_key_case(d: Dict[str, Any]) -> Dict[str, Any]:
    # 将字典的 key 统一转为小写，便于不区分大小写读取
    return {str(k).lower(): v for k, v in d.items()}


def get_value_case_insensitive(d: Dict[str, Any], key: str, default: Any = None) -> Any:
    if not isinstance(d, dict):
        return default
    lower = normalize_key_case(d)
    return lower.get(key.lower(), default)


def parse_color(value: Optional[str], default: Tuple[int, int, int, int]) -> Tuple[int, int, int, int]:
    if not value:
        return default
    try:
        rgba = ImageColor.getcolor(value, "RGBA")
        if isinstance(rgba, tuple) and len(rgba) == 4:
            return rgba
        if isinstance(rgba, tuple) and len(rgba) == 3:
            r, g, b = rgba
            return (r, g, b, 255)
    except Exception:
        logging.warning("无法解析颜色 %r，使用默认值", value)
    return default


def _font_candidates() -> List[str]:
    # 常见系统中可用的中文或全量字符覆盖的可缩放字体
    return [
        # macOS CJK
        "/System/Library/Fonts/Hiragino Sans GB.ttc",
        "/System/Library/Fonts/STHeiti Medium.ttc",
        "/System/Library/Fonts/STHeiti Light.ttc",
        "/System/Library/Fonts/Supplemental/Songti.ttc",
        "/System/Library/Fonts/Supplemental/Arial Unicode.ttf",
        # Windows
        "C:/Windows/Fonts/msyh.ttc",              # 微软雅黑
        "C:/Windows/Fonts/simhei.ttf",            # 黑体
        "C:/Windows/Fonts/simsun.ttc",            # 宋体
        "C:/Windows/Fonts/arialuni.ttf",          # Arial Unicode
        # Linux 常见
        "/usr/share/fonts/truetype/noto/NotoSansCJK-Regular.ttc",
        "/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc",
        "/usr/share/fonts/truetype/wqy/wqy-zenhei.ttc",
        "/usr/share/fonts/truetype/wqy/wqy-microhei.ttc",
    ]


def _open_font_candidates() -> List[str]:
    # 仅包含开源许可字体（SIL OFL 等）：Noto / 思源黑体（Source Han Sans）
    return [
        # 项目内可选字体目录（请将 NotoSansSC-Regular.otf 放在 scripts/fonts/ 下）
        str((Path(__file__).parent / "fonts" / "NotoSansSC-Regular.otf").resolve()),
        str((Path(__file__).parent / "fonts" / "NotoSansCJKsc-Regular.otf").resolve()),
        str((Path(__file__).parent / "fonts" / "SourceHanSansCN-Regular.otf").resolve()),
        str((Path(__file__).parent / "fonts" / "SourceHanSansSC-Regular.otf").resolve()),

        # 用户字体（常见安装位置）
        str(Path.home() / "Library/Fonts/NotoSansSC-Regular.otf"),
        str(Path.home() / "Library/Fonts/NotoSansTC-Regular.otf"),
        str(Path.home() / "Library/Fonts/NotoSansCJKsc-Regular.otf"),
        str(Path.home() / "Library/Fonts/SourceHanSansCN-Regular.otf"),
        str(Path.home() / "Library/Fonts/SourceHanSansSC-Regular.otf"),

        # 系统字体目录（如有）
        "/Library/Fonts/NotoSansSC-Regular.otf",
        "/Library/Fonts/NotoSansCJKsc-Regular.otf",
        "/Library/Fonts/SourceHanSansCN-Regular.otf",
        "/Library/Fonts/SourceHanSansSC-Regular.otf",

        # Linux 常见路径
        "/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc",
        "/usr/share/fonts/opentype/noto/NotoSansCJKsc-Regular.otf",
        "/usr/share/fonts/truetype/noto/NotoSansCJK-Regular.ttc",
        "/usr/share/fonts/truetype/noto/NotoSansSC-Regular.otf",
        "/usr/share/fonts/opentype/adobe-fonts/source-han-sans/SourceHanSansCN-Regular.otf",
        "/usr/share/fonts/opentype/adobe-fonts/source-han-sans/SourceHanSansSC-Regular.otf",
    ]


def _is_font_effective(draw: ImageDraw.ImageDraw, font: ImageFont.ImageFont, target_size: int) -> bool:
    # 通过测量一个代表性字符的 bbox 高度，判断当前字体是否接近目标字号（避免退回到很小的位图字体）
    try:
        bbox = draw.textbbox((0, 0), "国", font=font)
        height = bbox[3] - bbox[1]
        # 允许一定误差；若小于目标字号的一半，则认为无效
        return height >= max(12, target_size // 2)
    except Exception:
        return False


def try_load_font(font_path: Optional[str], font_size: int, require_open_font: bool = False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    # 优先使用指定字体；失败则在候选集中回退，最后再回退到 PIL 默认字体
    candidates: List[str] = []
    if require_open_font:
        if font_path:
            base = os.path.basename(font_path).lower()
            if any(token in base for token in ["notosans", "sourcehansans", "思源", "noto"]):
                candidates.append(font_path)
            else:
                logging.warning("已启用 open-font-only，忽略非开源字体路径: %s", font_path)
        candidates.extend(_open_font_candidates())
    else:
        if font_path:
            candidates.append(font_path)
        # 开源优先，再到通用候选
        candidates.extend(_open_font_candidates())
        candidates.extend(_font_candidates())

    # 使用一个临时画布来验证字号是否有效
    tmp_img = Image.new("RGB", (10, 10), (255, 255, 255))
    tmp_draw = ImageDraw.Draw(tmp_img)

    for path in candidates:
        p = Path(path)
        if not p.exists():
            continue
        try:
            font = ImageFont.truetype(str(p), font_size)
            if _is_font_effective(tmp_draw, font, font_size):
                logging.debug("使用字体: %s @ %d", path, font_size)
                return font
            else:
                logging.debug("字体有效性不足（字号过小）: %s @ %d，继续回退", path, font_size)
        except Exception as exc:
            logging.debug("尝试字体失败 %s: %s", path, exc)

    # 最后退回 PIL 默认字体
    fallback = ImageFont.load_default()
    if require_open_font:
        logging.warning("已启用 open-font-only，但未找到合适的开源中文字体，已回退到 PIL 默认字体（可能导致文字偏小）")
    else:
        logging.warning("未找到合适的可缩放中文字体，已回退到 PIL 默认字体（可能导致文字偏小）")
    return fallback


def measure_multiline_text(draw: ImageDraw.ImageDraw, text_lines: List[str], font: ImageFont.ImageFont, line_spacing: int) -> Tuple[int, int]:
    max_width = 0
    total_height = 0
    for line in text_lines:
        bbox = draw.textbbox((0, 0), line, font=font)
        width = bbox[2] - bbox[0]
        height = bbox[3] - bbox[1]
        max_width = max(max_width, width)
        total_height += height + line_spacing
    if text_lines:
        total_height -= line_spacing
    return max_width, total_height


def wrap_text_to_width(draw: ImageDraw.ImageDraw, text: str, font: ImageFont.ImageFont, max_width: int) -> List[str]:
    # 简单按字/空格断行（中文按字，英文按空格）
    if not text:
        return []
    lines: List[str] = []
    current = ""
    words = []
    # 将连续英文视为词，其他字符按单字切分
    buffer = ""
    for ch in text:
        if ch.encode("utf-8").isalnum() or ch in "-_@#&/":
            buffer += ch
        else:
            if buffer:
                words.append(buffer)
                buffer = ""
            words.append(ch)
    if buffer:
        words.append(buffer)

    for token in words:
        tentative = current + token
        width = draw.textlength(tentative, font=font)
        if width <= max_width or not current:
            current = tentative
        else:
            lines.append(current)
            current = token
    if current:
        lines.append(current)
    return lines


@dataclass
class Style:
    width: int
    height: int
    background: Tuple[int, int, int, int]
    title_color: Tuple[int, int, int, int]
    subtitle_color: Tuple[int, int, int, int]
    title_font_size: int
    subtitle_font_size: int
    title_font_path: Optional[str]
    subtitle_font_path: Optional[str]
    padding: int
    line_spacing: int
    max_text_width_ratio: float
    text_align: str
    screenshot_mode: str
    screenshot_max_height_ratio: float
    screenshot_top_offset: Optional[int]
    open_font_only: bool
    # 布局增强
    text_to_image_spacing: int
    screenshot_bottom_margin: int
    screenshot_border_width: int
    screenshot_border_color: Tuple[int, int, int, int]
    # 背景渐变与设备卡片（仿示例风格）
    use_background_gradient: bool
    background_top_color: Tuple[int, int, int, int]
    background_bottom_color: Tuple[int, int, int, int]
    device_card_corner_radius: int
    device_card_fill: Tuple[int, int, int, int]
    device_card_shadow_color: Tuple[int, int, int, int]
    device_card_shadow_blur: int
    device_card_shadow_offset_y: int
    device_card_padding: int
    # 文案强调：将副标题作为主标题（更大）
    subtitle_is_headline: bool
    subtitle_scale: float


def build_style(style_cfg: Dict[str, Any]) -> Style:
    # 通用默认值（非业务数据）
    width = int(get_value_case_insensitive(style_cfg, "width", 1242))
    height = int(get_value_case_insensitive(style_cfg, "height", 2688))
    background = parse_color(get_value_case_insensitive(style_cfg, "backgroundcolor", "#FFFFFF"), (255, 255, 255, 255))
    title_color = parse_color(get_value_case_insensitive(style_cfg, "titlecolor", "#000000"), (0, 0, 0, 255))
    subtitle_color = parse_color(get_value_case_insensitive(style_cfg, "subtitlecolor", "#333333"), (51, 51, 51, 255))
    title_font_size = int(get_value_case_insensitive(style_cfg, "titlefontsize", 76))
    subtitle_font_size = int(get_value_case_insensitive(style_cfg, "subtitlefontsize", 42))
    # 强制仅使用开源字体：忽略自定义路径
    title_font_path = None
    subtitle_font_path = None
    padding = int(get_value_case_insensitive(style_cfg, "padding", 64))
    line_spacing = int(get_value_case_insensitive(style_cfg, "linespacing", 12))
    max_text_width_ratio = float(get_value_case_insensitive(style_cfg, "maxtextwidthratio", 0.88))
    text_align = str(get_value_case_insensitive(style_cfg, "textalign", "center")).lower()
    screenshot_mode = str(get_value_case_insensitive(style_cfg, "screenshotmode", "fit")).lower()
    screenshot_max_height_ratio = float(get_value_case_insensitive(style_cfg, "screenshotmaxheightratio", 0.70))
    screenshot_top_offset = get_value_case_insensitive(style_cfg, "screenshottopoffset")
    screenshot_top_offset = int(screenshot_top_offset) if screenshot_top_offset is not None else None
    # 布局增强默认值
    text_to_image_spacing = int(get_value_case_insensitive(style_cfg, "texttoimagespacing", 32))
    screenshot_bottom_margin = int(get_value_case_insensitive(style_cfg, "screenshotbottommargin", 96))
    screenshot_border_width = int(get_value_case_insensitive(style_cfg, "screenshotborderwidth", 8))
    screenshot_border_color = parse_color(
        get_value_case_insensitive(style_cfg, "screenshotbordercolor", "#E5E8EF"), (229, 232, 239, 255)
    )
    open_font_only = True
    # 背景与设备卡片默认（参考 IMG_2762 风格）
    use_background_gradient = bool(get_value_case_insensitive(style_cfg, "usebackgroundgradient", True))
    background_top_color = parse_color(get_value_case_insensitive(style_cfg, "backgroundtopcolor", "#F6F7FB"), (246, 247, 251, 255))
    background_bottom_color = parse_color(get_value_case_insensitive(style_cfg, "backgroundbottomcolor", "#ECEEF5"), (236, 238, 245, 255))
    device_card_corner_radius = int(get_value_case_insensitive(style_cfg, "devicecardcornerradius", 64))
    device_card_fill = parse_color(get_value_case_insensitive(style_cfg, "devicecardfill", "#FFFFFF"), (255, 255, 255, 255))
    device_card_shadow_color = parse_color(get_value_case_insensitive(style_cfg, "devicecardshadowcolor", "#22000000"), (0, 0, 0, 34))
    device_card_shadow_blur = int(get_value_case_insensitive(style_cfg, "devicecardshadowblur", 36))
    device_card_shadow_offset_y = int(get_value_case_insensitive(style_cfg, "devicecardshadowoffsety", 12))
    device_card_padding = int(get_value_case_insensitive(style_cfg, "devicecardpadding", 36))
    # 文案强调
    subtitle_is_headline = bool(get_value_case_insensitive(style_cfg, "subtitleisheadline", True))
    subtitle_scale = float(get_value_case_insensitive(style_cfg, "subtitlescale", 1.4))

    if text_align not in {"center", "left", "right"}:
        logging.warning("textAlign=%r 无效，回退为 center", text_align)
        text_align = "center"
    if screenshot_mode not in {"fit"}:  # 目前仅实现 fit
        logging.warning("screenshotMode=%r 暂不支持，回退为 fit", screenshot_mode)
        screenshot_mode = "fit"

    return Style(
        width=width,
        height=height,
        background=background,
        title_color=title_color,
        subtitle_color=subtitle_color,
        title_font_size=title_font_size,
        subtitle_font_size=subtitle_font_size,
        title_font_path=title_font_path,
        subtitle_font_path=subtitle_font_path,
        padding=padding,
        line_spacing=line_spacing,
        max_text_width_ratio=max_text_width_ratio,
        text_align=text_align,
        screenshot_mode=screenshot_mode,
        screenshot_max_height_ratio=screenshot_max_height_ratio,
        screenshot_top_offset=screenshot_top_offset,
        open_font_only=open_font_only,
        text_to_image_spacing=text_to_image_spacing,
        screenshot_bottom_margin=screenshot_bottom_margin,
        screenshot_border_width=screenshot_border_width,
        screenshot_border_color=screenshot_border_color,
        use_background_gradient=use_background_gradient,
        background_top_color=background_top_color,
        background_bottom_color=background_bottom_color,
        device_card_corner_radius=device_card_corner_radius,
        device_card_fill=device_card_fill,
        device_card_shadow_color=device_card_shadow_color,
        device_card_shadow_blur=device_card_shadow_blur,
        device_card_shadow_offset_y=device_card_shadow_offset_y,
        device_card_padding=device_card_padding,
        subtitle_is_headline=subtitle_is_headline,
        subtitle_scale=subtitle_scale,
    )


def compute_text_x(style: Style, draw: ImageDraw.ImageDraw, line: str, font: ImageFont.ImageFont) -> int:
    line_width = draw.textlength(line, font=font)
    if style.text_align == "left":
        return style.padding
    if style.text_align == "right":
        return style.width - style.padding - int(line_width)
    # center
    return (style.width - int(line_width)) // 2


def render_single_image(
    input_dir: Path,
    output_dir: Path,
    style: Style,
    item: Dict[str, Any],
) -> Optional[Path]:
    title = get_value_case_insensitive(item, "title", "")
    subtitle = get_value_case_insensitive(item, "subtitle", "")
    screenshot_name = get_value_case_insensitive(item, "screenshot")
    output_name = get_value_case_insensitive(item, "outputname")

    if not screenshot_name:
        logging.error("缺少 screenshot 字段，跳过该条目: %s", item)
        return None

    screenshot_path = input_dir / screenshot_name
    if not screenshot_path.exists():
        logging.error("找不到截图文件: %s", screenshot_path)
        return None

    # 背景：纯色或渐变
    canvas = Image.new("RGBA", (style.width, style.height), style.background)
    if style.use_background_gradient:
        grad = Image.new("RGBA", (1, style.height), (0, 0, 0, 0))
        top = style.background_top_color
        bottom = style.background_bottom_color
        # 垂直渐变插值
        for y in range(style.height):
            t = y / max(1, style.height - 1)
            r = int(top[0] * (1 - t) + bottom[0] * t)
            g = int(top[1] * (1 - t) + bottom[1] * t)
            b = int(top[2] * (1 - t) + bottom[2] * t)
            a = int(top[3] * (1 - t) + bottom[3] * t)
            grad.putpixel((0, y), (r, g, b, a))
        grad = grad.resize((style.width, style.height))
        canvas.alpha_composite(grad)
    draw = ImageDraw.Draw(canvas)

    # 始终仅使用开源字体
    title_font = try_load_font(style.title_font_path, style.title_font_size, require_open_font=True)
    subtitle_font = try_load_font(style.subtitle_font_path, style.subtitle_font_size, require_open_font=True)
    try:
        logging.debug("title_font: %s", getattr(title_font, "getname", lambda: (str(title_font), ""))())
        logging.debug("subtitle_font: %s", getattr(subtitle_font, "getname", lambda: (str(subtitle_font), ""))())
    except Exception:
        pass

    # 文本区域最大宽度
    max_text_width = int(style.width * style.max_text_width_ratio) - style.padding * (0 if style.text_align == "center" else 1)

    # 标题与副标题：支持“副标题更醒目”的风格
    current_y = style.padding
    if style.subtitle_is_headline:
        # 先绘制小标题（原 title）
        title_lines = wrap_text_to_width(draw, title or "", title_font, max_text_width)
        logging.debug("title raw=%r -> lines=%s", title, title_lines)
        for line in title_lines:
            x = compute_text_x(style, draw, line, title_font)
            draw.text((x, current_y), line, font=title_font, fill=style.title_color)
            bbox = draw.textbbox((x, current_y), line, font=title_font)
            line_h = bbox[3] - bbox[1]
            current_y += line_h + style.line_spacing

        # 再绘制大字号副标题
        big_subtitle_font = try_load_font(None, int(style.subtitle_font_size * style.subtitle_scale), require_open_font=True)
        subtitle_lines = wrap_text_to_width(draw, subtitle or "", big_subtitle_font, max_text_width)
        logging.debug("subtitle(headline) raw=%r -> lines=%s", subtitle, subtitle_lines)
        for line in subtitle_lines:
            x = compute_text_x(style, draw, line, big_subtitle_font)
            draw.text((x, current_y), line, font=big_subtitle_font, fill=style.title_color)
            bbox = draw.textbbox((x, current_y), line, font=big_subtitle_font)
            line_h = bbox[3] - bbox[1]
            current_y += line_h + style.line_spacing
    else:
        # 常规：大标题 + 小副标题
        title_lines = wrap_text_to_width(draw, title or "", title_font, max_text_width)
        logging.debug("title raw=%r -> lines=%s", title, title_lines)
        for line in title_lines:
            x = compute_text_x(style, draw, line, title_font)
            draw.text((x, current_y), line, font=title_font, fill=style.title_color)
            bbox = draw.textbbox((x, current_y), line, font=title_font)
            line_h = bbox[3] - bbox[1]
            current_y += line_h + style.line_spacing

        subtitle_lines = wrap_text_to_width(draw, subtitle or "", subtitle_font, max_text_width)
        logging.debug("subtitle raw=%r -> lines=%s", subtitle, subtitle_lines)
        for line in subtitle_lines:
            x = compute_text_x(style, draw, line, subtitle_font)
            draw.text((x, current_y), line, font=subtitle_font, fill=style.subtitle_color)
            bbox = draw.textbbox((x, current_y), line, font=subtitle_font)
            line_h = bbox[3] - bbox[1]
            current_y += line_h + style.line_spacing

    # 文本区到截图之间美观间距
    current_y += max(style.text_to_image_spacing, style.padding // 2)

    # 3) 绘制截图（居中偏下，带设备卡片与阴影）
    with Image.open(screenshot_path) as src:
        src = src.convert("RGBA")
        available_height = int(style.height * style.screenshot_max_height_ratio)
        if style.screenshot_top_offset is not None:
            # 若提供了绝对偏移，则覆盖当前 y
            current_y = style.screenshot_top_offset

        # 截图最大显示区域（左右各留 padding）
        max_w = style.width - style.padding * 2
        max_h = min(available_height, style.height - current_y - max(style.screenshot_bottom_margin, style.padding))
        if max_w <= 0 or max_h <= 0:
            logging.warning("可用区域不足，跳过截图绘制: %s", screenshot_path)
        else:
            # 等比缩放
            ratio = min(max_w / src.width, max_h / src.height)
            target_size = (max(1, int(src.width * ratio)), max(1, int(src.height * ratio)))
            resized = src.resize(target_size, Image.LANCZOS)
            x = (style.width - target_size[0]) // 2
            y = current_y
            # 设备卡片阴影
            if style.device_card_shadow_blur > 0:
                shadow = Image.new("RGBA", (style.width, style.height), (0, 0, 0, 0))
                shadow_draw = ImageDraw.Draw(shadow)
                card_rect = [
                    x - style.device_card_padding,
                    y - style.device_card_padding + style.device_card_shadow_offset_y,
                    x + target_size[0] + style.device_card_padding,
                    y + target_size[1] + style.device_card_padding,
                ]
                shadow_draw.rounded_rectangle(
                    card_rect,
                    radius=style.device_card_corner_radius,
                    fill=style.device_card_shadow_color,
                )
                shadow = shadow.filter(ImageFilter.GaussianBlur(radius=style.device_card_shadow_blur))
                canvas.alpha_composite(shadow)
            # 设备卡片底
            card = Image.new("RGBA", (style.width, style.height), (0, 0, 0, 0))
            card_draw = ImageDraw.Draw(card)
            card_rect2 = [
                x - style.device_card_padding,
                y - style.device_card_padding,
                x + target_size[0] + style.device_card_padding,
                y + target_size[1] + style.device_card_padding,
            ]
            card_draw.rounded_rectangle(
                card_rect2,
                radius=style.device_card_corner_radius,
                fill=style.device_card_fill,
            )
            canvas.alpha_composite(card)
            # 绘制边框（先画矩形，再贴图）
            if style.screenshot_border_width > 0:
                border_x0 = x - style.screenshot_border_width
                border_y0 = y - style.screenshot_border_width
                border_x1 = x + target_size[0] + style.screenshot_border_width
                border_y1 = y + target_size[1] + style.screenshot_border_width
                draw.rounded_rectangle(
                    [border_x0, border_y0, border_x1, border_y1],
                    radius=max(12, style.screenshot_border_width * 2),
                    fill=None,
                    outline=style.screenshot_border_color,
                    width=style.screenshot_border_width,
                )
            canvas.alpha_composite(resized, (x, y))

    # 导出文件名
    if output_name:
        out_name = output_name
    else:
        base = Path(screenshot_name).stem
        out_name = f"{base}_appstore.png"

    out_path = output_dir / out_name
    out_path.parent.mkdir(parents=True, exist_ok=True)
    canvas = canvas.convert("RGB")  # App Store 推荐 JPG/PNG，统一去除 alpha
    canvas.save(out_path, format="PNG", optimize=True)
    logging.info("已生成: %s", out_path)
    return out_path


def main() -> None:
    args = parse_args()
    logging.basicConfig(level=logging.DEBUG if args.verbose else logging.INFO, format="%(levelname)s: %(message)s")

    input_dir = Path(args.input_dir).expanduser().resolve()
    if not input_dir.exists() or not input_dir.is_dir():
        raise SystemExit(f"输入目录不存在或不是目录: {input_dir}")

    cfg_path = input_dir / args.config
    if not cfg_path.exists():
        raise SystemExit(f"配置文件不存在: {cfg_path}")

    output_dir = Path(args.output_dir).expanduser().resolve() if args.output_dir else (input_dir / "output")
    ensure_dir(output_dir)

    data = load_json(cfg_path)
    if not isinstance(data, dict):
        raise SystemExit("配置文件 JSON 根应为对象")

    style_cfg = get_value_case_insensitive(data, "styleconfig", {})
    configs = get_value_case_insensitive(data, "configs", [])
    if not isinstance(configs, list) or not configs:
        raise SystemExit("configs 必须为非空数组")

    style = build_style(style_cfg if isinstance(style_cfg, dict) else {})

    generated: List[Path] = []
    for idx, item in enumerate(configs, start=1):
        if not isinstance(item, dict):
            logging.warning("configs[%d] 非对象，已跳过", idx - 1)
            continue
        out = render_single_image(input_dir, output_dir, style, item)
        if out is not None:
            generated.append(out)

    logging.info("生成完成，共 %d 张", len(generated))


if __name__ == "__main__":
    main()

