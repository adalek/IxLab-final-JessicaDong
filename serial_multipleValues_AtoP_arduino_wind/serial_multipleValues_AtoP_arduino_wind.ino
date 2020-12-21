// IMA NYU Shanghai
// Interaction Lab
// For sending multiple values from Arduino to Processing

// Universiteit Twente
// Practical lab
// Course: Sensors(201000190)
// For making a "wind speed sensor" with a dc motor
// https://www.studocu.com/en-us/u/4171163?sid=01608458719
int zero=192;

void setup() {
  Serial.begin(9600);
}

void loop() {
  int sensor1 = analogRead(A0);
  sensor1=sensor1-zero;
  //int sensor2 = analogRead(A1);
  //int sensor3 = analogRead(A2);

  // keep this format
  Serial.print(sensor1);
//  Serial.print(",");  // put comma between sensor values
//  Serial.print(sensor2);
//  Serial.print(",");
//  Serial.print(sensor3);
  Serial.println(); // add linefeed after sending the last sensor value

  // too fast communication might cause some latency in Processing
  // this delay resolves the issue.
  //delay(300);
}
