FC=gfortran

FEFTFLAGS=-O3 -fimplicit-none
#~ FEFTFLAGS=-fbounds-check -fbacktrace -fimplicit-none

FFLAGS=-fimplicit-none -Ofast
#~ FFLAGS=-fbounds-check -fbacktrace -fimplicit-none

EFTDIR = ./eftlib
EFTLIB = eftlib8

all:

	$(FC) -c $(EFTDIR)/$(EFTLIB).f90 $(FEFTFLAGS) -o $(EFTDIR)/$(EFTLIB).o
	
	$(FC)  main.f90 -o main.exe $(FFLAGS) $(EFTDIR)/$(EFTLIB).o
	
	rm *.mod
