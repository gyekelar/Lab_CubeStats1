/*
 CMPUT 229: Cube Statistics Laboratory
 Author: Jose Nelson Amaral
 Date: December 2009

 Main program to read base array into memory,
 then read several cube specifications 
 and print statistics in each cube.
  */

#include <stdio.h>
#include <stdlib.h>

int total;
int max;
int min;

int power(int base, int exponent)
{
  int r = 1;
  int t;
  for(t = exponent ; t>0 ; t--)
    r = r*base;
  return r;
}

int main(int argc, char **argv)
{
	int dimension;
	int size;
	int numelems;
	
	int *A;
	int *cursor, d;
	
	int cubed;
	
	int *first;
	int edge;
	int range;
	int average;
	
	int *lastelem;
	
	scanf("%d %d", &dimension, &size);
	numelems = power(size,dimension);
	A = (int *)malloc(numelems*sizeof(int));
	lastelem = &(A[numelems]);
        /* Read in all the elements of the array */
	for(cursor=A ; cursor<lastelem ; cursor++) {
		scanf("%d",cursor);
	}
	
	while(1) {
		first = A;
		for(d=0 ; d<dimension ; d++) {
			scanf("%d",&cubed);
			if(cubed < 0)
				exit(0);
	 		first = first + cubed*power(size,dimension-d-1);
		}
		scanf("%d",&edge);
                max = min = *first;
                total = 0;
		CubeStats(first,edge,dimension,size,&range,&average);
       		printf("edge = %d; Range = %d; Average = %d\n",edge,range,average);
    }
}
