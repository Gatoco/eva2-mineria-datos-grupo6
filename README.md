# EV2 Minería de Datos (TI3061) · Grupo 6

Limpieza, transformación y validación del dataset de pacientes en R.

**Integrantes:** Benjamín Vidal · Amanda Cáceres · Abraham Grundt · Benjamín Cifuentes
**Docente:** Oscar Rodríguez Mendoza · INACAP Talca

## Archivos

| Archivo | Qué es |
|---|---|
| `Grupo6_script_limpieza_pacientes.R` | script completo, de la carga a la exportación |
| `data/raw/pacientes.csv` | dataset original |
| `data/processed/pacientes_final.csv` | dataset final limpio y transformado |
| `scripts/01_diagnostico.R` … `04_validacion.R` | el mismo script separado por etapa |

## Cómo correrlo

1. Abrir RStudio y elegir *Session > Set Working Directory > Choose Directory…* con esta carpeta.
2. Instalar dplyr una vez: `install.packages("dplyr")`.
3. Abrir `Grupo6_script_limpieza_pacientes.R` y ejecutar todo.

Resultado: 1100 filas originales → 912 filas finales (100 duplicadas y 88 sin edad válida).
