import os
import imageio
import numpy as np
import moviepy.editor as mp



DIR = "/Users/arpj/Documents/princeton/coursework/spring_2020/cee_546/assignments/03/equad_courtyard/gif/dr_45_tree_subd"
IN_NAME = 'dr_45_tree_subd.gif'
OUT_NAME = 'dr_45_tree_subd.mp4'

FPS = 6
CODEC = 'mpeg4'

IN = os.path.join(DIR, IN_NAME)
OUT = os.path.join(DIR, OUT_NAME)

clip = mp.VideoFileClip(IN)
clip.write_videofile(OUT, fps=FPS, codec=CODEC, audio=False)
clip.close()
