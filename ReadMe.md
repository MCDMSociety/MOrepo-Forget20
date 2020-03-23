# Tri-objective combinatorial optimization problems

The paper consider instances for tri-objective combinatorial (binary variables) optimization problems. 
Problem classes considered are Knapsack (KP), Assignment (AP), Facility Location (FLP) and IP/MILP (general problems with a mixture of constraints)


## Test instances

[TO BE MODIFIED] Instances are named `Forget20_[problem class]_n<n>.raw` where `n` is the size of the problem. The paper considers
instances of size 5-50; however, the instance set also contains 5 instances of size 60-100. Costs
are generated random in [0,30].

All instance files are given in raw format. 


### Raw format description 

All problems are given in the following format:



n m p non-zero_a non-zero_c

objective_types

matrix_of_objective_coefficients

matrix_of_constraint_coefficients

matrix_of_right-hand_sides



where:

- n is the number of variables
- m is the number of constrains
- p is the number of objectives
- non-zero_a is the number of non-zero coefficients in the matrix of the constraint coefficients
- non-zero_c is the number of non-zero coefficients in the matrix of the objective coefficients
- objective_types is the nature of the objectives to be optimized. An identifier should be added for each objective, and it should be done in the same order as in the objective coefficients matrix. Four types are supported so far:
	* maxsum: maximise a sum objective function
	* minsum: minimise a sum objective function
	* maxmin: maximise a min objective function
	* minmax: minimise a max objective function
- matrix_of_objective_coefficients is a p x n matrix defining the coefficients of the objective functions
- matrix_of_constraint_coefficients is a m x n matrix defining the coefficients of the constraints
- matrix_of_rand-hand_sides is a m x 2 matrix defining the right-hand side of the constraints. For each constraint, two numbers are required:
	* The first number is an identifier that is used to define the sign of the constraint. Three identifiers can be used:
		- 0 for >= constraints
		- 1 for <= constraints
		- 2 for = constraints
	* The second number is the actual value of the right-hand side of the constraint
	

## Results

Restults are given in the `results` folder using the [json
format](https://github.com/MCDMSociety/MOrepo/blob/master/contribute.md) (see Step 3). 




