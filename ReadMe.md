# Tri-objective combinatorial optimization problems

The paper consider instances for tri-objective combinatorial (binary) optimization
problems. Problem classes considered are Knapsack (KP), Assignment (AP), Facility Location (FLP)
and IP (general problems with a mixture of constraints and binary variables). [Other problem classes?]


## Test instances

Instances are named `Forget20_[problem class]_[n]_[p]_[range of costs]_[cost generation method]_[constaint id]_[id].raw` where 

   - `problem class` is either KP (knapsack problem), AP (assignment problem), FLP (facility
      location problem) or IP (integer problem with binary variables).
   - `n` is the size of the problem. 
   - `p`is the number of objectives.
   - `range of costs`: Objective coefficient range e.g. 1-1000.
   - `cost generation method`: Either random, spheredown, sphereup or 2box. For further details see 
      the documentation function `genSample` in the R package 
      [gMOIP](https://CRAN.R-project.org/package=gMOIP).
   - `costaint id`: Same id if constraints are the same.
   - `id`: Instance id running within the constraint id.
   
The paper considers instances of size 5-50; however, the instance set also contains 5
instances of size 60-100. Costs are generated random in [0,30].




### Raw format description 

All instance files are given in raw format. An example for a knapsack problem is:

```
15 1 3 15 45

maxsum maxsum maxsum 

37 500 117 743 703 165 877 570 445 690 549 705 958 605 472 
843 952 932 801 86 465 661 299 118 367 427 483 462 528 927 
657 163 532 378 825 963 218 927 962 847 915 800 122 850 485 

7 8 5 11 6 6 10 10 11 7 12 13 8 15 14 

1 71
```

The general format is defined as: [Is there a link to how Bensolve do it??]

```
n m p non-zero_a non-zero_c

objective_types

matrix_of_objective_coefficients

matrix_of_constraint_coefficients

matrix_of_right-hand_sides
```

where:

   - `n` is the number of variables.
   - `m` is the number of constrains.
   - `p` is the number of objectives.
   - `non-zero_a` is the number of non-zero entries in the matrix of the constraint coefficients.
   - `non-zero_c` is the number of non-zero objective coefficients in the objective matrix.
   - `objective_types` is the nature of the objectives to be optimized. An identifier should be 
   added for each objective, and it should be done in the same order as in the objective matrix. 
   Four types are supported:
      	* maxsum: maximise a sum objective function
      	* minsum: minimise a sum objective function
      	* maxmin: maximise a min objective function
      	* minmax: minimise a max objective function
   - matrix_of_objective_coefficients is a p x n matrix defining the coefficients of the objective functions
   - matrix_of_constraint_coefficients is a m x n matrix defining the coefficients of the constraints
   - matrix_of_rand-hand_sides is a m x 2 matrix defining the right-hand side of the constraints. 
   For each constraint, two numbers are required:
      * The second number is the actual value of the right-hand side of the constraint
      * The first number is an identifier that is used to define the sign of the constraint. 
      Three identifiers can be used: 0 for >= constraints, 1 for <= constraints and 2 for = constraints.


## Results

Restults are given in the `results` folder using the [json
format](https://github.com/MCDMSociety/MOrepo/blob/master/contribute.md) (see Step 3). 




