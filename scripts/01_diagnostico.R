# Instalación de paquetes necesarios
install.packages("dplyr")

library(dplyr)


#Cargar o leer CSV
DatosPacientes <- read.csv(file.choose())

str(DatosPacientes)

summary(DatosPacientes)

colSums(is.na(DatosPacientes))

sum(duplicated(DatosPacientes))

DP_Limpios <- DatosPacientes %>%
  
  filter.(is.na(edad)) %>%
  mutate(grupo_etario = case_when(
    edad < 18 ~ "Menor de edad",
    edad < 65 ~ "Adulto",
    TRUE ~ "Adulto mayor"
  ),
  costo_std = as.numeric(scale(costo_atencion))
  ) %>%
  arrange(desc(dias_hospitalizacion))
  