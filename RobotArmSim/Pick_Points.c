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

    // Step 3
    char bt_message;
    while (true) {
        if (kbhit()) { // Check if data is available from Bluetooth
            bt_message = getc(); // Read the message
            if (bt_message == 'P') {
                printf("Picking mode selected.\r\n");
                break;
            } else if (bt_message == 'R') {
                printf("Reading mode selected.\r\n");
                break;
            }
        }
    }
    // Step 4: Handle Picking Mode
   unsigned int memory_slot = 6; // Start from the sixth EEPROM slot
   bool finished = false;
   
   write_eeprom(1, 'S');  // Write 'S' to the first memory slot (indicating the start)
   
   bool initial_setup_finished = false;
   
   while (!initial_setup_finished) {
       printf("Please set the initial position of the motors. Use commands to move motors.\n");
   
       // Wait for a Bluetooth message (motor number, direction, and degrees)
       char command[6];
       for (int i = 0; i < 6; i++) { // Read the 6-character command
           while (!kbhit()); // Wait until a key is pressed
           command[i] = getc();
       }
   
       // Check if the received command is 'F' to finish initial setup
       if (command[0] == 'F') {
           initial_setup_finished = true;
           break;
       }
   
       // Extract the components from the command string
       char motor_number = command[0] - '0'; // Motor number (1–4)
       char direction = command[2];           // Direction (F or B)
       int degrees = (command[3] - '0') * 100 + (command[4] - '0') * 10 + (command[5] - '0'); // Degrees (0-255)
   
       if (direction == 'B') {
           degrees = -degrees;  // Convert to negative degrees for counterclockwise movement
       }
   
       // Validate the motor number and position
       if (motor_number >= 1 && motor_number <= 4) {
           int motor_index = motor_number - 1; // Get the motor index (0–3)
           int new_position = motor_position[motor_index] + degrees; // Calculate the new position
   
           if (new_position >= 0) { // Only update and move if the position is non-negative
               motor_positions[motor_index] = new_position;
   
               // Move the motor using the current motor number, degrees, and direction
               if (direction == 'F') {
                   move_motor(motor_index, degrees, 0);  // 0 for forward (clockwise)
               } else if (direction == 'B') {
                   move_motor(motor_index, degrees, 1);  // 1 for backward (counterclockwise)
               }
           } else {
               printf("Invalid operation: Motor %d position cannot go negative. Command ignored.\n", motor_number);
           }
       } else {
           printf("Invalid motor number: %d. Command ignored.\n", motor_number);
       }
   }
   
   // Write motor positions to memory slots 2–5
   for (int i = 0; i < 4; i++) {
       write_eeprom(2 + i, motor_position[i]); // Write motor 1 position to slot 2, motor 2 to slot 3, etc.
   }
   
   // Step 4.1: Wait for a Bluetooth message
   while (!finished) {
       // Step 4.1.1: Read the 6-character command
       char command[6];
       for (int i = 0; i < 6; i++) { // Read the 6-character command
           while (!kbhit()); // Wait until a key is pressed
           command[i] = getc();
       }
   
       // Step 4.2: Check if the received command is 'F' to finish
       if (command[0] == 'F') {
           write_eeprom(memory_slot, 'F');  // Write 'F' in the next memory slot to indicate the end
           write_eeprom(1, 'S');  // Write 'S' to the first memory slot as start marker
           finished = true;  // End the loop
           break;
       }
   
       // Extract the components from the command string
       char motor_number = command[0] - '0'; // Motor number (1–4)
       char direction = command[2];           // Direction (F or B)
       int degrees = (command[3] - '0') * 100 + (command[4] - '0') * 10 + (command[5] - '0'); // Degrees (0-255)
   
       if (direction == 'B') {
           degrees = -degrees;  // Convert to negative degrees for counterclockwise movement
       }
   
       // Step 4.3: Write the first command in the sixth slot of memory (one slot per command)
       if (memory_slot == 6) {
           // Write motor number, direction, and degrees (all in 3 bytes)
           write_eeprom(memory_slot, motor_number);  // Write motor number (1-4)
           write_eeprom(memory_slot + 1, direction); // Write direction ('F' or 'B')
           write_eeprom(memory_slot + 2, degrees);   // Write degrees (-255 to 255)
           memory_slot += 3; // Move to the next memory slot
           continue;
       }
   
       // Step 4.4: Handle the new command (whether it's for the same or different motor)
       char current_motor = motor_number;
       char current_direction = direction;
       int current_degrees = degrees;
   
       // Move the motor based on the current command
       if (current_motor >= 1 && current_motor <= 4) {
           // Move the motor using the current motor number, degrees, and direction
           if (current_direction == 'F') {
               move_motor(current_motor - 1, current_degrees, 0);  // 0 for forward (clockwise)
           } else if (current_direction == 'B') {
               move_motor(current_motor - 1, current_degrees, 1);  // 1 for backward (counterclockwise)
           }
       }
   
       // Step 4.5: Check the current command and the last command in EEPROM
       char last_motor = read_eeprom(memory_slot - 3);  // Read motor number from the last stored command
       char last_direction = read_eeprom(memory_slot - 2);  // Read direction from the last command
       int last_degrees = read_eeprom(memory_slot - 1);  // Read degrees (could be negative for counterclockwise)
   
       if (last_direction == 'B') {
           last_degrees = -last_degrees; // Convert the counterclockwise movement back to negative degrees
       }
   
       if (current_motor == last_motor) {
           // Combine movements for the same motor
           int combined_degrees = last_degrees + current_degrees;
   
           if (combined_degrees == 0) {
               // Movement cancels out, skip writing
               continue;
           }
   
           char combined_direction = (combined_degrees > 0) ? 'F' : 'B'; // Determine direction
           combined_degrees = abs(combined_degrees); // Use the absolute value of the degrees
   
           // Overwrite the last command with the combined result
           write_eeprom(memory_slot - 3, current_motor);  // Motor number
           write_eeprom(memory_slot - 2, combined_direction);  // Direction
           write_eeprom(memory_slot - 1, combined_degrees);  // Degrees (0-255)
       } else {
           // Different motors, write the new command in the next available slot
           if (memory_slot + 3 > 255) {
               // Reached EEPROM limit, write "F" to the next slot and finish
               write_eeprom(memory_slot, 'F');
               write_eeprom(1, 'S');  // Indicate end of the process in the first slot
               finished = true;
               break;
           }
   
           // Write the current command in the next available slot (same format as before)
           write_eeprom(memory_slot, current_motor);   // Motor number
           write_eeprom(memory_slot + 1, current_direction); // Direction
           write_eeprom(memory_slot + 2, current_degrees); // Degrees
           memory_slot += 3;  // Move to the next memory slot
       }
   }

   // Step 5: Reading logic with large iteration count support
   if (bt_message == 'R') { // Check if "Reading mode" is selected
       char first_slot = read_eeprom(1);
       if (first_slot != 'S') {
           printf("Picking was never chosen. Start there.\r\n");
           return; // Exit the function if picking mode wasn't set up
       }
   
       // Wait for the number of cycles
       unsigned long iteration_count = 0;
       char iter_msg[10]; // Buffer to store the number as a string
       int index = 0;
   
       printf("Enter the number of iterations (up to 9 digits):\r\n");
   
       while (true) {
           if (kbhit()) { // Check if data is available from Bluetooth
               char received_char = getc(); // Read one character
               if (received_char == '\n' || received_char == '\r') { 
                   // End of input (newline or carriage return)
                   iter_msg[index] = '\0'; // Null-terminate the string
                   iteration_count = atol(iter_msg); // Convert to unsigned long
                   printf("Repeating Step 5 for %lu iterations.\r\n", iteration_count);
                   break;
               } else if (index < sizeof(iter_msg) - 1) {
                   // Append character to the input buffer if within bounds
                   iter_msg[index++] = received_char;
               }
           }
       }
   
       // Repeat the execution of EEPROM commands for the given iteration count
       for (unsigned long iter = 0; iter < iteration_count; iter++) {
           printf("Iteration %lu of Step 5.\r\n", iter + 1);
   
           // Move motors to the initial positions saved in slots 2 to 5
           printf("Moving motors to initial positions saved in EEPROM slots 2-5.\r\n");
           bool all_motors_reached = false;
           while (!all_motors_reached) {
               all_motors_reached = true; // Assume all motors will reach their positions this loop
               for (int motor_index = 0; motor_index < 4; motor_index++) {
                   int target_position = read_eeprom(2 + motor_index); // Slot 2 = Motor 1, Slot 3 = Motor 2, etc.
                   int current_position = motor_position[motor_index]; // Get current motor position
   
                   if (current_position < target_position) {
                       int step = (target_position - current_position >= 3) ? 3 : (target_position - current_position);
                       move_motor(motor_index, step, 0); // Move forward (clockwise)
                       motor_position[motor_index] += step; // Update current position
                       all_motors_reached = false; // Not all motors have reached their positions yet
                   } else if (current_position > target_position) {
                       int step = (current_position - target_position >= 3) ? 3 : (current_position - target_position);
                       move_motor(motor_index, step, 1); // Move backward (counterclockwise)
                       motor_position[motor_index] -= step; // Update current position
                       all_motors_reached = false; // Not all motors have reached their positions yet
                   }
               }
           }
   
           // Execute commands saved in the EEPROM for the current iteration
           unsigned int read_slot = 6; // Start at slot 6
   
           while (true) {
               // Read 3 bytes: motor number, direction, and degrees
               char motor_num = read_eeprom(read_slot);    // Motor number (1-4)
               char direction = read_eeprom(read_slot + 1); // Direction ('F' or 'B')
               int degrees = read_eeprom(read_slot + 2);    // Degrees (0-255)
   
               // Check if we've reached the end of stored commands
               if (motor_num == 'F' || motor_num == 0) { 
                   printf("Reading complete for iteration %lu.\r\n", iter + 1);
                   break; // End this iteration if no valid command is found
               }
   
               // Move the motor based on the command
               if (direction == 'F') {
                   move_motor(motor_num - 1, degrees, 0); // Forward (clockwise)
               } else if (direction == 'B') {
                   move_motor(motor_num - 1, degrees, 1); // Backward (counterclockwise)
               }
   
               // Move to the next memory slot (3 bytes per command)
               read_slot += 3;
   
               // Check if the memory slot exceeds the EEPROM limit
               if (read_slot > 255) {
                   printf("Memory limit reached. Stopping iteration.\r\n");
                   break; // Stop processing if memory exceeds the limit
               }
           }
       }
   
       printf("All iterations of Step 5 are complete.\r\n");
   }
   

    // Step 6: Wait for Bluetooth message "F"
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

