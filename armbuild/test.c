void irq_main(int irq_r0){
    static int *p=(int *)0x4008;
    static int c=0;
    int spsr;
    p[0]=irq_r0;
    p[1]=(int)0x0d000721;
    p+=2;
    c++;
    // only two interrupts are handled
    if(c==2){
        __asm__ volatile (
            "mrs %0, SPSR\n"
            "orr %0, #0x80\n"
            "msr SPSR, %0\n"
            : "+r" (spsr)
        );
    }
}

int fib(int n){
    if (n<3){
        return 1;
    }else{
        return fib(n-1) + fib(n-2);
    }        
}

void main()
{
    int *p=(int *)0x4000;
    *p=fib(10);
}