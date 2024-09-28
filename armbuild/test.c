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