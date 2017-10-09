#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "../tp2.h"

extern float* matriz(float,int);

#define PI 3.14159265358979323846
#define E  2.71828182845904523536

int ik = 0;
int jk = 0;
float auxr =0;
float auxg =0;
float auxb =0;


float gauss(float sig, int x, int y){
	float cons = 1/(PI*2*sig*sig);
	float e = (x*x) + (y*y);
	e =e/(2*sig*sig);
	e = pow(E,-e);
	return cons*e;
}

float* matriz(float sigma, int rad) {
	float* ker = malloc (8*pow(2*rad+1,2));
	float (*k)[2*rad+1] = (float (*)[2*rad+1]) ker;
	for(int i = 0; i < 2*rad+1;i++){
		for(int j = 0; j < 2*rad+1;j++){
			float res = gauss(sigma,rad - i,rad - j);
			k[i][j] = res;
		}
	}
	return ker;
}


void blur_c    (
    unsigned char *src,
    unsigned char *dst,
    int cols,
    int filas,
    float sigma,
    int radius
    )
{
    unsigned char (*src_matrix)[cols*4] = (unsigned char (*)[cols*4]) src;
    unsigned char (*dst_matrix)[cols*4] = (unsigned char (*)[cols*4]) dst;
	

	float *k = matriz(sigma,radius);
	float (*ker)[2*radius+1] = (float (*)[2*radius+1]) k;
	for(int i = 0; i < filas;i++){
		for(int j = 0; j < cols*4;j+=4){
			
			if(i<radius || i > filas-radius|| j/4 < radius || j/4 > cols-radius){
				
				dst_matrix[i][j]=src_matrix [i][j];
				dst_matrix[i][j+1]=src_matrix [i][j+1];
				dst_matrix[i][j+2]=src_matrix [i][j+2];
				dst_matrix[i][j+3]=src_matrix [i][j+3];
				
			}
			else {
				auxr =0;
				auxg =0;
				auxb =0;
				dst_matrix[i][j+3] =src_matrix[i][j+3];
				ik = 0;
				jk = 0;
				for(int x = i-radius; x<= i+radius;x++){
					jk = 0;
					for(int l = j-radius*4; l<= j+radius*4;l+=4){
						auxr += src_matrix[x][l] * ker[ik][jk];
						auxg += src_matrix[x][l+1] * ker[ik][jk];
						auxb += src_matrix[x][l+2] * ker[ik][jk];
						
						jk++;
					}
					ik++;
				}
				dst_matrix[i][j]=(unsigned char) auxr;
				dst_matrix[i][j+1]=(unsigned char) auxg;
				dst_matrix[i][j+2]=(unsigned char) auxb;
			}
			
		}
	}
	free(k);
	
}
