# Tri-objective combinatorial optimization problems

The paper consider instances for tri-objective combinatorial (binary) optimization
problems. Problem classes considered are Knapsack (KP), Assignment (AP) and Uncapacitated Facility Location (UFLP).


## Test instances

Instances are named `Forget20_[problemClass]_[n]_[p]_[rangeOfCosts]_[costGenerationMethod]_[constaintId]_[id].raw` where 

   - `problemClass` is either KP (knapsack problem), AP (assignment problem), UFLP (Uncapacitated Facility
      Location Problem).
   - `n` is the size of the problem. 
   - `p` is the number of objectives.
   - `rangeOfCosts`: Objective coefficient range e.g. 1-1000.
   - `costGenerationMethod`: Either random or spheredown, sphereup, 2box. For further details see 
      the documentation function `genSample` in the R package 
      [gMOIP](https://CRAN.R-project.org/package=gMOIP).
   - `constaintId`: Same id if constraints are the same.
   - `id`: Instance id running within the constraint id.

### Raw format description 

All instance files are given in raw format (a text file). An example for a Production Planning Problem is:

```
10 1 3 10 30

maxsum maxsum maxsum 

10 1 9 1 1 9 3 10 2 9 
4 9 1 7 7 2 8 3 10 3 
9 4 10 3 4 8 1 9 4 7 

13 5 5 9 10 11 14 15 12 10 

1 52

```

The general format is defined as: 

```
n m p nZero nZeroObj

objectiveTypes

objectiveCoefficientMatrix

constraintMatrix

rHSMatrix

lbVector
ubVector
```

where:

   - `n` is the number of variables.
   - `m` is the number of constrains.
   - `p` is the number of objectives.
   - `nZero` is the number of non-zero coefficients in the constraint matrix.
   - `nZeroObj` is the number of non-zero coefficients in the objective matrix.
   - `objectiveTypes` is the nature of the objectives to be optimized. An identifier should be 
   added for each objective, and it should be done in the same order as in the objective matrix. 
   Four types are supported:
      	* maxsum: maximise a sum objective function
      	* minsum: minimise a sum objective function
   - `objectiveCoefficientMatrix` is a p x n matrix defining the coefficients of the objective functions
   - `constraintMatrix` is a m x n matrix defining the coefficients of the constraints
   - `rHSMatrix` is a m x 2 matrix defining the right-hand side of the constraints. 
   For each constraint, two numbers are required:
      * The second number is the actual value of the right-hand side of the constraint
      * The first number is an identifier that is used to define the sign of the constraint. 
      Three identifiers can be used: 0 for >= constraints, 1 for <= constraints and 2 for = constraints.

## Results

Restults are given in the `results` folder using the [json
format](https://github.com/MCDMSociety/MOrepo/blob/master/contribute.md) (see Step 3). 




