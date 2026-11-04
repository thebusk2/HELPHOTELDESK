# 📊 Módulo de Reportes y Estadísticas para el Departamento de TI

El sistema **GLPI** cuenta con un potente motor nativo de **Reportes, Estadísticas y Cuadros de Mando (Dashboards)**, complementado con plugins analíticos de código abierto específicos para auditoría gerencial e ITIL.

---

## 1. 📈 Estadísticas Nativas en Tiempo Real (Menú Asistencia / Estadísticas)

Dentro de la interfaz web de GLPI, en el menú superior **Asistencia -> Estadísticas**, puedes generar gráficos y reportes interactivos filtrados por fecha, técnico o departamento:

### Reportes de Tickets:
- **Volumen de Incidencias:** Número de tickets abiertos, cerrados, en espera o resueltos por día, semana, mes o año.
- **Tiempos de Respuesta y Resolución:**
  - Tiempo medio de primera respuesta (*TTR / MTTR - Mean Time to Resolution*).
  - Tiempo total de resolución de incidencias.
- **Rendimiento por Técnico:** Cantidad de tickets resueltos por cada miembro del equipo de TI.
- **Análisis por Categoría / Servicio Crítico:**
  - Incidencias en Software Hotelero (PMS Opera, Sihot, etc.).
  - Fallas en Puntos de Venta (POS Restaurante / Cajas).
  - Problemas de Red / Wi-Fi Huéspedes.
  - Fallos en Cerraduras Electrónicas de habitaciones.
- **Análisis por Ubicación:** Ver qué piso, torre o área común genera más solicitudes de soporte.

---

## 2. 🎛️ Cuadro de Mando Ejecutivo (Dashboards)

GLPI v10 incluye paneles gráficos visuales tipo *Business Intelligence*:
- **Tarjetas KPI:**
  - % de Cumplimiento de SLA (ej. "94% de tickets resueltos antes del límite").
  - Tickets urgentes activos sin asignar.
  - Satisfacción del usuario / Encuestas de calidad post-cierre.
- **Gráficos de Torta y Barras:** Distribución de carga de trabajo entre el turno diurno y nocturno.
- **Filtros Dinámicos:** Puedes aislar datos de un rango de fechas con 1 clic.

---

## 3. 📋 Reportes Nativos de Gestión de Activos e Inventario (Menú Herramientas / Reportes)

En el menú **Herramientas -> Informes**, el sistema genera reportes de auditoría de hardware y licencias:
- **Reporte de Antigüedad y Renovación:** Cuántas computadoras tienen más de 3 o 5 años en el hotel para planificar presupuestos de recambio.
- **Estado de Garantías de Equipamiento:** Servidores, switches de piso y terminales POS bajo garantía vigente o expirada.
- **Auditoría de Licencias:** Cantidad de licencias de Windows, Office o software PMS instaladas vs. compradas (control contra sobre-licenciamiento).
- **Consumo de Repuestos y Consumibles:** Toners de recepción gastados, cables o lectores reemplazados.

---

## 4. 📤 Exportación de Reportes a Formatos Estándar

Cualquier reporte, lista de tickets o auditoría de inventario se puede exportar con un solo clic a:
- **PDF:** Listo para imprimir y presentar a Gerencia General o Auditorías de Marca (Marriott, Hilton, etc.).
- **Excel (.xlsx o .csv):** Para análisis financiero o tablas dinámicas avanzadas.
- **SLK / XML:** Para cruce con otros sistemas informáticos.

---

## 5. ⭐ Plugins de Reportes Avanzados (Opcionales)

Si el hotel requiere métricas aún más específicas para auditorías hoteleras internacionales:
1. **GLPI Reports (`plugins/reports`):** Añade más de 20 consultas SQL preconstruidas (listado de costos por intervención, horas trabajadas por técnico).
2. **Dashboard Plugin:** Cuadros de mando específicos para pantallas de monitoreo en el Data Center o taller de informática.
3. **Conexión Directa a Power BI / Metabase:** Al estar sobre MySQL/MariaDB, puedes conectar **Power BI** en solo 2 pasos para crear tableros gerenciales en tiempo real.
