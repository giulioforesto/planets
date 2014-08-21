/******************
 * TEST ON DEMAND *
 ******************/

BufferedReader reader = createReader("test_2.txt");

try {
  String line = reader.readLine();
  println(line);
  
  while(millis() < 10000) {}
  
  line = reader.readLine();
  println(line);
  
} catch (Exception e) {
  e.printStackTrace();
}
