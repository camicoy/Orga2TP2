
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "tp2.h"
#include "helper/tiempo.h"
#include "helper/libbmp.h"
#include "helper/utils.h"
#include "helper/imagenes.h"

#define N_ENTRADAS_diff 2
#define N_ENTRADAS_blur 1

DECLARAR_FILTRO(diff)
DECLARAR_FILTRO(blur)

filtro_t filtros[] = {
	DEFINIR_FILTRO(diff) ,
	DEFINIR_FILTRO(blur) ,
	{0,0,0,0,0}
};

int main( int argc, char** argv ) {

	configuracion_t config;

	procesar_opciones(argc, argv, &config);
	// Imprimo info
	if (!config.nombre)
	{
		printf ( "Procesando...\n");
		printf ( "  Filtro             : %s\n", config.nombre_filtro);
		printf ( "  Implementación     : %s\n", C_ASM( (&config) ) );
		printf ( "  Archivo de entrada : %s\n", config.archivo_entrada);
	}

	filtro_t *filtro = detectar_filtro(&config);

	if (filtro != NULL) {
		filtro->leer_params(&config, argc, argv);
		correr_filtro_imagen(&config, filtro->aplicador);
	}

	return 0;
}

filtro_t* detectar_filtro(configuracion_t *config)
{
	for (int i = 0; filtros[i].nombre != 0; i++)
	{
		if (strcmp(config->nombre_filtro, filtros[i].nombre) == 0)
			return &filtros[i];
	}

	fprintf(stderr, "Filtro desconocido\n");
	return NULL; // avoid C warning
}


void imprimir_tiempos_ejecucion(unsigned long long int start, unsigned long long int end, int cant_iteraciones, float prom, float std) {
	unsigned long long int cant_ciclos = end-start;

	printf("Tiempo de ejecución:\n");
	printf("  Comienzo                          : %llu\n", start);
	printf("  Fin                               : %llu\n", end);
	printf("  # iteraciones                     : %d\n", cant_iteraciones);
	printf("  # de ciclos insumidos totales     : %llu\n", cant_ciclos);
	printf("  # de ciclos insumidos por llamada : %.3f\n", (float)cant_ciclos/(float)cant_iteraciones);
	printf("  # de ciclos promedio              : %.3f\n", prom);
	printf("  Desviación estandar               : %.3f\n", std);
}

void correr_filtro_imagen(configuracion_t *config, aplicador_fn_t aplicador)
{
	snprintf(config->archivo_salida, sizeof  (config->archivo_salida), "%s/%s.%s.%s%s.bmp",
             config->carpeta_salida, basename(config->archivo_entrada),
             config->nombre_filtro,  C_ASM(config), config->extra_archivo_salida );

	if (config->nombre)
	{
		printf("%s\n", basename(config->archivo_salida));
	}
	else
	{
		imagenes_abrir(config);
		unsigned long long start, end, ini, fin, tiem;
		float todos[config->cant_iteraciones];
		float desStd[config->cant_iteraciones];
		float prom, std, total;

		MEDIR_TIEMPO_START(start)
		for (int i = 0; i < config->cant_iteraciones; i++) {
				MEDIR_TIEMPO_START(ini)
				aplicador(config);
				MEDIR_TIEMPO_START(fin)
				tiem = fin - ini;
				todos[i] = (float)tiem;
				desStd[i] = (float)tiem;
		}
		MEDIR_TIEMPO_STOP(end)
		prom = end - start;
		prom = prom/config->cant_iteraciones;
		std = 0;
		for(int j = 0; j < config->cant_iteraciones; j++){
			desStd[j] = desStd[j] - prom;
			desStd[j] = desStd[j] * desStd[j];
			std = std + desStd[j];
		}
		std = std/config->cant_iteraciones;
		std = sqrt(std);
		total = 0;
		for(int k = 0; k < config->cant_iteraciones; k++){
			if(todos[k] <= prom+std || todos[k] >= prom-std){
				total = total + todos[k];
			}
		}
		total = total/config->cant_iteraciones;
		imagenes_guardar(config);
		imagenes_liberar(config);
		imprimir_tiempos_ejecucion(start, end, config->cant_iteraciones, total, std);
	}
}
