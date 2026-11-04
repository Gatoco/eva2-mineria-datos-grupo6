# EV2 mineria de datos - grupo 6
# Benjamin Vidal, Amanda Caceres, Abraham Grundt, Benjamin Cifuentes
# ojo: antes de correr poner la carpeta del proyecto como working directory (Session > Set Working Directory)
# hay que tener dplyr instalado: install.packages("dplyr")


# ==================================================================
# diagnostico - Benjamin Vidal
# aqui solo revisamos los datos, no se modifica nada

# leer el csv
datos <- read.csv("data/raw/pacientes.csv")

# Tamaño y tipos de cada columna
cat("filas:", nrow(datos), "| columnas:", ncol(datos), "\n")
str(datos)
class(datos$edad)            # sale character, deberia ser numero
class(datos$costo_atencion)  # igual
head(datos)
summary(datos)

# edad y costo vienen con " años" y " CLP", los paso a numero solo para mirarlos
edad_num <- as.numeric(gsub(" años", "", datos$edad))
costo_num <- as.numeric(gsub(" CLP", "", datos$costo_atencion))

# Media, mediana etc
cat("edad -> media:", round(mean(edad_num, na.rm = TRUE), 1),
    "| mediana:", median(edad_num, na.rm = TRUE),
    "| min:", min(edad_num, na.rm = TRUE), "| max:", max(edad_num, na.rm = TRUE), "\n")
cat("costo -> media:", round(mean(costo_num, na.rm = TRUE)),
    "| mediana:", median(costo_num, na.rm = TRUE),
    "| sd:", round(sd(costo_num, na.rm = TRUE)), "\n")
quantile(datos$dias_hospitalizacion, na.rm = TRUE)

# conteo por comuna y diagnostico, ojo que hay nombres escritos distinto
table(datos$comuna)
table(datos$diagnostico_principal)

# NA y celdas vacias
colSums(is.na(datos))
colSums(datos == "", na.rm = TRUE)

# Duplicados
dup_exactos <- sum(duplicated(datos))
dup_id <- sum(duplicated(datos$id_paciente))
cat("duplicados exactos:", dup_exactos, "| id repetidos:", dup_id, "\n")

# cuantos tienen años o CLP pegado
con_texto <- sum(datos$edad != gsub(" años", "", datos$edad)) +
  sum(datos$costo_atencion != gsub(" CLP", "", datos$costo_atencion))

# edades raras y costos negativos
edad_mala <- sum(edad_num < 0 | edad_num > 120, na.rm = TRUE)
costo_neg <- sum(costo_num < 0, na.rm = TRUE)
cat("edades fuera de 0-120:", edad_mala, "| costos negativos:", costo_neg, "\n")

# Fechas, vienen en 2 formatos (2024-02-25 y 25/02/2024)
f1 <- as.Date(datos$fecha_ultima_atencion, format = "%Y-%m-%d")
f2 <- as.Date(datos$fecha_ultima_atencion, format = "%d/%m/%Y")
fecha_otro_formato <- sum(!is.na(f2))
fecha_mala <- sum(datos$fecha_ultima_atencion != "" & is.na(f1) & is.na(f2))
fecha_futura <- sum(f1 > Sys.Date() | f2 > Sys.Date(), na.rm = TRUE)
cat("fechas dd/mm/aaaa:", fecha_otro_formato, "| invalidas:", fecha_mala,
    "| futuras:", fecha_futura, "\n")

# comunas distintas antes y despues de sacar espacios/mayusculas
cat("comunas como vienen:", length(unique(datos$comuna)),
    "| sin espacios ni mayusculas:", length(unique(tolower(trimws(datos$comuna)))), "\n")

# Tabla con todo lo que encontramos
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
# limpieza - Amanda Caceres

datos <- read.csv("data/raw/pacientes.csv")
filas_inicio <- nrow(datos)

# quitar duplicados, primero filas iguales y despues id repetido
datos <- datos[!duplicated(datos), ]
cat("sin duplicados exactos:", nrow(datos), "filas\n")
datos <- datos[!duplicated(datos$id_paciente), ]
cat("sin id repetidos:", nrow(datos), "filas\n")

# sacamos " años" y " CLP" para poder pasar a numero
vacios_edad <- sum(datos$edad == "")
datos$edad <- as.numeric(gsub(" años", "", datos$edad))
datos$costo_atencion <- as.numeric(gsub(" CLP", "", datos$costo_atencion))
# Revisar que no salgan NA de mas al convertir (deberian ser los mismos vacios)
cat("NA en edad:", sum(is.na(datos$edad)), "| vacios que tenia:", vacios_edad, "\n")

# arreglar comuna y diagnostico (espacios, mayusculas, tildes)
datos$comuna <- tolower(trimws(datos$comuna))
datos$comuna <- gsub("ó", "o", datos$comuna)
datos$diagnostico_principal <- tolower(trimws(datos$diagnostico_principal))
datos$diagnostico_principal <- gsub("ó", "o", datos$diagnostico_principal)
datos$diagnostico_principal <- gsub("í", "i", datos$diagnostico_principal)
# Lo que viene vacio queda como sin dato, no lo podemos inventar
datos$comuna[datos$comuna == ""] <- "sin dato"
datos$diagnostico_principal[datos$diagnostico_principal == ""] <- "sin dato"
datos$comuna <- as.factor(datos$comuna)
datos$diagnostico_principal <- as.factor(datos$diagnostico_principal)
levels(datos$comuna)
levels(datos$diagnostico_principal)

# fechas en los 2 formatos, despues se juntan
f1 <- as.Date(datos$fecha_ultima_atencion, format = "%Y-%m-%d")
f2 <- as.Date(datos$fecha_ultima_atencion, format = "%d/%m/%Y")
f1[is.na(f1)] <- f2[is.na(f1)]
datos$fecha_ultima_atencion <- f1
# si la fecha es futura esta mala, se deja NA
datos$fecha_ultima_atencion[datos$fecha_ultima_atencion > Sys.Date()] <- NA
cat("fechas NA (vacias, invalidas o futuras):", sum(is.na(datos$fecha_ultima_atencion)), "\n")

# edades imposibles y costos negativos pasan a NA
cat("edades fuera de rango:", sum(datos$edad < 0 | datos$edad > 120, na.rm = TRUE),
    "| costos negativos:", sum(datos$costo_atencion < 0, na.rm = TRUE), "\n")
datos$edad[datos$edad < 0 | datos$edad > 120] <- NA
datos$costo_atencion[datos$costo_atencion < 0] <- NA

# que hacemos con los NA
# edad -> se borra la fila porque sin edad no hay grupo etario
# costo y dias -> mediana, porque no le afectan los valores extremos
# Fecha -> se deja NA, no tiene sentido inventarla
sin_edad <- sum(is.na(datos$edad))
cat("filas sin edad:", sin_edad, "(", round(sin_edad / nrow(datos) * 100, 1), "% )\n")
datos <- datos[!is.na(datos$edad), ]
cat("costos NA imputados:", sum(is.na(datos$costo_atencion)),
    "| dias NA imputados:", sum(is.na(datos$dias_hospitalizacion)), "\n")
datos$costo_atencion[is.na(datos$costo_atencion)] <- median(datos$costo_atencion, na.rm = TRUE)
datos$dias_hospitalizacion[is.na(datos$dias_hospitalizacion)] <- median(datos$dias_hospitalizacion, na.rm = TRUE)

# como quedo
cat("filas:", filas_inicio, "->", nrow(datos), "\n")
colSums(is.na(datos))
write.csv(datos, "data/processed/pacientes_limpio.csv", row.names = FALSE)

# ==================================================================
# transformacion y normalizacion - Abraham Grundt

library(dplyr)

datos <- read.csv("data/processed/pacientes_limpio.csv")

# como esta el costo antes de normalizar
summary(datos$costo_atencion)
cat("sd costo:", round(sd(datos$costo_atencion)), "\n")

# Atipicos con IQR (1.5 * IQR)
q1 <- quantile(datos$costo_atencion, 0.25)
q3 <- quantile(datos$costo_atencion, 0.75)
lim_inf <- q1 - 1.5 * IQR(datos$costo_atencion)
lim_sup <- q3 + 1.5 * IQR(datos$costo_atencion)
cat("atipicos en costo:", sum(datos$costo_atencion < lim_inf | datos$costo_atencion > lim_sup), "\n")

# Pipeline con dplyr
# normalizamos despues de ver los atipicos, sino los extremos desordenan todo
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

# revisar que costo_std quedo bien
class(transformado$costo_std)
range(transformado$costo_std)
cat("media:", round(mean(transformado$costo_std), 2), "| sd:", round(sd(transformado$costo_std), 2), "\n")

# Resumen por comuna y grupo etario, para ver donde se necesitan mas camas
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
# validacion final - Benjamin Cifuentes

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
