#include <ucontext.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>

int NumberOfContexts = 10;
int StackSize;

struct ContextOptions{
    int ContextId;
    int ContextStatus;
    ucontext_t Context;
    int ContextSleepTime;
};

int main(){
	
	return 0;
}