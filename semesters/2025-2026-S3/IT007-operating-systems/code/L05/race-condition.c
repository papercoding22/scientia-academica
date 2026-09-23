// race-condition.c — minh hoạ race condition của bài toán Producer vs. Consumer (5.1.1)
//   Có race:  gcc -O0 -pthread race-condition.c -o race && ./race
//   Đã khoá:  gcc -O0 -pthread -DUSE_MUTEX race-condition.c -o race && ./race
#include <pthread.h>
#include <stdio.h>

#define N 1000000
int count = 5;                                     // dữ liệu chia sẻ
pthread_mutex_t lock = PTHREAD_MUTEX_INITIALIZER;  // toàn cục: mọi thread cùng thấy

void *producer(void *arg) {
    for (int i = 0; i < N; i++) {
#ifdef USE_MUTEX
        pthread_mutex_lock(&lock);    // acquire() — entry section
#endif
        count++;                      // critical section: load → inc → store
#ifdef USE_MUTEX
        pthread_mutex_unlock(&lock);  // release() — exit section
#endif
    }
    return NULL;
}

void *consumer(void *arg) {
    for (int i = 0; i < N; i++) {
#ifdef USE_MUTEX
        pthread_mutex_lock(&lock);
#endif
        count--;
#ifdef USE_MUTEX
        pthread_mutex_unlock(&lock);
#endif
    }
    return NULL;
}

int main(void) {
    pthread_t p, c;
    pthread_create(&p, NULL, producer, NULL);
    pthread_create(&c, NULL, consumer, NULL);
    pthread_join(p, NULL);
    pthread_join(c, NULL);
    printf("count = %d (kỳ vọng 5)\n", count);
    return 0;
}
