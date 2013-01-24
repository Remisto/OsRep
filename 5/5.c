#include <stdio.h>
#include <ucontext.h>
#include <sys/time.h>

int Interval 100;  
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

void schedul_function(int signal){
	int CurrentId, NextId = 0;
}	

int main(){
	int i;
	for (i = 1; i < NumberOfContexts; i++) {
		MyTreads[i].ContextStatus = 0;//Free Tread
	}
	struct itimerval AlarmInterval;
	
	AlarmInterval.it_interval.tv_sec = 0;
	AlarmInterval.it_interval.tv_usec = Interval*1000;
	AlarmInterval.it_value.tv_sec = 0;
	AlarmInterval.it_value.tv_usec = Interval*1000;
	setitimer(ITIMER_REAL, &AlarmInterval, 0);
	
	signal(SIGALRM, schedul_function); 
	
	return 0;
}