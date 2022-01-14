#include <16F877A.h>
#device adc=10
#fuses HS,NOWDT,PUT,NOPROTECT,NODEBUG,NOBROWNOUT,NOLVP,NODEBUG
#use delay(clock=4000000)
#use rs232(baud=9600,parity=N,xmit=PIN_C6,rcv=PIN_C7,bits=8,stream=PORT1)
#include <stdlib.h>
#define LED1 PIN_D7
#define LED2 PIN_D6
#define DELAY 1000

int step_cycle=0,stepmotor=0,blink1=0,blink2=0,first_run=read_eeprom(255),motor_direction=2;
long int duty_1=512, duty_2=256, cicles=0, n_cicles=15;

#int_timer0
void timer_0(){  
   cicles=cicles+1;
   if (cicles>=n_cicles){
      step_cycle=step_cycle+1;
      cicles=0;
   }
   if(motor_direction==0){
         if(step_cycle>=7){
            printf("Got here!!!,Forward\r");
            step_cycle=0;
            if(stepmotor==0){
               output_low(PIN_D3);
               output_high(PIN_D0);
               stepmotor=1;
            }else if(stepmotor==1){
               output_low(PIN_D0);
               output_high(PIN_D1);
               stepmotor=2;
            }else if(stepmotor==2){
               output_low(PIN_D1);
               output_high(PIN_D2);
               stepmotor=3;
            }else if(stepmotor==3){
               output_low(PIN_D2);
               output_high(PIN_D3);
               stepmotor=0;
            }
         }
      }
      if(motor_direction==1){  
         if(step_cycle>=7){
            printf("Got here!!!,backward\r");
            step_cycle=0;
            if(stepmotor==0){
               output_low(PIN_D0);
               output_high(PIN_D3);
               stepmotor=1;
            }else if(stepmotor==1){
               output_low(PIN_D3);
               output_high(PIN_D2);
               stepmotor=2;
            }else if(stepmotor==2){
               output_low(PIN_D2);
               output_high(PIN_D1);
               stepmotor=3;
            }else if(stepmotor==3){
               output_low(PIN_D1);
               output_high(PIN_D0);
               stepmotor=0;
            }
         }
      }
      if(motor_direction==2){
         output_low(PIN_D0);
         output_low(PIN_D1);
         output_low(PIN_D2);
         output_low(PIN_D3);
      }
   set_timer0(6+get_timer0());
}

void main()
{    
    output_high(LED1);
    delay_ms(DELAY);
    output_high(LED2);
    delay_ms(DELAY);
    output_low(LED1);
    delay_ms(DELAY);
    output_low(LED2);
    
    if (first_run!=213){
      write_eeprom(0,-50);
      write_eeprom(1,-49);
      write_eeprom(2,-48);
      write_eeprom(3,-47);
      write_eeprom(4,-46);
      write_eeprom(5,250);
      write_eeprom(6,250);
      write_eeprom(7,256);
      write_eeprom(8,256);
      write_eeprom(9,125);
      write_eeprom(255,213);
   } 
   
   n_cicles=read_eeprom(9);
   
   //Setup timer0 interruption
   setup_timer_0(RTCC_INTERNAL|RTCC_DIV_32);  
   enable_interrupts(global|int_timer0);
   set_timer0(6);
     
    //Setup ADC
   setup_ADC_ports(RA0_analog);
   setup_ADC(ADC_CLOCK_INTERNAL);
   set_ADC_channel(0);

   //Setup PWM
   setup_timer_2(T2_DIV_BY_16,249,1);         //timer2 com prescaler de 16, PR2=249 e postscaler de 1
   setup_ccp2(ccp_pwm);                       //Configura CCP como pwm
   set_pwm2_duty(duty_1);                     //1024* %
   setup_ccp1(ccp_pwm);                       //Configura CCP como pwm
   set_pwm1_duty(duty_2);                     //1024* %
   
   output_low(PIN_D0);
   output_low(PIN_D1);
   output_low(PIN_D2);
   output_high(PIN_D3);
   
    while(true){
    
      if(blink1){
         output_high(LED1);
         delay_us(20); 
      }else{
         output_low(LED1);    
      }
      if(blink2){
         output_high(LED2);
      }else{
         output_low(LED2);
      }
    
       if(input(PIN_A1)==0){
            delay_ms(120);
            if(input(PIN_A1)==0){              
               motor_direction=0;
               blink1=1;
               blink2=0;
               cicles=0;
            }
       }
       
       if(input(PIN_A2)==0){
            delay_ms(120);
            if(input(PIN_A2)==0){
               motor_direction=1;
               blink1=0;
               blink2=1;
               cicles=0;
            }
       }
       
       if(input(PIN_A3)==0){
            delay_ms(120);
            if(input(PIN_A3)==0){
               motor_direction=2;
               blink1=1;
               blink2=1;
               cicles=0;
            }
       }
       
       if(input(PIN_A4)==0){
            delay_ms(120);
            if(input(PIN_A4)==0){
               delay_us(20);
               n_cicles=read_adc();  
               blink1=1;
               blink2=1;
               cicles=0;
               printf("O valor da variavel motor_direction equivale a: %d\r",motor_direction);
               printf("O valor da variavel n_cicles equivale a: %ld\r",n_cicles);
            }
       }
       
       if(input(PIN_A5)==0){
            delay_ms(120);
            if(input(PIN_A5)==0){
               write_eeprom(9,n_cicles);
               blink1=1;
               blink2=1;
               cicles=0;
            }
       }
      
 
    }
   
}
