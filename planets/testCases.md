#Test Cases
##Exploration tests
###File reading
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
