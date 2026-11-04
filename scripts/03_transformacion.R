# transformacion y normalizacion

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
