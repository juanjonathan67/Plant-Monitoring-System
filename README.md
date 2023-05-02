# Plant-Monitoring-System

Plant monitoring system is an arduino based automated system to monitor the status of your plants in order to provide them with the highest quality environtment to maximize growth quality. The system will monitor certain environtment quality such as soil moisture, sorrounding environtment temperature, and humidity of air. 5 LEDs will act as indicators of environtment quality ranging from healthy to critical.

## Hardware
### 1. Arduino UNO R3
![Arduino UNO R3](./docs/Ardunio%20UNO%20R3.jpeg)
### 2. YL39 sensor
![YL39](./docs/YL39.jpg)
### 3. DHT11 sensor
![DHT11](./docs/DHT11.jpg)
### 4. 5 LEDs
![LED](./docs/LED.jpg)
### 5. Resistors
![Resistor](./docs/Resistor.jpg)
### 6. MAX7219
![MAX7219](./docs/MAX7219.jpg)

## Software
### [Ardunio IDE 2](https://www.arduino.cc/en/software)
Arduino IDE 2 will be used to flash the program into the arduino via USB type B cable.
### AVR Assembly
The program is fully written in AVR Assembly, thus it is designed and only tested on Arduino UNO R3, specifically ATMega328p processor. This was not tested on any other device.

## Connection Diagram & Simulation

## How to Use
1. Connect all hardware following the Connection Diagram
2. Clone the repository
```
git clone https://github.com/juanjonathan67/Plant-Monitoring-System.git
```
3. Open Plant-Monitoring-System with Arduino IDE 2
4. Connect the Arduino to your computer using a USB type A to type B cable
5. Make sure it has successfully connected by checking COM port (Windows) or /dev/ttyUSB0 (Ubuntu)
6. Set the board to be Arduino UNO R3
7. Upload by clicking the arrow key icon next to the checklist icon

## Contributors
