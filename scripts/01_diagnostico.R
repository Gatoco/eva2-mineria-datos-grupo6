# 01 - diagnostico inicial (Benjamin Vidal)
# aca solo se mira el dataset, no se cambia nada

# cargar el archivo original
datos <- read.csv("data/raw/pacientes.csv")

# dimensiones, estructura y tipos
cat("filas:", nrow(datos), "| columnas:", ncol(datos), "\n")
str(datos)
class(datos$edad)            # viene como texto, deberia ser numero
class(datos$costo_atencion)  # tambien texto
head(datos)
summary(datos)

# edad y costo traen " años" y " CLP", se pasan a numero solo para revisarlos
edad_num <- as.numeric(gsub(" años", "", datos$edad))
costo_num <- as.numeric(gsub(" CLP", "", datos$costo_atencion))

# estadisticas de las numericas
cat("edad -> media:", round(mean(edad_num, na.rm = TRUE), 1),
    "| mediana:", median(edad_num, na.rm = TRUE),
    "| min:", min(edad_num, na.rm = TRUE), "| max:", max(edad_num, na.rm = TRUE), "\n")
cat("costo -> media:", round(mean(costo_num, na.rm = TRUE)),
    "| mediana:", median(costo_num, na.rm = TRUE),
    "| sd:", round(sd(costo_num, na.rm = TRUE)), "\n")
quantile(datos$dias_hospitalizacion, na.rm = TRUE)

# frecuencias de las categoricas, aca se ven las escrituras distintas
table(datos$comuna)
table(datos$diagnostico_principal)

# NA y vacios por columna
colSums(is.na(datos))
colSums(datos == "", na.rm = TRUE)

# Duplicados exactos y por id_paciente
dup_exactos <- sum(duplicated(datos))
dup_id <- sum(duplicated(datos$id_paciente))
cat("duplicados exactos:", dup_exactos, "| id repetidos:", dup_id, "\n")

# cuantos traen texto pegado al numero
con_texto <- sum(datos$edad != gsub(" años", "", datos$edad)) +
  sum(datos$costo_atencion != gsub(" CLP", "", datos$costo_atencion))

# valores imposibles
edad_mala <- sum(edad_num < 0 | edad_num > 120, na.rm = TRUE)
costo_neg <- sum(costo_num < 0, na.rm = TRUE)
cat("edades fuera de 0-120:", edad_mala, "| costos negativos:", costo_neg, "\n")

# fechas: hay dos formatos (2024-02-25 y 25/02/2024)
f1 <- as.Date(datos$fecha_ultima_atencion, format = "%Y-%m-%d")
f2 <- as.Date(datos$fecha_ultima_atencion, format = "%d/%m/%Y")
fecha_otro_formato <- sum(!is.na(f2))
fecha_mala <- sum(datos$fecha_ultima_atencion != "" & is.na(f1) & is.na(f2))
fecha_futura <- sum(f1 > Sys.Date() | f2 > Sys.Date(), na.rm = TRUE)
cat("fechas dd/mm/aaaa:", fecha_otro_formato, "| invalidas:", fecha_mala,
    "| futuras:", fecha_futura, "\n")

# textos: cuantas comunas quedan si se quitan espacios y mayusculas
cat("comunas como vienen:", length(unique(datos$comuna)),
    "| sin espacios ni mayusculas:", length(unique(tolower(trimws(datos$comuna)))), "\n")

# Tabla de hallazgos
hallazgos <- data.frame(
  problema = c("duplicados exactos", "id repetido", "edad fuera de rango", "costo negativo",
               "edad y costo como texto", "fechas en dos formatos", "fechas invalidas",
               "fechas futuras", "texto inconsistente", "valores vacios"),
  variable = c("fila completa", "id_paciente", "edad", "costo_atencion",
               "edad, costo_atencion", "fecha_ultima_atencion", "fecha_ultima_atencion",
               "fecha_ultima_atencion", "comuna, diagnostico_principal", "varias"),
  evidencia = c(dup_exactos, dup_id, edad_mala, costo_neg,
                con_texto,
                fecha_otro_formato, fecha_mala, fecha_futura,
                length(unique(datos$comuna)), sum(datos == "", na.rm = TRUE)),
  riesgo = c("contar dos veces", "sobrecontar pacientes", "promedios falsos", "costos falsos",
             "no se puede calcular", "fechas mal leidas", "fechas perdidas",
             "reportes falsos", "categorias partidas", "menos datos"),
  accion = c("eliminar", "dejar uno por id", "pasar a NA y revisar", "pasar a NA e imputar",
             "quitar texto y convertir", "convertir ambos formatos", "dejar NA",
             "dejar NA", "trimws, tolower y tildes", "tratar segun variable")
)
hallazgos
