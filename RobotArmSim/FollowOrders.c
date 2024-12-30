#include <16F877A.h>
#device adc=10
#fuses HS,NOWDT,PUT,NOPROTECT,NODEBUG,NOBROWNOUT,NOLVP,NODEBUG
#use delay(clock=4000000)
#use rs232(baud=9600,parity=N,xmit=PIN_C6,rcv=PIN_C7,bits=8,stream=PORT1)
#include <stdlib.h>

// Pin definitions
#define MOTOR1_PIN_D0 PIN_D0
#define MOTOR1_PIN_D1 PIN_D1
#define MOTOR1_PIN_D2 PIN_D2
#define MOTOR1_PIN_D3 PIN_D3

#define MOTOR2_PIN_D0 PIN_E0
#define MOTOR2_PIN_D1 PIN_E1
#define MOTOR2_PIN_D2 PIN_E2
#define MOTOR2_PIN_D3 PIN_E3

#define MOTOR3_PIN_D0 PIN_C0
#define MOTOR3_PIN_D1 PIN_C1
#define MOTOR3_PIN_D2 PIN_C2
#define MOTOR3_PIN_D3 PIN_C3

#define MOTOR4_PIN_D0 PIN_B0
#define MOTOR4_PIN_D1 PIN_B1
#define MOTOR4_PIN_D2 PIN_B2
#define MOTOR4_PIN_D3 PIN_B3

#define BUTTON1_PIN PIN_A0
#define BUTTON2_PIN PIN_A1
#define BUTTON3_PIN PIN_A2
#define BUTTON4_PIN PIN_A3
#define BUTTON5_PIN PIN_A4

// Motor state variables
int motor_position[4] = {180, 180, 180, 180}; // Initial positions
int motor_active[4] = {1, 1, 1, 1};           // Track active motors
int step_cycle[4] = {0, 0, 0, 0};             // Counter for each motor's timer cycles
int stepmotor[4] = {0, 0, 0, 0};              // Current step for each motor
int motor_speed = 7;                          // Speed of rotation (adjustable)
int motor_direction[4] = {1, 1, 1, 1};        // All motors start moving backward (counterclockwise)

// EEPROM memory slot tracking
unsigned int memory_slot = 2; // Start at slot 2, slot 1 reserved for "S"

#INT_TIMER0
void timer0_isr() {
    for (int i = 0; i < 4; i++) {
        if (motor_active[i] == 0) continue; // Skip motors that are no longer active

        if (motor_direction[i] == 0) { // Forward (clockwise)
            if (step_cycle[i] >= motor_speed) {
                step_cycle[i] = 0;
                if (stepmotor[i] == 0) {
                    output_low(MOTOR1_PIN_D3 + i * 4);
                    output_high(MOTOR1_PIN_D0 + i * 4);
                    stepmotor[i] = 1;
                } else if (stepmotor[i] == 1) {
                    output_low(MOTOR1_PIN_D0 + i * 4);
                    output_high(MOTOR1_PIN_D1 + i * 4);
                    stepmotor[i] = 2;
                } else if (stepmotor[i] == 2) {
                    output_low(MOTOR1_PIN_D1 + i * 4);
                    output_high(MOTOR1_PIN_D2 + i * 4);
                    stepmotor[i] = 3;
                } else if (stepmotor[i] == 3) {
                    output_low(MOTOR1_PIN_D2 + i * 4);
                    output_high(MOTOR1_PIN_D3 + i * 4);
                    stepmotor[i] = 0;
                }
            }
        }
        if (motor_direction[i] == 1) { // Backward (counterclockwise)
            if (step_cycle[i] >= motor_speed) {
                step_cycle[i] = 0;
                if (stepmotor[i] == 0) {
                    output_low(MOTOR1_PIN_D0 + i * 4);
                    output_high(MOTOR1_PIN_D3 + i * 4);
                    stepmotor[i] = 1;
                } else if (stepmotor[i] == 1) {
                    output_low(MOTOR1_PIN_D3 + i * 4);
                    output_high(MOTOR1_PIN_D2 + i * 4);
                    stepmotor[i] = 2;
                } else if (stepmotor[i] == 2) {
                    output_low(MOTOR1_PIN_D2 + i * 4);
                    output_high(MOTOR1_PIN_D1 + i * 4);
                    stepmotor[i] = 3;
                } else if (stepmotor[i] == 3) {
                    output_low(MOTOR1_PIN_D1 + i * 4);
                    output_high(MOTOR1_PIN_D0 + i * 4);
                    stepmotor[i] = 0;
                }
            }
        }
        if (motor_direction[i] == 2) { // Stop
            output_low(MOTOR1_PIN_D0 + i * 4);
            output_low(MOTOR1_PIN_D1 + i * 4);
            output_low(MOTOR1_PIN_D2 + i * 4);
            output_low(MOTOR1_PIN_D3 + i * 4);
        }
        step_cycle[i]++; // Increment step cycle for each motor individually
    }
    set_timer0(6 + get_timer0()); // Maintain consistent timing
}

void move_motor(int motor_num, int degrees, int direction) {
    motor_direction[motor_num] = direction; // Set direction
    motor_active[motor_num] = 1;           // Activate motor
    int steps = degrees / 3;               // Each step is 3 degrees
    for (int i = 0; i < steps; i++) {
        delay_ms(20); // Delay to simulate motor movement
    }
    motor_active[motor_num] = 0; // Stop motor after movement
    motor_direction[motor_num] = 2; // Set to stop
}

void return_to_zero_and_adjust() {
    // Reset all motors to zero position
    motor_active[0] = motor_active[1] = motor_active[2] = motor_active[3] = 1; // Reactivate all motors
    motor_direction[0] = motor_direction[1] = motor_direction[2] = motor_direction[3] = 1; // Move counterclockwise

    // Wait until all buttons are pressed
    while (input(BUTTON1_PIN) == 0 || input(BUTTON2_PIN) == 0 || input(BUTTON3_PIN) == 0 || 
           (input(BUTTON4_PIN) == 0 && input(BUTTON5_PIN) == 0));

    // Stop all motors
    motor_active[0] = motor_active[1] = motor_active[2] = motor_active[3] = 0;

    // Move each motor 3 degrees clockwise
    for (int i = 0; i < 4; i++) {
        move_motor(i, 3, 0); // 0 = Forward (clockwise)
    }
}

void main() {
    setup_timer_0(RTCC_INTERNAL | RTCC_DIV_32); // Timer0 configuration
    enable_interrupts(INT_TIMER0);
    enable_interrupts(GLOBAL);
    set_timer0(6);

    // Step 1: Move the first three motors
    while (true) {
        for (int i = 0; i < 3; i++) {
            if (motor_active[i]) {
                // Rotate motor 3 degrees
                motor_position[i] -= 3;
                if (motor_position[i] <= 0) {
                    motor_position[i] = 0;
                    motor_active[i] = 0;
                    motor_direction[i] = 2; // Stop motor
                }
                delay_ms(20); // Control motor rotation speed
            }
        }

        // Check if buttons are pressed
        if (input(BUTTON1_PIN) == 0) {
            motor_active[0] = 0;
            motor_position[0] = 0;
            motor_direction[0] = 2; // Stop motor 1
        }
        if (input(BUTTON2_PIN) == 0) {
            motor_active[1] = 0;
            motor_position[1] = 0;
            motor_direction[1] = 2; // Stop motor 2
        }
        if (input(BUTTON3_PIN) == 0) {
            motor_active[2] = 0;
            motor_position[2] = 0;
            motor_direction[2] = 2; // Stop motor 3
        }

        // Break the loop if all motors are inactive
        if (motor_active[0] == 0 && motor_active[1] == 0 && motor_active[2] == 0) {
            break;
        }
    }

    // Step 2: Move the fourth motor
    while (motor_active[3]) {
        motor_position[3] -= 3; // Rotate motor 4 counterclockwise by 3 degrees
        if (motor_position[3] <= 0) {
            motor_position[3] = 0; // Ensure it doesn't go negative
            motor_active[3] = 0;
            motor_direction[3] = 2; // Stop motor 4
        }

        // Check if button 4 or button 5 is pressed
        if (input(BUTTON4_PIN) == 0 || input(BUTTON5_PIN) == 0) {
            motor_active[3] = 0;
            motor_position[3] = 0;
            motor_direction[3] = 2; // Stop motor 4
        }

        delay_ms(20); // Control motor rotation speed
    }

    // Step 3: Handle Bluetooth messages to control motor movements
   printf("Waiting for Bluetooth commands...\r\n");
   
   while (true) {
       if (kbhit()) { // Check if data is available from Bluetooth
           char mode_message = getc(); // Read the mode selection message
           if (mode_message == 'F') {
               printf("Step 3 finished.\r\n");
               break; // Exit the loop
           }
       }
   
       char command[6];
       for (int i = 0; i < 6; i++) { // Read the 6-character command
           while (!kbhit()); // Wait until a key is pressed
           command[i] = getc();
       }
   
       // Parse the command
       char motor_number = command[0] - '0'; // Motor number (1–4)
       char direction = command[2];         // Direction (F or B)
       int degrees = (command[3] - '0') * 100 + (command[4] - '0') * 10 + (command[5] - '0'); // Degrees (0-255)
   
       if (direction == 'B') {
           degrees = -degrees; // Convert to negative degrees for counterclockwise movement
       }
   
       // Validate the motor number and position
       if (motor_number >= 1 && motor_number <= 4) {
           int motor_index = motor_number - 1; // Get the motor index (0–3)
           int new_position = motor_position[motor_index] + degrees; // Calculate the new position
   
           if (new_position >= 0) { // Only update and move if the position is non-negative
               motor_position[motor_index] = new_position;
   
               // Move the motor using the current motor number, degrees, and direction
               if (direction == 'F') {
                   move_motor(motor_index, degrees, 0);  // 0 for forward (clockwise)
               } else if (direction == 'B') {
                   move_motor(motor_index, -degrees, 1);  // 1 for backward (counterclockwise)
               }
   
               // Provide feedback to the user
               printf("Motor %d moved %d degrees %s. Current position: %d.\r\n",
                      motor_number,
                      abs(degrees),
                      (direction == 'F' ? "clockwise" : "counterclockwise"),
                      motor_position[motor_index]);
           } else {
               printf("Invalid operation: Motor %d position cannot go negative. Command ignored.\r\n", motor_number);
           }
       } else {
           printf("Invalid motor number: %d. Command ignored.\r\n", motor_number);
       }
   }

    // Step 4: Wait for Bluetooth message "F"
    char bt_message;
    while (true) {
        bt_message = getc();
        if (bt_message == 'F') {
            printf("Returning to zero position...\r\n");
            return_to_zero_and_adjust(); // Move to zero and adjust
            printf("Adjustment complete.\r\n");
            break; // Finish execution
        }
    }
}
