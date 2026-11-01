# ============================================================
# 04_validacion.R  |  Responsable: Benjamín Cifuentes
# Etapas 5 y 6: validación antes/después y exportación final
# Entrada : data/raw/pacientes.csv, data/processed/*.csv
# Salida  : data/processed/pacientes_final.csv
# ============================================================

library(dplyr)

# TODO: comparar dimensiones, NA, duplicados y tipos (antes vs. después),
#       reglas de validez, verificar que no se generaron NA nuevos,
#       exportar el CSV final y registrar su nombre.

# write.csv(datos_final, "data/processed/pacientes_final.csv", row.names = FALSE)
