# Grupo 6 - limpieza del dataset de pacientes (TI3061, EV2)
# integrantes: Benjamin Vidal, Amanda Caceres, Abraham Grundt, Benjamin Cifuentes
# antes de correr: Session > Set Working Directory > carpeta del proyecto
# necesita dplyr instalado una vez: install.packages("dplyr")


# ==================================================================
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

# ==================================================================
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

# ==================================================================
# 03 - transformacion y normalizacion (Abraham Grundt, ajustes de Benjamin Cifuentes)

library(dplyr)

datos <- read.csv("data/processed/pacientes_limpio.csv")

# estadistica basica del costo antes de normalizar
summary(datos$costo_atencion)
cat("sd costo:", round(sd(datos$costo_atencion)), "\n")

# atipicos con el rango intercuartilico (1.5 * IQR)
q1 <- quantile(datos$costo_atencion, 0.25)
q3 <- quantile(datos$costo_atencion, 0.75)
lim_inf <- q1 - 1.5 * IQR(datos$costo_atencion)
lim_sup <- q3 + 1.5 * IQR(datos$costo_atencion)
cat("atipicos en costo:", sum(datos$costo_atencion < lim_inf | datos$costo_atencion > lim_sup), "\n")

# pipeline: filtrar, crear variables, elegir columnas y ordenar
# se normaliza despues de revisar atipicos, si no los extremos deforman la escala
transformado <- datos %>%
  filter(edad >= 0 & edad <= 120) %>%
  mutate(
    grupo_etario = case_when(
      edad < 18 ~ "Menor de edad",
      edad < 65 ~ "Adulto",
      TRUE ~ "Adulto mayor"
    ),
    costo_std = as.numeric(scale(costo_atencion))
  ) %>%
  select(id_paciente, edad, grupo_etario, comuna, diagnostico_principal,
         cantidad_consultas, dias_hospitalizacion, fecha_ultima_atencion,
         costo_atencion, costo_std) %>%
  arrange(desc(dias_hospitalizacion))

table(transformado$grupo_etario)

# Revisar la variable normalizada
class(transformado$costo_std)
range(transformado$costo_std)
cat("media:", round(mean(transformado$costo_std), 2), "| sd:", round(sd(transformado$costo_std), 2), "\n")

# resumen por comuna y grupo etario, sirve para planificar camas y recursos
resumen <- transformado %>%
  group_by(comuna, grupo_etario) %>%
  summarise(
    total_pacientes = n(),
    promedio_hospitalizacion = round(mean(dias_hospitalizacion), 1),
    mediana_hospitalizacion = median(dias_hospitalizacion),
    costo_promedio = round(mean(costo_atencion)),
    .groups = "drop"
  ) %>%
  arrange(desc(total_pacientes))
print(resumen, n = 30)

write.csv(transformado, "data/processed/pacientes_transformado.csv", row.names = FALSE)
write.csv(resumen, "data/processed/resumen_comuna_grupo.csv", row.names = FALSE)

# ==================================================================
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
