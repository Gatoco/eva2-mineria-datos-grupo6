# ============================================================
# 02_limpieza.R  |  Responsable: Amanda Cáceres
# Etapa 2: limpieza de datos
# Entrada : data/raw/pacientes.csv
# Salida  : data/processed/pacientes_limpio.csv
# ============================================================

library(dplyr)

datos <- read.csv("data/raw/pacientes.csv")

# TODO: NA y vacíos, duplicados, tipos (verificar NA por coerción),
#       texto (trimws, tolower/toupper, gsub), fechas y valores fuera de rango.
# Documentar cada decisión: qué se hizo, por qué y cuántos registros afectó.

# write.csv(datos_limpios, "data/processed/pacientes_limpio.csv", row.names = FALSE)
