#include "add.h"
#include "subtraction.h"
#include <stdio.h>

int main(void){
    int result = 0;
    result = add(10, 20);
    printf("add restult is %d .\n\r", result);

    result = subtraction(20, 10);
    printf("subtraction restult is %d .\n\r", result);

}
