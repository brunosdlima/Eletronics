#include <16F877A.h>
#device adc=10
#fuses HS,NOWDT,PUT,NOPROTECT,NODEBUG,NOBROWNOUT,NOLVP,NODEBUG
#use delay(clock=4000000)
#use rs232(baud=9600,parity=N,xmit=PIN_C6,rcv=PIN_C7,bits=8,stream=PORT1)
#include <stdlib.h>
#define LED1 PIN_D7
#define LED2 PIN_D6
#define DELAY 1000

int blink1=0,blink2=0,first_run=read_eeprom(255), cicles=0, dc1=2, dc2=2;
long int duty_1=512, duty_2=256;

#int_timer0
void timer_0(){  
   cicles=cicles+1;
   if (cicles==125){
      blink1=0;
      blink2=0;
      set_pwm2_duty(duty_1);
      set_pwm1_duty(duty_2);
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
      write_eeprom(255,213);
   } 
   
   duty_1=read_eeprom(7);
   duty_2=read_eeprom(8);
   
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
   
    while(true){
    
      if(blink1){
         output_high(LED1);
         delay_us(20); 
         printf("O valor da variavel read_adc equivale a: %ld\r",duty_1=read_adc());
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
               delay_us(20);
               duty_1=read_adc();
               if(duty_1<=32){
                  duty_1=32;
               }
               blink1=1;
               blink2=0;
               cicles=0;
               dc1=1;
               printf("O valor da variavel duty_1 equivale a: %ld\r",duty_1);
            }
       }
       
       if(input(PIN_A2)==0){
            delay_ms(120);
            if(input(PIN_A2)==0){
               delay_us(20);
               duty_1=read_adc();
               if(duty_1>=1024){
                  duty_1=1024;
               }
               dc1=0;
               blink1=1;
               blink2=0;
               cicles=0;
            }
       }
       
       if(input(PIN_A3)==0){
            delay_ms(120);
            if(input(PIN_A3)==0){
               delay_us(20);
               duty_2=read_adc();
               if(duty_2<=32){
                  duty_2=32;
               }
               dc2=1;
               blink1=0;
               blink2=1;
               cicles=0;
               printf("O valor da variavel duty_2 equivale a: %ld\r",duty_2);
            }
       }
       
       if(input(PIN_A4)==0){
            delay_ms(120);
            if(input(PIN_A4)==0){
               delay_us(20);
               duty_2=read_adc();
               if(duty_2>=1024){
                  duty_2=1024;
               }
               dc2=0;
               blink1=0;
               blink2=1;
               cicles=0;
            }
       }
       
       if(input(PIN_A5)==0){
            delay_ms(120);
            if(input(PIN_A5)==0){
               write_eeprom(7,duty_1);
               write_eeprom(8,duty_2);
               blink1=1;
               blink2=1;
               cicles=0;
               dc1=2;
               dc2=2;
            }
       }
       
       if(dc1==0){
         output_low(PIN_C3);
         delay_ms(120);
         output_high(PIN_C0);
       }else if(dc1==1){
         output_low(PIN_C0);
         delay_ms(120);
         output_high(PIN_C3);
       }else{
         output_low(PIN_C3);
         output_low(PIN_C0);
       }
       
       if(dc2==0){
         output_low(PIN_C5);
         delay_ms(120);
         output_high(PIN_C4);
       }else if(dc2==1){
         output_low(PIN_C4);
         delay_ms(120);
         output_high(PIN_C5);
       }else{
         output_low(PIN_C5);
         output_low(PIN_C4);
       }
      
 
    }
   
}
