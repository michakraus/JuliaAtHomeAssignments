# Assignment: Write a simple particle code.

The goal of the assignment is to write a simple yet flexible particle code, that can handle

- different dimensionalities,
- different equations with prescribed as well as self-consistent potentials,
- different time stepping schemes.

The resulting code could be used for particle-in-cell simulations of the Vlasov-Poisson equation just as well as for molecular dynamics simulations.


#### 1. Create a new Project

In order to organise your code, create a new Julia project.
Open the julia interpreter
```
$ julia
```
change to the `Pkg` REPL with `]` so that you see a prompt like the following:
```
(@v1.4) pkg>
```
Create the project using the `generate` command:
```
(@v1.4) pkg> generate Particles
 Generating  project Particles:
    Particles/Project.toml
    Particles/src/Particles.jl
```
This creates two files: `Project.toml` stores meta-data and dependencies of the package, and `src/Particles.jl` contains the main module.
The newly generated environment is activated by the `activate` command:
```
(@v1.4) pkg> activate Particles
 Activating new environment at `~/Particles/Project.toml`
```
Now you can add dependencies.
You will probably want to plot simulation results, which can be done by either Plots.jl or Makie.jl.


#### 2. Pendulum

Implement a simulation for `n` independent pendula:
$$
\dot{x} = v , \quad
\dot{v} = - \sin(x) .
$$
To that end, write a `Simulation` type that stores all the necessary information (solution, time step size, number of time steps, etc.). Use one specific time-stepping scheme, e.g., explicit Runge-Kutta, at first.


#### 3. Equations

Implement the possibility to change the equation, i.e. write an `Equation` type that stores the functions providing the vector fields and initial conditions.

Implement a simulation for `n` independent charged particles in some prescribed electromagnetic field:
$$
\dot{x} = v , \quad
\dot{v} = E (x) + v \times B(x) .
$$


#### 4. Time-stepping schemes

Implement the possibility to change the time stepping schemes.
Write an abstract integrator type with different concrete sub-types.
Implement a function that integrates one time step and has different methods for different integrators.

Add at least one more time stepping method, e.g., Störmer-Verlet.


#### 5. N-body dynamics

Implement a N-body system, where the forces depend on all particles, e.g., the gravitational dynamics of the solar system:
$$
\dot{x} = v , \quad
\dot{v} = - G \sum \limits_{j \ne i} \dfrac{m_i m_j \, (x_i - x_j)}{\vert x_i - x_j \vert^3} ,
$$
where $G = 6.67300 \times 10^{−11} m^{3} kg^{−1} s^{−2}$ is the gravitational constant. Initial data can be found below.

Note that the potential might have to be updated during one time step, e.g., for each internal stage of a Runge-Kutta method.
This can be achieved using callbacks, e.g., functions that are called at the beginning or end of a stage or sub-step of an integrator.
Extend the equation and integrator types and methods accordingly.


#### 6. Electromagnetic fields

Implement an abstract interface for electromagnetic fields that supports prescribed analytical, prescibed numerical as well as self-consistent numerical fields.

Use this interface to generalise the Lorentz force in the charged particle equations.

Wrap some package like ApproxFun.jl or FrameFun.jl, that allows to project analytical fields onto a numerical representation, to be compatible with your electromagnetic field interface.

Implement a FFT-based 1D Poisson solver for the electromagnetic potential. Use this potential to compute the electric field in the charged particle equations. Do not forget proper callbacks.



#### Appendix: Solar System Data

Solar system masses [10^24 kg], positions [km] and velocities [km/d] at 2000-Jan-01 00:00:00.0000
according to the NASA Jet Propulson Laboratory's HORIZONS system (http://ssd.jpl.nasa.gov/horizons.cgi).

```julia
solar_system = Dict(
    "sun" => (1.9884E+6,
    [-1.068000648301820E+06, -4.176802125684930E+05,  3.084467020687090E+04],
    [ 8.039779932353974E+02, -1.108664643177914E+03, -1.409640216521517E+01]),

    "mercury" => (0.33022,
    [-2.212062175862221E+07, -6.682431829610253E+07, -3.461601353176080E+06],
    [ 3.167622060317513E+06, -1.062950676579149E+06, -3.774242348742058E+05]),

    "venus" => (4.8685,
    [-1.085735509178141E+08, -3.784200933160055E+06,  6.190064472977990E+06],
    [ 7.762738511380683E+04, -3.038864213486565E+06, -4.596674903463532E+04]),

    "earth" => (5.9737,
    [-2.627892928682480E+07,  1.445102393586391E+08,  3.022818135935813E+04],
    [-2.577357622036949E+06, -4.510482352192447E+05, -8.766332335017779E+00]),

    "mars" => (0.64185,
    [ 2.069270543147017E+08, -3.560689745239088E+06, -5.147936537447235E+06],
    [ 1.126922831990409E+05,  2.270729281323685E+06,  4.482834400085559E+04]),

    "jupiter" => (1898.7,
    [ 5.978411588490014E+08,  4.387049129404825E+08, -1.520170147924584E+07],
    [-6.819234315724170E+05,  9.633898242256927E+05,  1.127604277013819E+04]),

    "saturn" => (568.51,
    [ 9.576383361717228E+08,  9.821475306996269E+08, -5.518981215364373E+07],
    [-6.410517450582563E+05,  5.811248854956032E+05,  1.533610442176325E+04]),

    "uranus" => (86.849,
    [ 2.157706702828831E+09, -2.055242911807622E+09, -3.559264256520975E+07],
    [ 4.014968007726331E+05,  3.986807999463429E+05, -3.716358575168354E+03]),

    "neptune" => (102.44,
    [ 2.513785419503203E+09, -3.739265092576820E+09,  1.907031792232442E+07],
    [ 3.866490966171590E+05,  2.646301879222923E+05, -1.440534798436708E+04]),

    "pluto" => (0.01305,
    [-1.478626340588577E+09, -4.182878123310691E+09,  8.753002534312660E+08],
    [ 4.554287514915584E+05, -2.299789192198391E+05, -1.073093417616792E+05])
)
```
