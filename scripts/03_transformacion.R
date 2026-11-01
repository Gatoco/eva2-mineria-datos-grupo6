# ============================================================
# 03_transformacion.R  |  Responsable: Abraham Grundt
# Etapas 3 y 4: pipeline dplyr, estadística y normalización
# Entrada : data/processed/pacientes_limpio.csv
# Salida  : data/processed/pacientes_transformado.csv
# ============================================================

library(dplyr)

datos <- read.csv("data/processed/pacientes_limpio.csv")

# TODO: pipeline con %>% (filter, select, mutate, arrange, group_by, summarise),
#       grupo_etario con case_when, estadística básica, resumen por comuna y grupo,
#       normalización (scale() / Min-Max) con comprobación de tipo y rango.

# write.csv(datos_transformados, "data/processed/pacientes_transformado.csv", row.names = FALSE)
