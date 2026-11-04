# 04 - validacion final (Benjamin Cifuentes)

original <- read.csv("data/raw/pacientes.csv")
final <- read.csv("data/processed/pacientes_transformado.csv")
final$fecha_ultima_atencion <- as.Date(final$fecha_ultima_atencion)

# comparacion antes y despues
comparacion <- data.frame(
  medida = c("filas", "columnas", "NA", "vacios", "duplicados exactos", "id repetidos"),
  antes = c(nrow(original), ncol(original), sum(is.na(original)), sum(original == "", na.rm = TRUE),
            sum(duplicated(original)), sum(duplicated(original$id_paciente))),
  despues = c(nrow(final), ncol(final), sum(is.na(final)), sum(final == "", na.rm = TRUE),
              sum(duplicated(final)), sum(duplicated(final$id_paciente)))
)
comparacion

# tipos antes y despues
class(original$edad); class(final$edad)
class(original$costo_atencion); class(final$costo_atencion)
class(original$fecha_ultima_atencion); class(final$fecha_ultima_atencion)

# reglas de validez, todas deberian dar 0
cat("edad fuera de 0-120:", sum(final$edad < 0 | final$edad > 120), "\n")
cat("fechas futuras:", sum(final$fecha_ultima_atencion > Sys.Date(), na.rm = TRUE), "\n")
cat("costos negativos:", sum(final$costo_atencion < 0), "\n")
cat("dias negativos:", sum(final$dias_hospitalizacion < 0), "\n")

# categorias esperadas
table(final$grupo_etario)
table(final$comuna)
table(final$diagnostico_principal)

# NA que quedan: solo deberian estar en la fecha (se dejaron a proposito)
colSums(is.na(final))

# Filas perdidas: 100 duplicados exactos + las que no tenian edad valida
cat("filas perdidas:", nrow(original) - nrow(final), "\n")

# exportar el dataset final
write.csv(final, "data/processed/pacientes_final.csv", row.names = FALSE)
cat("archivo generado: data/processed/pacientes_final.csv\n")
