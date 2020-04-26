import os
from PIL import Image


DIR = "../gif/dr_45_tree_subd_gif_to_images/"
IN_NAME = 'dr_45_tree_subd.gif'
OUT_NAME = 'dr_45_tree_{}.png'


IN = os.path.join(DIR, IN_NAME)
OUT = os.path.join(DIR, OUT_NAME)


img = Image.open(IN)
for frame in range(0, img.n_frames):
    img.seek(frame)
    img.save(os.path.join(DIR, OUT_NAME.format(frame)))