
INPUT = ex1.cu
# FUNCTIONS = functions  $(FUNCTIONS)$(tag) 
tag = .cu
compiler = nvcc
output = main

excute: compile
	@./$(output)	
compile:
	@$(compiler) $(INPUT)$(tag) -o $(output)



push:
	git add ex1.cu 
	git commit -m "updated"
	git push -u origin main
