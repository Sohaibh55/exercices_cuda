
INPUT = ex1
# FUNCTIONS = functions  $(FUNCTIONS)$(tag) 
tag = .cu
compiler = nvcc
output = main

compile:
	@$(compiler) $(INPUT)$(tag) -o $(output)



push:
	git add *
	git commit -m "updated"
	git push -u origin main
