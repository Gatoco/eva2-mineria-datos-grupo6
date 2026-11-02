# 0. Limpiar memoria
rm(list = ls())

library(dplyr)

# cambia la carpeta
df <- read.csv("pacientes (2).csv", header = TRUE, stringsAsFactors = FALSE, fileEncoding = "UTF-8")
df <- as.data.frame(df)


cat("\n--- COLUMNAS RECONOCIDAS ---\n")
print(names(df))

# . Limpieza y transformación con dplyr
df_modif <- df %>%
  mutate(
    id_paciente = as.character(id_paciente),
    edad = as.numeric(edad),
    costo_atencion = as.numeric(gsub(",", ".", as.character(costo_atencion))),
    dias_hospitalizacion = as.numeric(dias_hospitalizacion),
    comuna = as.factor(trimws(tolower(as.character(comuna))))
  ) %>%
  filter(!is.na(edad) & !is.na(comuna) & comuna != "") %>%
  filter(edad >= 0 & edad <= 120)

# Generar el resumen final de decisiones
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

# Mostrar la tabla final
cat("\n--- TABLA RESULTANTE --- \n")
print(resumen_decisiones)