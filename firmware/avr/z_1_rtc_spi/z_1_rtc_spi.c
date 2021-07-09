#include "z_1_rtc_spi.h"

// Initialize SPI Master Device (without interrupt)
void spi_init_master (void)
{
    PRR1 = PRR1 & ~(1<<PRSPI1);
    // Set MOSI, SCK, SS as Output
    set_output(DDRE, PE2);
    set_output(DDRE, PE3);
    set_output(DDRC, PC1);
    set_input(DDRC, PC0);

    // Enable SPI, Set as Master
    //Prescaler: Fosc/128
    SPCR1 = (1<<SPE)|(1<<MSTR)|(0x3<<SPR0)|(0<<SPIE);
}

//Function to send and receive spi data for both master and slave
unsigned char spi_tranceiver (unsigned char data)
{
    // Load data into the buffer
    SPDR1 = data;

    //Wait until transmission complete
    while(!(SPSR1 & (1<<SPIF) ));
    
    // Return received data
    return(SPDR1);
}
