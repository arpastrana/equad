import os
import imageio
from pygifsicle import optimize


DIR = "../gif/dr_45_tree_subd_gif_to_images/"
OUT_NAME = 'dr_45_tree.mp4'
SUFFIX = ".png"

LOOP = 0
FPS = 6
OPTIMIZE = False
COLORS = 256


filenames = os.listdir(DIR)
OUT = os.path.join(DIR, OUT_NAME)

images = []
filenames = sorted([filename for filename in filenames if filename.endswith(SUFFIX)])
for filename in filenames:
	file_path = os.path.join(DIR, filename)
	images.append(imageio.imread(file_path))

print('baking...')
imageio.mimsave(OUT, images, fps=FPS)  # mp4
# imageio.mimsave(OUT, images, loop=LOOP, fps=FPS)  # gif
print('baked!')

if OPTIMIZE:  # only for gif
	print('optimizing gif...')
	optimize(OUT, colors=COLORS)

print('done!')
