
INPUT ?= ex3
tag = .cu
compiler = nvcc
output = ex3

compile:
	@$(compiler) $(INPUT)$(tag) -o $(output)

push:
	@git add .
	@git commit -m "updated"
	@git push 
