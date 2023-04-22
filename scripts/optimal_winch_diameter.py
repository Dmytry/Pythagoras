import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import jax.numpy as jnp
import numpy as np


# Basic estimate for acceleration at standstill, not taking into account decrease of torque with RPM (alleviated by larger winch)


cm=1.0E-2
mm=1.0E-3
inch=2.54E-2
gram=1.0E-3
newton=1
meter=1
lbf=4.44822


# Motors I have:
class nema17_38: # 
    model='5-17HS15-1504S-X1'
    torque=45 * newton * cm
    rotor_inertia=54 * gram * cm**2

# Bigger motor

class nema17_48:
    model='5-17HS19-2004S1'
    torque=59 * newton * cm
    rotor_inertia=82 * gram * cm**2

# Some amazon motor:
class nema17_60:
    model='17HS24-2104S'
    torque=65*newton*cm
    rotor_inertia=148 * gram * cm**2

class nema23_76:
    model='23HS8430B'
    torque=180*newton*cm
    rotor_inertia=440*gram*cm**2

class nema23_74_another:
    model='23HS30-2804S'
    torque=1.9 * newton * meter
    rotor_inertia=440*gram*cm**2

motor=nema17_38

def total_inertia(winch_r):
    return motor.rotor_inertia + toolhead_mass * winch_r**2

def max_rot_accel(winch_r):
    return motor.torque / (motor.rotor_inertia + toolhead_mass * winch_r**2)

def max_lin_accel(winch_r):
    return winch_r * motor.torque / (motor.rotor_inertia + toolhead_mass * winch_r**2)

toolhead_mass=100 * gram

winch_r=40 * mm/(2*np.pi)

# diameter for max accel: 
# first derivative of:
# motor_torque / (rotor_inertia/winch_r + toolhead_mass * winch_r)
# equals zero at that point
# (rotor_inertia/winch_r) ' = - (toolhead_mass * winch_r)'
# -rotor_inertia/winch_r^2 = - toolhead_mass
# rotor_inertia/winch_r^2 = toolhead_mass
# winch_r^2 = rotor_inertia/toolhead_mass
# winch_r = sqrt(rotor_inertia/toolhead_mass)

optimum_winch_r=np.sqrt(motor.rotor_inertia/toolhead_mass)
accel_at_max=max_lin_accel(optimum_winch_r)
accel_at_typical=max_lin_accel(winch_r)

r = np.arange(0.0, 2*optimum_winch_r, 0.1*mm)

# setup figures
fig, ax = plt.subplots()

plt.title(f'A {motor.torque/(newton*cm)} $N*cm$ motor with, {motor.rotor_inertia/(gram * cm**2):0.1f} $g*cm^2$ inertia and {toolhead_mass/gram:0.1f} $g$ toolhead')

plt.plot(r, max_lin_accel(r))

plt.axvline(x=winch_r, color='red', label=f'r={(winch_r*1E3):0.2f} $mm$, {accel_at_typical:0.2f} $m/s^2$')

plt.axvline(x=optimum_winch_r, color='green', label=f'r={(optimum_winch_r*1E3):0.2f} $mm$, {accel_at_max:0.2f} $m/s^2$')

plt.xlabel('Pulley radius, $mm$')
plt.ylabel('Acceleration, $m/s^2$')

ticks_x = ticker.FuncFormatter(lambda x, pos: '{0:g}'.format(x/mm))
ax.xaxis.set_major_formatter(ticks_x)

plt.legend()
#plt.legend(bbox_to_anchor = (1.0, 1), loc = 'upper left')

plt.show()