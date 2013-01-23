#include <stdio.h>
#include <pthread.h>

int locked_count = 0;
int simple_count = 0;
int thread_count = 100;
int mutex=0;
int new_val=1;
int old_val=0;

void* locked(void* argument){
    int ret_val;
	int i=0;
	while(i<10000){
		asm volatile("lock cmpxchgl %1, %2"
			:"=a"(ret_val)
			:"r"(new_val),"m"(mutex),"0"(old_val)
			: "memory" , "cc");

		if (!ret_val){
			locked_count++;
			i++;
			mutex=0;
		}
	}
}

void* simple(void* argument){
	int i=0;
	while(i<10000){
		simple_count++;
		i++;
	}
}

int main(){
    pthread_t thread[thread_count];
    
	for(int i=0; i<thread_count; i++){
		int create_error = pthread_create(&thread[i], NULL, locked, NULL);
		if(create_error){
			printf("Couldn't create %d thread", i);
			return 0;
		}
	}
	for(int i=0; i<thread_count; i++){
		int join_error = pthread_join(thread[i], NULL);
	}
	
	for(int i=0; i<thread_count; i++){
		int create_error = pthread_create(&thread[i], NULL, simple, NULL);
		if(create_error){
			printf("Couldn't create %d thread", i);
			return 0;
		}
	}
	for(int i=0; i<thread_count; i++){
		int join_error = pthread_join(thread[i], NULL);
	}
       
	printf("Must be 1000000\n");
	printf("Locked: %d\n",locked_count);
	printf("Simple: %d\n",simple_count);
	return 0;
}
