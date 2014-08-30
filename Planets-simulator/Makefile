all:

	#~ gfortran main.f90 -o main.exe -fbounds-check -fbacktrace -fimplicit-none
	gfortran main.f90 -o main.exe -fimplicit-none -Ofast -march=native -fwhole-program -ftree-parallelize-loops=4
	#~ gfortran main.f90 -o main.exe -fimplicit-none -Ofast -march=native -fwhole-program
	#~ gfortran main.f90 -o main.exe -fimplicit-none -march=native -fwhole-program 
	
	
	./main.exe
