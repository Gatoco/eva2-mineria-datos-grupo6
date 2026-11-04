# 02 - limpieza (Amanda Caceres, ajustes de Benjamin Cifuentes)

datos <- read.csv("data/raw/pacientes.csv")
filas_inicio <- nrow(datos)

# duplicados: primero filas completas, despues el mismo id
datos <- datos[!duplicated(datos), ]
cat("sin duplicados exactos:", nrow(datos), "filas\n")
datos <- datos[!duplicated(datos$id_paciente), ]
cat("sin id repetidos:", nrow(datos), "filas\n")

# Tipos: se quita " años" y " CLP" antes de pasar a numero
vacios_edad <- sum(datos$edad == "")
datos$edad <- as.numeric(gsub(" años", "", datos$edad))
datos$costo_atencion <- as.numeric(gsub(" CLP", "", datos$costo_atencion))
# los NA de edad deben ser solo los que venian vacios, si no hubo error al convertir
cat("NA en edad:", sum(is.na(datos$edad)), "| vacios que tenia:", vacios_edad, "\n")

# textos: sin espacios, en minuscula y sin tildes
datos$comuna <- tolower(trimws(datos$comuna))
datos$comuna <- gsub("ó", "o", datos$comuna)
datos$diagnostico_principal <- tolower(trimws(datos$diagnostico_principal))
datos$diagnostico_principal <- gsub("ó", "o", datos$diagnostico_principal)
datos$diagnostico_principal <- gsub("í", "i", datos$diagnostico_principal)
# los vacios quedan como "sin dato", no se inventa la comuna ni el diagnostico
datos$comuna[datos$comuna == ""] <- "sin dato"
datos$diagnostico_principal[datos$diagnostico_principal == ""] <- "sin dato"
datos$comuna <- as.factor(datos$comuna)
datos$diagnostico_principal <- as.factor(datos$diagnostico_principal)
levels(datos$comuna)
levels(datos$diagnostico_principal)

# Fechas: se leen los dos formatos y se juntan
f1 <- as.Date(datos$fecha_ultima_atencion, format = "%Y-%m-%d")
f2 <- as.Date(datos$fecha_ultima_atencion, format = "%d/%m/%Y")
f1[is.na(f1)] <- f2[is.na(f1)]
datos$fecha_ultima_atencion <- f1
# una fecha futura es un error de digitacion, queda NA
datos$fecha_ultima_atencion[datos$fecha_ultima_atencion > Sys.Date()] <- NA
cat("fechas NA (vacias, invalidas o futuras):", sum(is.na(datos$fecha_ultima_atencion)), "\n")

# rangos: edad fuera de 0-120 y costos negativos son errores, pasan a NA
cat("edades fuera de rango:", sum(datos$edad < 0 | datos$edad > 120, na.rm = TRUE),
    "| costos negativos:", sum(datos$costo_atencion < 0, na.rm = TRUE), "\n")
datos$edad[datos$edad < 0 | datos$edad > 120] <- NA
datos$costo_atencion[datos$costo_atencion < 0] <- NA

# NA:
# - edad: se eliminan las filas, sin edad no hay grupo etario
# - costo y dias: se imputan con la mediana, que no la mueven los extremos
# - fecha: se conserva el NA, inventar una fecha seria peor
sin_edad <- sum(is.na(datos$edad))
cat("filas sin edad:", sin_edad, "(", round(sin_edad / nrow(datos) * 100, 1), "% )\n")
datos <- datos[!is.na(datos$edad), ]
cat("costos NA imputados:", sum(is.na(datos$costo_atencion)),
    "| dias NA imputados:", sum(is.na(datos$dias_hospitalizacion)), "\n")
datos$costo_atencion[is.na(datos$costo_atencion)] <- median(datos$costo_atencion, na.rm = TRUE)
datos$dias_hospitalizacion[is.na(datos$dias_hospitalizacion)] <- median(datos$dias_hospitalizacion, na.rm = TRUE)

# resultado
cat("filas:", filas_inicio, "->", nrow(datos), "\n")
colSums(is.na(datos))
write.csv(datos, "data/processed/pacientes_limpio.csv", row.names = FALSE)
