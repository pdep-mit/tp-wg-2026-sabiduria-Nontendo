"""Recorta las fuentes de ALTTP y escala sin suavizado. Requiere Pillow."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "assets" / "fuentes"
OUT = ROOT / "assets" / "zelda"
OUT.mkdir(exist_ok=True)
NEAREST = Image.Resampling.NEAREST

def source(name):
    return Image.open(SRC / name).convert("RGBA")

def tile(sheet, box, size=(48, 48)):
    return sheet.crop(box).resize(size, NEAREST)

def save(image, name):
    image.save(OUT / (name + ".png"))

def centered(image, scale=2):
    image = image.resize((image.width * scale, image.height * scale), NEAREST)
    result = Image.new("RGBA", (48, 48))
    result.alpha_composite(image, ((48 - image.width) // 2, (48 - image.height) // 2))
    return result

font = ImageFont.truetype("C:/Windows/Fonts/consolab.ttf", 16)
big_font = ImageFont.truetype("C:/Windows/Fonts/consolab.ttf", 21)
link = source("link-sheet.png")
for direction, x in [("derecha", 0), ("arriba", 24), ("izquierda", 72), ("abajo", 96)]:
    save(tile(link, (x, 0, x + 24, 24)), "link-" + direction)
save(centered(source("Key.png")), "llave")
save(centered(source("PendantOfCourage.png")), "colgante")

misc = source("misc.png")
for number, color in [(1, "#5fd382"), (2, "#75b9ff"), (3, "#f3ae72")]:
    for active in [False, True]:
        image = tile(misc, (16 if active else 0, 0, 32 if active else 16, 16))
        draw = ImageDraw.Draw(image)
        draw.rectangle((2, 2, 45, 45), outline=color, width=3)
        draw.text((24, 23), str(number), fill="#ffffff" if active else color,
                  font=big_font, anchor="mm", stroke_width=1, stroke_fill="#202332")
        save(image, "boton-" + str(number) + ("-on" if active else ""))

dungeon = source("dungeon.png")
floor = tile(dungeon, (288, 192, 304, 208))
wall = tile(dungeon, (48, 64, 64, 80))
save(wall, "muro")
save(tile(misc, (0, 32, 16, 48)), "barrera")
open_gate = Image.new("RGBA", (48, 48))
ImageDraw.Draw(open_gate).rectangle((3, 3, 44, 44), outline="#74d39e", width=2)
save(open_gate, "barrera-abierta")

# Antorcha con llama original y soporte sencillo agregado para la demo.
for lit in [False, True]:
    torch = Image.new("RGBA", (48, 48))
    d = ImageDraw.Draw(torch)
    if lit:
        d.ellipse((1, 1, 46, 46), fill=(255, 185, 45, 55))
    d.rectangle((20, 23, 28, 43), fill="#69432c", outline="#b69b6c", width=2)
    d.rectangle((14, 21, 34, 27), fill="#8d8194", outline="#242438", width=2)
    if lit:
        torch.alpha_composite(tile(misc, (96, 0, 112, 16), (32, 32)), (8, 0))
    else:
        d.rectangle((18, 11, 30, 21), fill="#41333b", outline="#948093")
    save(torch, "antorcha-encendida" if lit else "antorcha")

# Pinchos de la plancha de mazmorra; su celda se seniala en rojo.
spikes = tile(dungeon, (280, 496, 296, 512))
ImageDraw.Draw(spikes).rectangle((1, 1, 46, 46), outline="#ce687b", width=2)
save(spikes, "pinchos")

doors = source("doors.png")
save(tile(doors, (64, 48, 96, 64)), "salida")
save(tile(doors, (160, 48, 192, 64)), "salida-abierta")

board = Image.new("RGBA", (768, 576), "#121724")
for y in range(10):
    for x in range(16):
        board.alpha_composite(wall if x in (0, 15) or y in (0, 9) else floor,
                              (x * 48, (11 - y) * 48))
draw = ImageDraw.Draw(board)
draw.rounded_rectangle((18, 100, 750, 137), radius=4, fill="#202538", outline="#a89166", width=2)
draw.text((384, 118), "PISTA: 1 > 2 > 3    /    LLAVE > SALIDA", fill="#f6dd99", font=font, anchor="mm")
draw.rounded_rectangle((18, 539, 750, 568), radius=4, fill="#202538", outline="#526478")
draw.text((384, 554), "FLECHAS: mover   E: activar / recoger / salir   R: reiniciar", fill="#dae2e8", font=font, anchor="mm")
draw.text((168, 176), "ANTORCHA", fill="#edd594", font=font, anchor="mm")
draw.text((650, 174), "SALIDA", fill="#edd594", font=font, anchor="mm")
draw.text((648, 254), "LLAVE", fill="#edd594", font=font, anchor="mm")
draw.text((354, 503), "PINCHOS", fill="#ed9caa", font=font, anchor="mm")
save(board, "sala")
print("Sprites y sala generados en", OUT)
