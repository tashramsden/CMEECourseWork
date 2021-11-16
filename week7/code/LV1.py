#!/usr/bin/env python3

"""The Lotka-Volterra model; 2 plots of consumer-resource density created in ../results."""
__author__ = 'Tash Ramsden (tash.ramsden21@imperial.ac.uk)'
__version__ = '0.0.1'

from scipy import integrate
import numpy as np
import matplotlib.pylab as p


# Lotka-Volterra model
def dCR_dt(pops, t=0):
    """Defines the Lotka-Volterra model. 
    Returns the growth rate of the consumer and resource populations at any given time step"""

    R = pops[0]
    C = pops[1]
    dRdt = r * R - a * R * C
    dCdt = -z * C + e * a * R * C

    return np.array([dRdt, dCdt])


type(dCR_dt)

# param values
r = 1.
a = 0.1 
z = 1.5
e = 0.75

# time vector - here integrating from time 0 to 15 using 1000 sub-divisions
t = np.linspace(0, 15, 1000)

# initial conditions for the 2 pops
R0 = 10
C0 = 5 
RC0 = np.array([R0, C0])

# now numerically integrate this systme forward 
pops, infodict = integrate.odeint(dCR_dt, RC0, t, full_output=True)
pops
# pops contains the result (pop trajectories)

# ?integrate.odeint
# infodict is a dictionary w some additional info:
type(infodict)
infodict.keys()
infodict["message"]


# visualise results

# consumer-resource over time
f1 = p.figure()
p.plot(t, pops[:, 0], 'g-', label='Resource density')  # Plot
p.plot(t, pops[:, 1], 'b-', label='Consumer density')
p.grid()
p.legend(loc='best')
p.xlabel('Time')
p.ylabel('Population density')
p.title('Consumer-Resource population dynamics')
# p.show()  # To display the figure

f1.savefig('../results/LV_model.pdf')  # Save figure


# resource vs consumer density
f2 = p.figure()
p.plot(pops[:, 0], pops[:, 1], 'red')
p.grid()
p.xlabel('Resource density')
p.ylabel('Consumer density')
p.title('Consumer-Resource population dynamics')
# p.show()

f2.savefig("../results/LV_model2.pdf")
