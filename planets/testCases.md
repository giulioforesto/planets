#Test Cases
##Exploration tests
###1. File reading
**Options:**

- Writing at the beginning of the file with Fortran
- Reading all the file each Frame
	- `BufferedReader`
	- `loadStrings()`
	- `loadJSONArray()` (don't forget final `']'`)

**Questions:**

- Doesn't the `BufferedReader` read all the file anyway?

**Tests:**

- Create 100.000-line files and test file reading methods above.
- Create long and short version of a file and compare `BufferedReader` reading time for the same first `n` lines. 

##Unit tests
###1. `getData()` execution time
**Requirement**:  
`getData()` must execute in approximately less than `1/(FRAME_RATE_PARAM*2)` seconds (factor 2 is due to display execution time that comes afterwards).
