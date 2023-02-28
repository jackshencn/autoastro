#!/usr/bin/python3

import numpy
from PIL import Image

data = numpy.fromfile("/tmp/solve.raw", '>u2').reshape((1090,1932))
#data = (data >> 8).astype('u1')

image = Image.fromarray(data)
image.save("/tmp/solve.tiff")

