# 0. Limpiar memoria
rm(list = ls())

library(dplyr)

# Cargar dataset (ruta relativa a la carpeta del proyecto)
df <- read.csv("data/raw/pacientes.csv", header = TRUE, stringsAsFactors = FALSE, fileEncoding = "UTF-8")
df <- as.data.frame(df)

cat("\n--- 1. DIAGNÓSTICO INICIAL ---\n")
cat("Filas iniciales:", nrow(df), " | Columnas:", ncol(df), "\n")
print(names(df))

# 1. Tratamiento de duplicados
df_limpio <- df %>%
  distinct() %>%
  distinct(id_paciente, .keep_all = TRUE)

cat("Filas tras eliminar duplicados:", nrow(df_limpio), "\n")

# 2. Limpieza y transformación con dplyr
df_modif <- df_limpio %>%
  mutate(
    id_paciente = as.character(id_paciente),
    edad = as.numeric(edad),
    costo_atencion = as.numeric(gsub(",", ".", as.character(costo_atencion))),
    dias_hospitalizacion = as.numeric(dias_hospitalizacion),
    
    # Normalizar comuna (minúsculas, sin espacios y unificando tildes)
    comuna = tolower(trimws(as.character(comuna))),
    comuna = iconv(comuna, from = "UTF-8", to = "ASCII//TRANSLIT"),
    comuna = as.factor(comuna),
    
    # Limpiar diagnostico_principal
    diagnostico_principal = trimws(tolower(as.character(diagnostico_principal))),
    diagnostico_principal = ifelse(diagnostico_principal == "neumonia", "neumonía", diagnostico_principal),
    diagnostico_principal = as.factor(na_if(diagnostico_principal, "")),
    
    # Validar y convertir fecha_ultima_atencion
    fecha_ultima_atencion = as.Date(fecha_ultima_atencion, format = "%Y-%m-%d"),
    # Fechas futuras no son válidas: se marcan como NA
    fecha_ultima_atencion = if_else(fecha_ultima_atencion > Sys.Date(), as.Date(NA), fecha_ultima_atencion)
  ) %>%
  # validación: edad lógica, costos no negativos y comuna no vacía
  filter(
    !is.na(edad) & edad >= 0 & edad <= 120,
    !is.na(costo_atencion) & costo_atencion >= 0,
    !is.na(comuna) & comuna != ""
  )

cat("Filas finales tras filtros de limpieza:", nrow(df_modif), "\n")

# 3. Generar el resumen final de decisiones
resumen_decisiones <- df_modif %>%
  mutate(
    grupo_etario = case_when(
      edad < 18 ~ "Menor de edad",
      edad < 65 ~ "Adulto",
      TRUE ~ "Adulto mayor"
    )
  ) %>%
  group_by(comuna, grupo_etario) %>%
  summarise(
    total_pacientes = n(),
    promedio_hospitalizacion = mean(dias_hospitalizacion, na.rm = TRUE),
    mediana_hospitalizacion = median(dias_hospitalizacion, na.rm = TRUE),
    desv_est_hospitalizacion = sd(dias_hospitalizacion, na.rm = TRUE),
    costo_promedio = mean(costo_atencion, na.rm = TRUE),
    min_hospitalizacion = min(dias_hospitalizacion, na.rm = TRUE),
    max_hospitalizacion = max(dias_hospitalizacion, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(comuna, grupo_etario)


cat("\n--- TABLA RESULTANTE --- \n")
print(resumen_decisiones)


write.csv2(df_modif, "pacientes_limpio.csv", row.names = FALSE)
cat("\n¡Archivo 'pacientes_limpio.csv' exportado con éxito!\n")
