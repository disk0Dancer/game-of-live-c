#include <stdio.h>
#include <stdint.h>

static FILE *ftrace = NULL;
static FILE *frelations = NULL;
static int instructions_count = 0;
static int relations_count = 0;

__attribute__((constructor))
void init() {
    ftrace = fopen("trace.txt", "w");
    frelations = fopen("relations.txt", "w");
}

__attribute__((destructor))
void cleanup() {
    if (ftrace) fclose(ftrace);
    if (frelations) fclose(frelations);
    printf("done: %d instructions, %d relations\n", instructions_count, relations_count);
}

void logExecution(const char *name, uint64_t addr) {
    instructions_count++;
    if (ftrace) {
        fprintf(ftrace, "%s\n", name);
    }
}

void logRelation(uint64_t user_addr, uint64_t operand_addr,
                const char *user_name, const char *operand_name) {
    relations_count++;
    if (frelations) {
        fprintf(frelations, "%s <- %s\n", user_name, operand_name);
    }
}

