#Test Cases
##Exploration tests
###1. File reading
####Options

- Writing at the beginning of the file with Fortran
- Reading all the file each Frame
	- `BufferedReader`
	- `loadStrings()`
	- `loadJSONArray()` (don't forget final `']'`)

####Questions

- Doesn't the `BufferedReader` read all the file anyway?

####Tests

**1.** Create 1,000,000-line files and test file reading methods above.

**2.** Create long and short version of a file and compare `BufferedReader` reading time for the same first `n` lines. 
#####Buffered Reader
    File		| 1.000.000 l	| 1000 l	| 200 l		| 100 l
    ------------+---------------+-----------+-----------+---------
    1000 l read | 30 ms			| 32 ms		|			|
	------------+---------------+-----------+-----------+---------
	200 l read	| 9 ms			| 7 ms		| 7	ms		|
	------------+---------------+-----------+-----------+---------
	100 l read	| 6 ms			| 4 ms		| 4 ms 		| 4 ms

**Conclusion:** The `BufferedReader` time execution depends only on the number of lines it reads. The implementation of this method would imply that **the newest points are added to the beginning of the file**.

*Remark:* Reading 1,000 lines takes approximately 0.03 s, *ie* one 30th of a second. For a frame rate of 30, 500 is the maximum order of magnitude of the lines we can read during an iteration. 

##Unit tests
###1. `getData()` execution time
####Requirement  
`getData()` must execute in approximately less than `1/(FRAME_RATE_PARAM*2)` seconds (factor 2 is due to display execution time that comes afterwards).
