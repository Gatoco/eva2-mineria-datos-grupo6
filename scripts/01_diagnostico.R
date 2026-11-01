# ============================================================
# 01_diagnostico.R  |  Responsable: Benjamín Vidal
# Etapa 1: carga y diagnóstico inicial
# Entrada : data/raw/pacientes.csv (NO se modifica)
# Salida  : solo diagnóstico (capturas + tabla de hallazgos en evidencias/vidal/)
# ============================================================

library(dplyr)

datos <- read.csv("data/raw/pacientes.csv")  # separado por coma

# TODO: dim/nrow/ncol, str/class/summary/head, estadísticas descriptivas,
#       NA y vacíos por columna, duplicados (fila completa y por id_paciente),
#       valores imposibles, fechas inválidas, textos inconsistentes.
