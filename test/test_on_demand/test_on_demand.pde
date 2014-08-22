/******************
 * TEST ON DEMAND *
 ******************/

String line = "";

try {
  long start = millis();
  
  BufferedReader reader = createReader("../test_1/test_long.txt");
  line = reader.readLine();
  println(millis() - start);
  println(line);
  
  line = "";
  
  long start2 = millis();
  reader.skip(23*900000 - 5);
  line = reader.readLine();
  println(millis() - start2);
  println(line);
  
} catch (Exception e) {
  e.printStackTrace();
}
