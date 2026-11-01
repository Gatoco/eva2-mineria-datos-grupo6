# Evaluación Sumativa 2 — Limpieza de datos en R

**Minería de Datos (TI3061) · INACAP Sede Talca · Grupo 6**
Caso: gestión de pacientes de un Servicio de Salud regional (Maule).

Proceso completo de diagnóstico, limpieza, transformación y validación de un dataset de atenciones de salud, usando **R** y **dplyr**, con trazabilidad de cada decisión.

> **Entrega:** martes 3 de noviembre de 2026, 23:00 (el AAI bloquea el envío a esa hora).

## Equipo y responsabilidades

| Integrante | Parte | Script | Carga |
|---|---|---|---|
| Benjamín Vidal | Carga y diagnóstico inicial | `scripts/01_diagnostico.R` | 20 % |
| Amanda Cáceres | Limpieza de datos | `scripts/02_limpieza.R` | 25 % |
| Abraham Grundt | Pipeline dplyr, estadística y normalización | `scripts/03_transformacion.R` | 25 % |
| Benjamín Cifuentes | Validación, riesgos, conclusión e informe | `scripts/04_validacion.R` | 30 % |

## Dataset

`data/raw/pacientes.csv` — 1.100 registros anonimizados, separados por **coma**. Es el archivo original entregado por el docente y **no se modifica**.

| Variable | Descripción |
|---|---|
| `id_paciente` | Identificador anonimizado |
| `edad` | Edad en años |
| `comuna` | Comuna de residencia |
| `diagnostico_principal` | Categoría diagnóstica |
| `cantidad_consultas` | Número de consultas |
| `dias_hospitalizacion` | Días de hospitalización |
| `fecha_ultima_atencion` | Fecha de última atención |
| `costo_atencion` | Costo estimado en pesos |

El archivo contiene problemas de calidad deliberados que forman parte del ejercicio. No incluye nombres, RUT, direcciones ni teléfonos.

## Flujo de trabajo

Cada integrante trabaja en su propio script, así que no hay conflictos entre partes. El dataset pasa de mano en mano así:

```
data/raw/pacientes.csv
   ├─ Vidal    → diagnóstico (no modifica datos)
   └─ Amanda   → data/processed/pacientes_limpio.csv
                    └─ Abraham → data/processed/pacientes_transformado.csv
                                    └─ Cifuentes → data/processed/pacientes_final.csv  ← se entrega
```

### Hoja de ruta

| # | Quién | Hito | Plazo (lunes 2-nov) |
|---|---|---|---|
| 1 | Cifuentes | Repositorio, dataset y README | listo |
| 2 | Vidal | `01_diagnostico.R`, capturas y tabla de hallazgos | 11:00 |
| 3 | Amanda | `02_limpieza.R` y `pacientes_limpio.csv` | 15:00 |
| 4 | Abraham | `03_transformacion.R` y `pacientes_transformado.csv` | 20:00 |
| 5 | Cifuentes | Validación, `pacientes_final.csv`, script unificado e informe | lunes noche |
| 6 | Todos | Revisión cruzada y subida al AAI | martes, antes de las 21:00 |

## Estructura del repositorio

Estado final esperado:

```
.
├── README.md
├── data/
│   ├── raw/
│   │   └── pacientes.csv                  # original, solo lectura
│   └── processed/
│       ├── pacientes_limpio.csv           # Amanda
│       ├── pacientes_transformado.csv     # Abraham
│       └── pacientes_final.csv            # Cifuentes (entrega)
├── scripts/
│   ├── 01_diagnostico.R                   # Vidal
│   ├── 02_limpieza.R                      # Amanda
│   ├── 03_transformacion.R                # Abraham
│   ├── 04_validacion.R                    # Cifuentes
│   └── pipeline_completo.R                # script unificado (entrega)
├── evidencias/
│   ├── vidal/                             # capturas numeradas + texto
│   ├── amanda/
│   ├── abraham/
│   └── cifuentes/
└── informe/
    └── Informe_ES2_Grupo6.docx            # informe final (entrega)
```

**Se suben 3 archivos al AAI:** el informe, `pipeline_completo.R` y `pacientes_final.csv`.

## Cómo contribuir

1. Clonar el repositorio y trabajar **solo en los archivos de tu parte**.
2. Cada script debe empezar con `library(dplyr)` y leer su entrada con `read.csv()` (no `read.csv2`).
3. Comentar el código: **qué se hizo, por qué y qué resultó**.
4. Subir capturas numeradas a tu carpeta de `evidencias/` (`nombre_1.png`, `nombre_2.png`…) junto con un texto de 5 a 8 líneas explicando lo que hiciste.
5. Commits con formato convencional, por ejemplo: `feat: add data cleaning script`.
6. Si Git se complica, enviar los archivos al responsable del repositorio para que los incorpore con tu autoría.

## Reglas del trabajo

- Usar solo funciones vistas en clase o en la Lectura del material instruccional; todos deben poder explicar lo que hicieron.
- No incluir datos personales en capturas ni en el informe; solo `id_paciente`.
- Informe con la plantilla del curso, sin modificarla, con tablas y figuras numeradas y referencias en APA.

## Requisitos

- R ≥ 4.x y el paquete `dplyr` (`install.packages("dplyr")`).
- Ejecutar desde la raíz del repositorio para que las rutas relativas funcionen.
