#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

void OnStart()
{   
    for(int i=1; i<9; i++)
    {
        int a = Fibonacci(i);
        printf(a);
    }
      
}

int Fibonacci(int n)
{
    if(n<0)
    {
        return 0;
    }

    if(n == 0 || n==1)
    {
        return n;
    }

    int num1 = 0, num2 = 1;
    
    for(int i=2; i<=n; i++){
        num2 = num1+num2;
        num1 = num2-num1;
    }
    
    return num2;
}