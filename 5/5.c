#include <ucontext.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>

int NumberOfContexts = 10;
int StackSize = 1024;

struct ContextOptions{
    int ContextId;
    int ContextStatus;
    ucontext_t Context;
    int ContextSleepTime;
};
ucontext_t SchedulerContext;

int main(){
	
	return 0;
}