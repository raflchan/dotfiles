import datetime
import gi
import os

gi.require_version("GdkPixbuf", "2.0")
from gi.repository import GdkPixbuf

# 160,  0 width
# 160,  1 height
# 640,  2 rowstride
# 1,    3 has_alpha
# 8,    4 bits_per_sample
# 4,    5 ???
# [...] 6 pixeldata

def save_image_bytes(data: dict) -> str:
    thumbs_folder = os.path.join(os.environ['HOME'], '.cache/notif-log/thumbs')
    save_path = os.path.join(thumbs_folder, f"{datetime.datetime.now().strftime('%s')}.png")
    if not os.path.exists(thumbs_folder):
        os.makedirs(thumbs_folder)

    # TODO: compare file hashes to reduce clutter!

    GdkPixbuf.Pixbuf.new_from_data(
        width=data[0],
        height=data[1],
        rowstride=data[2],
        has_alpha=data[3],
        bits_per_sample=data[4],
        data=data[6],
        colorspace=GdkPixbuf.Colorspace.RGB
    ).savev(save_path, 'png')

    return save_path
