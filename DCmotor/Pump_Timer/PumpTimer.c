//This code turns on and controls the time of working for two pumps

#include <16F877A.h>
#device ADC=10
#include <stdio.h>
#use delay(clock=4000000)
#fuses XT,NOWDT,PUT,NOPROTECT,NODEBUG,NOBROWNOUT,NOLVP,NODEBUG
#include <lcd2.c>

int n=1, s1=0, s2=0, ciclos=0, i1=read_eeprom(254), i2=read_eeprom(255), k=1,l=1,p=0,j=read_eeprom(253);
long int t1=0, t2=0;

#int_timer0
   void tempo(){
      ciclos++;
      if(ciclos==125){
         k=1;
         if (t1>0){
         t1=t1-1;
         }
         if (t2>0){
         t2=t2-1;
         }
         ciclos=0;
         if (t1==0){
            output_low(PIN_D2);
            s1=0;
         }
         if (t2==0){
            output_low(PIN_D3);
            s2=0;
         }
      }
      set_timer0(6+get_timer0());
   }


void main(void){

//zera todos os pinos
   output_low(PIN_A0);
   output_low(PIN_A1);
   output_low(PIN_A2);
   output_low(PIN_A3);
   output_low(PIN_A4);
   output_low(PIN_A5);
   output_low(PIN_B0);
   output_low(PIN_B1);
   output_low(PIN_B2);
   output_low(PIN_B3);
   output_low(PIN_B4);
   output_low(PIN_B5);
   output_low(PIN_B6);
   output_low(PIN_B7);
   output_low(PIN_C0);
   output_low(PIN_C1);
   output_low(PIN_C2);
   output_low(PIN_C3);
   output_low(PIN_C4);
   output_low(PIN_C5);
   output_low(PIN_C6);
   output_low(PIN_C7);
   output_low(PIN_D0);
   output_low(PIN_D1);
   output_low(PIN_D2);
   output_low(PIN_D3);
   output_low(PIN_D4);
   output_low(PIN_D5);
   output_low(PIN_D6);
   output_low(PIN_D7);
   output_low(PIN_E0);
   output_low(PIN_E2);
   output_low(PIN_E1);

   //setup
   lcd_init();
   lcd_putc("\f");//apaga lcd
   setup_ADC_ports(RA0_RA1_RA3_analog);
   setup_ADC(ADC_CLOCK_INTERNAL);
   set_ADC_channel(1);
   setup_timer_0(RTCC_INTERNAL|RTCC_DIV_32);
   enable_interrupts(global|int_timer0);
   set_timer0(6);
   
   //definindo tempo inicial
   
   if (j!=213){
      write_eeprom(254,45);
      write_eeprom(255,20);
      write_eeprom(253,213);
   }  

   while(true){
   
   p=0;
   
   //botao liga bomba 1
   if(input(PIN_B0)==0){
         delay_ms(120);
         if(input(PIN_B0)==0){
            if (s2==0){
               s1=1;
               output_high(PIN_D2);
               t1=read_eeprom(254);
               t1=t1*60;
               k=1;
            }
            }
   }
   
   //Botao liga bomba 2
   if(input(PIN_B1)==0){
         delay_ms(120);
         if(input(PIN_B1)==0){
            if (s1==0){
               s2=1;
               output_high(PIN_D3);
               t2=read_eeprom(255);
               t2=t2*60;
               k=1;
            }
         }
   }
 
 //imprime estado da bomba no lcd
   
   if (k==1){
   if (s1==1){
      if (s2==1){
         printf(lcd_putc,"\fBomba1: %ld:%ld",t1/60,t1%60);
         printf(lcd_putc,"\nBomba2: %ld:%ld",t2/60,t2%60);
      }else {
         printf(lcd_putc,"\fBomba1: %ld:%ld",t1/60,t1%60);
         printf(lcd_putc,"\nBomba2:Desligada");
      }
   }
   
   if (s1==0){
      if (s2==1){
         printf(lcd_putc,"\fBomba1:Desligada");
         printf(lcd_putc,"\nBomba2: %ld:%ld",t2/60,t2%60);
      }else {
         printf(lcd_putc,"\fBomba1:Desligada");
         printf(lcd_putc,"\nBomba2:Desligada");
      }
   }
   k=0;
   }
   
   //chama as opcoes
   if(input(PIN_B2)==0){
      delay_ms(120);
      if(input(PIN_B2)==0){
      
      delay_ms(500);
      l=1;
      
      while(p==0){
         
         if(l==1){
            lcd_putc("\f");
            printf(lcd_putc,"Bomba %d",n);
            l=0;
         }
         
         if(input(PIN_B3)==0){
               delay_ms(120);
               if(input(PIN_B3)==0){
                  l=1;
                  if (n==1){
                     n=2;
                  }else{
                     n=1;
                  }
               }
         }     
          
         if(input(PIN_B4)==0){
               delay_ms(120);
               if(input(PIN_B4)==0){
                  l=1;
                  if (n==1){
                     n=2;
                  }else{
                     n=1;
                  }
               }
         }
         
         if(input(PIN_B2)==0){
               delay_ms(120);
               if(input(PIN_B2)==0){
         
                  if (n==1){
                  j=1;
                  
                     delay_ms(500);
                     
                     while (p==0){
                     
                        if (j==1){
                           lcd_putc("\f");//apaga lcd
                           printf(lcd_putc,"Tempo1: %d min",i1);
                           j=0;
                        }
                        
                       if(input(PIN_B3)==0){
                         delay_ms(120);
                         if(input(PIN_B3)==0){ 
                           i1=i1+1;
                           j=1;
                         }
                        }
                        
                        if(input(PIN_B4)==0){
                         delay_ms(120);
                         if(input(PIN_B4)==0){ 
                           i1=i1-1;
                           j=1;
                         }
                        }
                        
                        if(input(PIN_B2)==0){
                         delay_ms(120);
                         if(input(PIN_B2)==0){ 
                           write_eeprom(254,i1);
                           printf(lcd_putc,"\fTempo 1 gravado\n na memoria");
                           delay_ms(2000);
                           p=1;
                         }
                        }
                        
                        
                       }
                  
                  }else{
                  j=1;
                  
                     delay_ms(500);
                     
                     while (p==0){
                     
                        if (j==1){
                           lcd_putc("\f");//apaga lcd
                           printf(lcd_putc,"Tempo2: %d min",i2);
                           j=0;
                        }
                        
                       if(input(PIN_B3)==0){
                         delay_ms(120);
                         if(input(PIN_B3)==0){ 
                           i2=i2+1;
                           j=1;
                         }
                        }
                        
                        if(input(PIN_B4)==0){
                         delay_ms(120);
                         if(input(PIN_B4)==0){ 
                           i2=i2-1;
                           j=1;
                         }
                        }
                        
                       if(input(PIN_B2)==0){
                         delay_ms(120);
                         if(input(PIN_B2)==0){ 
                           write_eeprom(255,i2);
                           printf(lcd_putc,"\fTempo 2 gravado\n na memoria");
                           delay_ms(2000);
                           p=1;
                         }
                        } 
                        
                       }
                       
                     }
                  }
               }
         } 
              
      }
   }  
}
}
