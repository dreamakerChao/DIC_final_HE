import numpy as np

a =  np.array([[161,158,159],[158,0,155],[156,154,153]])
x =  np.array([[-1,0,1],[-2,0,2],[-1,0,1]])
y =  np.array([[-1,-2,-1],[0,0,0],[1,2,1]])


gx = np.sum(a*x)
gy = np.sum(a*y)

g= (gx**2+gy**2)
print(g)
pass