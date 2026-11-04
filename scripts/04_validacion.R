# validacion final

original <- read.csv("data/raw/pacientes.csv")
final <- read.csv("data/processed/pacientes_transformado.csv")
final$fecha_ultima_atencion <- as.Date(final$fecha_ultima_atencion)

# antes vs despues
comparacion <- data.frame(
  medida = c("filas", "columnas", "NA", "vacios", "duplicados exactos", "id repetidos"),
  antes = c(nrow(original), ncol(original), sum(is.na(original)), sum(original == "", na.rm = TRUE),
            sum(duplicated(original)), sum(duplicated(original$id_paciente))),
  despues = c(nrow(final), ncol(final), sum(is.na(final)), sum(final == "", na.rm = TRUE),
              sum(duplicated(final)), sum(duplicated(final$id_paciente)))
)
comparacion

# Tipos de datos antes y despues
class(original$edad); class(final$edad)
class(original$costo_atencion); class(final$costo_atencion)
class(original$fecha_ultima_atencion); class(final$fecha_ultima_atencion)

# Reglas, todo deberia dar 0
cat("edad fuera de 0-120:", sum(final$edad < 0 | final$edad > 120), "\n")
cat("fechas futuras:", sum(final$fecha_ultima_atencion > Sys.Date(), na.rm = TRUE), "\n")
cat("costos negativos:", sum(final$costo_atencion < 0), "\n")
cat("dias negativos:", sum(final$dias_hospitalizacion < 0), "\n")

# ver que esten solo las categorias que corresponden
table(final$grupo_etario)
table(final$comuna)
table(final$diagnostico_principal)

# los unicos NA deberian ser de fecha (eso lo dejamos asi)
colSums(is.na(final))

# filas perdidas = 100 duplicados + las sin edad valida
cat("filas perdidas:", nrow(original) - nrow(final), "\n")

# Guardar el archivo final
write.csv(final, "data/processed/pacientes_final.csv", row.names = FALSE)
cat("archivo generado: data/processed/pacientes_final.csv\n")
