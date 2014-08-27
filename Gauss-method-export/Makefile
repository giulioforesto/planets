all:

	#~ gfortran main.f90 -o main.exe -fbounds-check -fno-backtrace -fimplicit-none -Wall -O0 
	gfortran main.f90 -o main.exe -fcheck=bounds -fno-backtrace -fimplicit-none -O0
	#~ gfortran main.f90 -o main.exe -fimplicit-none -Ofast -march=native -fwhole-program -ftree-parallelize-loops=4
	#~ gfortran main.f90 -o main.exe -fimplicit-none -Ofast -march=native -fwhole-program
	#~ gfortran main.f90 -o main.exe -fimplicit-none -march=native -fwhole-program 
	
	
	./main.exe
