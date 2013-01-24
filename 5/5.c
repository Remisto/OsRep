#include <stdio.h>
#include <ucontext.h>
#include <sys/time.h>

int NumberOfContexts = 10;
int StackSize = 1024;

struct context_options{
    int ContextId;
    int ContextStatus;
    int ContextSleepTime;
	char Stack[STACK_SIZE];
	char ExitStack[STACK_SIZE];
	ucontext_t Context;
	ucontext_t ExitContext;
};

ucontext_t SchedulerContext;
context_options MyTreads[NumberOfContexts];
int CurrentContextId = 0;


int main(){
	int i;
	for (i = 1; i < NumberOfContexts; i++) {
		MyTreads[i].ContextStatus = 0;//Free Tread
	}
	
	return 0;
}