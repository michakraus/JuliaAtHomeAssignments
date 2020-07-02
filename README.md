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


#### 5. Traits and Closures

Implement a FFT-based 1D Poisson solver for the electrostatic potential. Use this potential to compute the electric field in the charged particle equations.

Note that the potential might have to be updated during one time step, e.g., for each internal stage of a Runge-Kutta method.
This can be achieved using callbacks, e.g., functions that are called at the beginning or end of a stage or sub-step of an integrator.
Extend the equation and integrator types and methods accordingly.


#### 6. Abstract Types and Interfaces

Implement an abstract interface for electromagnetic fields that supports prescribed analytical, prescibed numerical as well as self-consistent numerical fields.

Use this interface to generalise the Lorentz force in the charged particle equations.

Wrap some package like ApproxFun.jl or FrameFun.jl, that allows to project analytical fields onto a numerical representation, to be compatible with your electromagnetic field interface. Adapt the interface of your electrostatic FFT solver accordingly.


#### 7. Abstract Arrays

Implement a custom array type that holds both particle and field data.
Implement a Vlasov-Ampere solver that advances both the particles and the electric field in time using a splitting method.

Remark: A convenient feature to consider is the possibility to index your array by symbols `:x`, `:v`, `:e`, `:b` instead of `1..4` to access the various components of the solution. 
