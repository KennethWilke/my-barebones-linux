#include <stdio.h>
#include <unistd.h>

int main() {
	printf("Bare bones Linux!\n");

	while (1) {
		printf("I'm still alive!\n");
		sleep(1);
	}

	return 0;
}
