import numpy as np
from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
from matplotlib import cm
import re

fig = plt.figure()
ax = plt.axes(projection='3d')
ax.set_xlabel("X")
ax.set_ylabel("Y")
ax.set_zlabel("Z")


pts_str="""
07:52:29.195 : 0 +0.217 +0.179 +0.161 +0.139 +0.131 +0.151 +0.201
07:52:29.195 : 1 +0.241 +0.179 +0.158 +0.129 +0.116 +0.138 +0.178
07:52:29.197 : 2 +0.275 +0.179 +0.131 +0.109 +0.110 +0.134 +0.182
07:52:29.197 : 3 +0.281 +0.179 +0.119 +0.109 +0.098 +0.126 +0.197
07:52:29.197 : 4 +0.284 +0.186 +0.120 +0.083 +0.082 +0.118 +0.200
07:52:29.197 : 5 +0.280 +0.174 +0.109 +0.083 +0.079 +0.118 +0.191
07:52:29.197 : 6 +0.278 +0.167 +0.100 +0.067 +0.087 +0.103 +0.181
"""


numbers=re.findall(r'[+-]\d+\.\d+', pts_str)

pts=[float(n) for n in numbers]

# lines=pts_str.splitlines()
# pts=[]
# for l in lines:
#     ls=l.split(" ")
#     if len(ls)>4:
#         for n in ls[3:]:
#             pts.append(float(n))
res=int(np.floor(np.sqrt(len(pts))))
if res*res != len(pts):
    print("Not square")
    exit(1)

z=np.array(pts).reshape(res,res)

print(f'Range: {np.max(z)-np.min(z)}')

x=np.arange(0,res)
y=np.arange(0,res)
x,y=np.meshgrid(x,y)

m = cm.ScalarMappable(cmap=cm.jet)
m.set_array(z)

ax.get_proj = lambda: np.dot(Axes3D.get_proj(ax), np.diag([scale_x, scale_y, scale_z, 1]))

ax.plot_surface(x, y, z, cmap=cm.jet)

scale_x = 1
scale_y = 1
scale_z = 0.25



plt.colorbar(m)

plt.show()

z2=z.copy()

for x in range(1, z.shape[0]-1, 2):
    for y in range(0, z.shape[1]):
        z2[x,y]=(z2[x-1,y]+z2[x+1,y])/2

for x in range(0, z.shape[0]):
    for y in range(1, z.shape[1]-1, 2):
        z2[x,y]=(z2[x,y-1]+z2[x,y+1])/2

print(z2)

print(f'difference={np.max(np.abs(z-z2))}')


#ax.plot_surface(x, y, z2, cmap=cm.coolwarm)


