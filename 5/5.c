#include <stdio.h>
#include <ucontext.h>
#include <sys/time.h>
#define NumberOfContexts 10;
#define MyInterval 100

int thread_create(void(*)(), int);
void thread_exit();
void thread_wait(int);
void thread_sleep(int);
void my_thread(int);
void schedul_function(int);

int StackSize = 1024;
int TreadId[NumberOfContexts];
struct context_options{
    int ContextId;
    int ContextStatus;
    int ContextSleepTime;
	char Stack[StackSize];
	char ExitStack[StackSize];
	ucontext_t Context;
	ucontext_t ExitContext;
};

ucontext_t SchedulerContext;
context_options MyTreads[NumberOfContexts];
int CurrentContextId = 0;

int thread_create(void(*func)(), int tnumber){
	int id;
	for(id = 1; id < NumberOfContexts; id++){
		if(MyTreads[id].ContextStatus == 0){
			MyTreads[id].ContextId = id;
			MyTreads[id].ContextStatus = 1;
			MyTreads[id].ContextSleepTime = 0;
			break;
		}
	}

	getcontext(&MyTreads[id].ExitContext);
	MyTreads[id].ExitContext.uc_stack.ss_sp = MyTreads[id].ExitStack;
	MyTreads[id].ExitContext.uc_stack.ss_size = sizeof(MyTreads[id].ExitStack);
	MyTreads[id].ExitContext.uc_link = &SchedulerContext;
	makecontext(&MyTreads[id].ExitContext, thread_exit, 0);


	getcontext(&MyTreads[id].Context);
	MyTreads[id].Context.uc_stack.ss_sp = MyTreads[id].Stack;
	MyTreads[id].Context.uc_stack.ss_size = sizeof(MyTreads[id].Stack);
	MyTreads[id].Context.uc_link = &MyTreads[id].ExitContext;
	makecontext(&MyTreads[id].Context, func(tnumber), 0);

	return thread_id;
}

void thread_exit(){
	MyTreads[CurrentContextId].ContextStatus = 0;
}

void thread_wait(int id){
	struct timespec nanotime;
	nanotime.tv_sec = 0;
	nanotime.tv_nsec = 10000*MyInterval;
	while (MyTreads[id].ContextStatus != 0) {
		nanosleep(&nanotime, 0);
	}
}

void thread_sleep(int counts){
	MyTreads[CurrentContextId].ContextStatus = 2;
	MyTreads[CurrentContextId].ContextSleepTime = counts;
	int TempContextId = CurrentContextId;
	CurrentContextId = 0;
	swapcontext(&MyTreads[TempContextId].Context, &SchedulerContext);
}

void my_thread(int qwe){
	int i;
	for (i=0; i<10; i++){
		printf("Thread %d...\n",qwe);
		thread_sleep(4+qwe);
	}
}

void schedul_function(int signal){
	int NextId = 0;
	int CurrentId = 0;
	while(CurrentId < NumberOfContexts){
		if (MyTreads[CurrentId].ContextStatus == 2){//Sleeping?
			MyTreads[CurrentId].ContextSleepTime -= 1;
			if (MyTreads[CurrentId].ContextSleepTime == 0){
				MyTreads[CurrentId].ContextStatus = 1;//Active!
			}
		}
		CurrentId++;
	}

	//Moving...
	CurrentId = 0;
	while(CurrentId < NumberOfContexts){
		if (MyTreads[CurrentId].ContextStatus == 1 && CurrentContextId != CurrentId){
			NextId = CurrentId;
			break;
		}
		CurrentId++;
	}
	
	if (NextId != 0){
		CurrentContextId = NextId;
		swapcontext(&SchedulerContext, &MyTreads[CurrentContextId].Context);
	}
}	

int main(){
	int i;
	for (i = 1; i < NumberOfContexts; i++){
		MyTreads[i].ContextStatus = 0;//Free Tread
	}
	struct itimerval AlarmInterval;
	
	AlarmInterval.it_interval.tv_sec = 0;
	AlarmInterval.it_interval.tv_usec = MyInterval*1000;
	AlarmInterval.it_value.tv_sec = 0;
	AlarmInterval.it_value.tv_usec = MyInterval*1000;
	setitimer(ITIMER_REAL, &AlarmInterval, 0);
	
	signal(SIGALRM, schedul_function); 
	
	for(i=0; i<10; i++){
		int TreadId[i] = thread_create(my_thread, i);
		printf("Thread %d created\n", i);
	}
	
	for(i=0; i<10; i++){
		thread_wait(TreadId[i]);
		printf("Thread %d stoped\n", TreadId[i]);
	}
	
	return 0;
}