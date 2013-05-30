#include <stdlib.h>
#include <stdio.h>

int main (int argc, char **argv) {
	int b = atoi(argv[1]);
	
	char num[10];
	char *aux;
	sprintf(num, "%x", b);
	//if( b >= 0)
		aux = num;
	//else
	//	aux = num + 4;
	printf("%s",aux);
}
