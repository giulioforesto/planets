/******************
 * TEST ON DEMAND *
 ******************/

import java.io.InputStreamReader;

try {
  File file = new File("./test.txt");
  println(file.getAbsolutePath());
  
  PrintWriter writer = new PrintWriter(file);
  writer.println("ciao");
  
  long start = millis();
  
  //BufferedReader in = new BufferedReader(new InputStreamReader(new ReverseLineInputStream(file)));
  //String line = in.readLine();
  
  //println(line);
  
  println(millis() - start);
}
catch (Exception e) {
  e.printStackTrace();
}
