// bounded-buffer.c — bounded-buffer với 3 semaphore (empty, full, mutex)
// gcc -pthread bounded-buffer.c -o bbuf && ./bbuf
// Semaphore tự cài bằng mutex + condition variable: đúng ý "không busy waiting"
// của 5.7.3 — thread chờ thì ngủ, signal thì đánh thức. Trên Linux có thể thay
// bằng <semaphore.h>: sem_init / sem_wait / sem_post (macOS không hỗ trợ sem_init).
#include <pthread.h>
#include <stdio.h>

typedef struct { int value; pthread_mutex_t m; pthread_cond_t q; } semaphore;

void sem_setup(semaphore *s, int v) {
    s->value = v;
    pthread_mutex_init(&s->m, NULL);
    pthread_cond_init(&s->q, NULL);
}
void wait_(semaphore *s) {                // P(): xin một đơn vị tài nguyên
    pthread_mutex_lock(&s->m);
    while (s->value <= 0) pthread_cond_wait(&s->q, &s->m);  // ngủ, không quay vòng
    s->value--;
    pthread_mutex_unlock(&s->m);
}
void signal_(semaphore *s) {              // V(): trả một đơn vị tài nguyên
    pthread_mutex_lock(&s->m);
    s->value++;
    pthread_cond_signal(&s->q);           // wakeup một thread đang chờ (nếu có)
    pthread_mutex_unlock(&s->m);
}

#define BUFFER_SIZE 3
#define ITEMS 10
int buffer[BUFFER_SIZE], in = 0, out = 0, count = 0;
semaphore empty, full, mutex;

void *producer(void *arg) {
    for (int item = 1; item <= ITEMS; item++) {
        wait_(&empty);                    // còn chỗ trống không? hết thì ngủ
        wait_(&mutex);
        buffer[in] = item; in = (in + 1) % BUFFER_SIZE; count++;
        printf("produce %2d | count = %d\n", item, count);
        signal_(&mutex);
        signal_(&full);                   // báo có thêm một phần tử để lấy
    }
    return NULL;
}

void *consumer(void *arg) {
    for (int i = 0; i < ITEMS; i++) {
        wait_(&full);                     // có gì để lấy không? rỗng thì ngủ
        wait_(&mutex);
        int item = buffer[out]; out = (out + 1) % BUFFER_SIZE; count--;
        printf("consume %2d | count = %d\n", item, count);
        signal_(&mutex);
        signal_(&empty);                  // báo có thêm một chỗ trống
    }
    return NULL;
}

int main(void) {
    sem_setup(&empty, BUFFER_SIZE);       // ban đầu rỗng: n chỗ trống
    sem_setup(&full, 0);                  // chưa có gì để lấy
    sem_setup(&mutex, 1);                 // binary semaphore bảo vệ buffer + count
    pthread_t p, c;
    pthread_create(&p, NULL, producer, NULL);
    pthread_create(&c, NULL, consumer, NULL);
    pthread_join(p, NULL);
    pthread_join(c, NULL);
    printf("xong, count = %d\n", count);
    return 0;
}
