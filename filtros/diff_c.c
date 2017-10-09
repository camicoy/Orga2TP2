
#include <stdlib.h>
#include <math.h>
#include "../tp2.h"

void  resta(bgra_t* prim,bgra_t* seg,bgra_t* dest){
	
	if(prim -> b > seg -> b){
		dest -> b = (prim -> b) - (seg -> b);
	}
	else{
		dest -> b = (seg -> b) - (prim -> b);
	}
	
	if(prim -> g > seg -> g){
		dest -> g = (prim -> g) - (seg -> g);
	}
	else{
		dest -> g = (seg -> g) - (prim -> g);
	}
	
	if(prim -> r > seg -> r){
		dest -> r = (prim -> r) - (seg -> r);
	}
	else{
		dest -> r = (seg -> r) - (prim -> r);
	}
	
	dest -> b = fmax(dest -> b,fmax( dest -> g,dest -> r));
	dest -> g = dest -> b;
	dest -> r = dest -> g;
	dest -> a = 255;
	
}

void diff_c (
	unsigned char *src,
	unsigned char *src_2,
	unsigned char *dst,
	int m,//columnas
	int n,//filas
	int src_row_size,
	int src_2_row_size,
	int dst_row_size
) {
	unsigned char (*src_matrix)[src_row_size] = (unsigned char (*)[src_row_size]) src;
	unsigned char (*src_2_matrix)[src_2_row_size] = (unsigned char (*)[src_2_row_size]) src_2;
	unsigned char (*dst_matrix)[dst_row_size] = (unsigned char (*)[dst_row_size]) dst;
	
	for(int i = 0; i < n; i++) {
		for(int j = 0; j < m*4; j+=4) {
			
			resta((bgra_t*) & src_matrix[i][j],(bgra_t*) & src_2_matrix[i][j],(bgra_t*) & dst_matrix[i][j]);
			
		}
	}
	
}




