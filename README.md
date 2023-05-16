# Plant-Monitoring-System

## I. Introduction to the problem and the solution
Plant monitoring system is an arduino based automated system to monitor the status of your plants in order to provide them with the highest quality environtment to maximize growth quality. The system will monitor certain environtment quality such as soil moisture, sorrounding environtment temperature, and humidity of air. 3 LEDs will act as indicators of environtment quality ranging from healthy to critical.

The problem that necessitates the existence of the Plant Monitoring System is the challenge of effectively monitoring and maintaining optimal environmental conditions for plants. In traditional plant care practices, it can be difficult for individuals to accurately determine the specific needs of different plant species in terms of moisture levels, temperature, and light requirements. This lack of precision often results in suboptimal plant health, leading to stunted growth, disease susceptibility, or even plant mortality.

The Plant Monitoring System addresses this problem by providing an automated and precise monitoring solution for plant care. The system incorporates sensors to measure key environmental parameters such as moisture levels, temperature, and light intensity. By collecting and analyzing this data, the system can provide real-time feedback and notifications to users, alerting them to any deviations from the optimal conditions for plant growth. Additionally, the system can offer recommendations and actionable insights to guide users in adjusting the environmental factors to maintain healthy plant growth.

## II. Hardware design and implementation details
The hardware and design implementation of the Plant Monitoring System involves several components and considerations to ensure accurate monitoring and reliable performance. The following are the key hardware components and design considerations for the system:

### Components:
### 1. Arduino UNO R3
<img src="./docs/Ardunio%20UNO%20R3.jpeg" width="80">
### 2. YL39 sensor
![YL39](./docs/YL39.jpg | width=80)
### 3. DHT11 sensor
![DHT11](./docs/DHT11.jpg | width=80)
### 4. 3 LEDs
![LED](./docs/LED.jpg | width=80)
### 5. Resistors
![Resistor](./docs/Resistor.jpg | width=80)
### 6. MAX7219
![MAX7219](./docs/MAX7219.jpg | width=80)
### 7. Buzzer
![Buzzer](./docs/buzzer.jpg | width=80)
### 8. LDR Module
![ldr](./docs/ldr.jpg | width=80)

The system is built around an Arduino microcontroller, which serves as the central processing unit. The Arduino board provides the necessary computational power and interfaces to connect and control various hardware modules.

Sensors:

**a. Moisture Sensor:** A moisture sensor is used to measure the moisture level in the soil or growing medium. It is typically connected to the Arduino board via digital input pins.

**b. Temperature and Humidity Sensor:** A temperature and humidity sensor, such as the DHT series sensor, is utilized to measure ambient temperature and humidity. This sensor is connected to the Arduino board through digital input/output pins.

**c. Light Sensor:** A light-dependent resistor (LDR) is used to measure the intensity of light in the plant's environment. The LDR is connected to the Arduino board through digital input pins.

A display module, such as MAX7219 seven segment display, can be incorporated to provide real-time feedback and visualization of the sensor readings and system status. The display module is connected to the Arduino board through appropriate communication protocols such as SPI.

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
