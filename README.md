#Planets
A 2D plotted planets movement simulator
##Simulator
##Interface
The Simulator's output, which is the Plotter input, is a JSON formatted data file including, for each outputted sample of the simulation, the 2D coordinates of each planet, the simulation time variable value and all the masses of the planets if one of them has changed from the previous sample.  
The object is an array that contains an object per sample.  
The positions and the masses are identified by a planet id (string code ranging from `'0001'` to `'9999'`) that remains the same for the whole simulation.

Object structure (one output sample represented):

	[{
		t: <num>,
		x: {
			0001: [<x>, <y>],
			0002: [<x>, <y>]
		},
		m: {
			0001: <num>
		}
	},
	...
	]
##Plotter
