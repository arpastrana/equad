import os
import imageio
from pygifsicle import optimize


DIR = "../gif/planarization_1_rgb/"
OUT_NAME = 'planarization_1_rgb.gif'
SUFFIX = ".bmp"
LOOP = 0
FPS = 6
OPTIMIZE = True
COLORS = 256


filenames = os.listdir(DIR)
OUT = os.path.join(DIR, OUT_NAME)

images = []
filenames = sorted([filename for filename in filenames if filename.endswith(SUFFIX)])
for filename in filenames:
	file_path = os.path.join(DIR, filename)
	images.append(imageio.imread(file_path))


print('baking...')
imageio.mimsave(OUT, images, loop=LOOP, fps=FPS)
print('baked!')
if OPTIMIZE:
	print('optimizing gif...')
	optimize(OUT, colors=COLORS)
print('done!')

