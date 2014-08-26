/**********
 * TEST#1 *
 **********/

int NUMBER_OF_LINES = 99;
/*
 * Input file sample:
{'t':0,'x':[0,1]} 
{'t':1,'x':[0,1]} 
{'t':2,'x':[0,1]} 
{'t':3,'x':[0,1]} 
{'t':4,'x':[0,1]}
 *
 * t values must be ascendent and consecutive
 * NUMBER_OF_LINES must be lesser than maximum t.
 */

int test = 0;
String line = "";

int startLong = millis();
BufferedReader readerLong = createReader("test_long.txt");
while(test < NUMBER_OF_LINES) {
  try {
    line = readerLong.readLine();
    test = JSONObject.parse(line).getInt("t");
  } catch (IOException e) {
    e.printStackTrace();
    line = null;
  }
}
println(millis()-startLong);

test = 0;
line = "";

int startShort = millis();
BufferedReader readerShort = createReader("test_short.txt");
while(test < NUMBER_OF_LINES) {
  try {
    line = readerShort.readLine();
    test = JSONObject.parse(line).getInt("t");
  } catch (IOException e) {
    e.printStackTrace();
    line = null;
  }
}
println(millis()-startShort);
