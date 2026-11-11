# Evidencias — Recetario UTEZ

**Nombre:** Juan José Díaz Barroso
**Matrícula:** 20233tn067
**Fecha:** 10 de noviembre de 2026
**Dispositivo donde se probó:** Chrome (Flutter web, compilación release) en Windows 11

## 1. Del JSON a Dart

| JSON | Campo Dart | Tipo | Regla (obligatorio, tolerado, valor por defecto) |
|---|---|---|---|
| `id` | `id` | `int` | Obligatorio. Si falta o no es `int` → `FormatException`. |
| `name` | `nombre` | `String` | Obligatorio. Si falta o no es texto → `FormatException`. |
| `cuisine` | `cocina` | `String` | Obligatorio. Si falta o no es texto → `FormatException`. |
| `difficulty` | `dificultad` | `Dificultad` | Tolerado. `Easy` → `facil`, `Medium` → `media`, `Hard` → `dificil`; cualquier otro valor, `null` o un número → `desconocida` ("Sin dato"). Nunca lanza error. |
| `prepTimeMinutes` | `minutosPreparacion` | `int` | Obligatorio. Si falta o no es `int` → `FormatException`. |
| `cookTimeMinutes` | `minutosCoccion` | `int` | Obligatorio. Si falta o no es `int` → `FormatException`. |
| `servings` | `porciones` | `int` | Obligatorio. Si falta o no es `int` (por ejemplo `"4"`) → `FormatException`. |
| `rating` | `calificacion` | `double` | Obligatorio. Se acepta cualquier `num` (entero `5` o decimal `4.6`) y se guarda con `.toDouble()`. |
| `tags` | `etiquetas` | `List<String>` | Opcional. Si falta → lista vacía. Si no es lista o algún elemento no es texto → `FormatException`. |
| `ingredients` | `ingredientes` | `List<String>` | Opcional. Si falta → lista vacía. Si no es lista o algún elemento no es texto → `FormatException`. |
| `recipes` | `PaginaRecetas.recetas` | `List<Receta>` | Obligatorio. Cada elemento debe ser objeto; una lista vacía es válida. |
| `total` | `PaginaRecetas.total` | `int` | Obligatorio. Si falta o no es `int` → `FormatException`. |
| `image`, `instructions`, `skip`, `limit`, etc. | — | — | Se ignoran. |

Campos calculados en el dominio: `tiempoTotal = minutosPreparacion + minutosCoccion` y `esRapida = tiempoTotal <= 30`.

## 2. Escenarios probados con el servicio real

La app se compiló para web y se abrió en Chrome contra `https://dummyjson.com`. En cada escenario se escribió `chicken` (o `zzzz`) en el campo y se tocó **Buscar recetas**.

En web, `developer.log` no llega a la consola del navegador. Para poder copiar la línea de la bitácora, durante las pruebas `main.dart` recibió temporalmente un `BitacoraInterceptor(escribir: print)` (la misma clase y el mismo formato). Ese cambio se quitó junto con los cambios A, B y C.

| Escenario | Cómo lo provoqué | Qué vio la persona | Línea de la bitácora | Captura | Prueba del kit que lo cubre |
|---|---|---|---|---|---|
| Éxito | Busqué `chicken` con el `main.dart` de la etapa 5. | El indicador de carga con el botón desactivado ([06_cargando.png](capturas/06_cargando.png)) y después las tarjetas con el encabezado "Mostrando 8 de 8 recetas · Rápidas: 1" (Chicken Alfredo Pasta, Mango Salsa Chicken, Chicken Biryani…). | `→ GET /recipes/search` y `← 200 GET /recipes/search (678 ms)` | [01_exito.png](capturas/01_exito.png) | `etapa3`: "200 → PaginaRecetas"; `etapa5`: "texto + botón → indicador y botón apagado → tarjetas" |
| Vacío | Busqué `zzzz`. DummyJSON respondió 200 con `"recipes": []`. | El mensaje `No encontramos recetas para "zzzz".` | `→ GET /recipes/search` y `← 200 GET /recipes/search (437 ms)` | [02_vacio.png](capturas/02_vacio.png) | `etapa3`: "200 sin resultados → página vacía"; `etapa4`: "sin resultados → Vacias, recordando qué se buscó"; `etapa5`: "vacío con texto dice qué se buscó; sin texto, otro mensaje" |
| Error del servidor | Cambio temporal A: un interceptor cambió la ruta a `/http/503` y DummyJSON respondió 503 de verdad. Busqué `chicken`. | "El recetario no está disponible (503). Intenta más tarde." y el botón **Reintentar**. | `→ GET /recipes/search` y `✗ badResponse 503 GET /http/503 (535 ms)` | [03_error_servidor.png](capturas/03_error_servidor.png) | `etapa3`: "503 → ErrorDelServidor(503)" y "en un error escribe una línea con ✗ y el código"; `etapa4`: "FallaRed → Fallidas con el mensaje de mensajePara" |
| Sin red | Cambio temporal C: un interceptor cambió `baseUrl` a `https://recetario.invalid`, un dominio que no existe (el navegador reportó `net::ERR_NAME_NOT_RESOLVED`). Lo usé porque la prueba se hizo en Chrome. Busqué `chicken`. | "Sin conexión. Revisa tu red e intenta de nuevo." y el botón **Reintentar**. | `→ GET /recipes/search` y `✗ connectionError GET /recipes/search (189 ms)` | [04_sin_red.png](capturas/04_sin_red.png) | `etapa3`: "sin red → SinConexion"; `etapa5`: "error → mensaje y Reintentar repite la misma búsqueda" |
| Tiempo agotado | Cambio temporal B: le pedí a DummyJSON `delay=5000` (5 s) y bajé `connectTimeout` y `receiveTimeout` a 2 s. Busqué `chicken`. | Primero el indicador de carga y, a los 2 s, "El recetario tardó demasiado en responder. Intenta de nuevo." con **Reintentar**. | `→ GET /recipes/search` y `✗ connectionTimeout GET /recipes/search (2023 ms)` (en web el timeout llega como `connectionTimeout`; se traduce igual a `TiempoAgotado`) | [05_tiempo_agotado.png](capturas/05_tiempo_agotado.png) | `etapa3`: "connectTimeout → TiempoAgotado" y "receiveTimeout → TiempoAgotado" |

En ninguna línea de la bitácora aparece `chicken` ni `zzzz`: solo el método, la ruta, el código, el tipo de error y el tiempo.

## 3. Preguntas de reflexión

1. **¿En qué se diferencian el escenario "Error del servidor" y "Sin red" desde el punto de vista de HTTP?**
   En el error del servidor sí hubo una conversación HTTP completa: la petición llegó a DummyJSON y el servidor contestó con una respuesta válida cuyo código de estado es 503. Dio lo reporta como `badResponse` y trae `statusCode`, por eso la bitácora muestra `✗ badResponse 503` y el mensaje incluye el código. En "Sin red" nunca hubo respuesta HTTP: falló antes, al resolver el dominio o abrir la conexión, así que no existe código de estado. Dio lo reporta como `connectionError` y la bitácora no trae código. Por eso uno se traduce a `ErrorDelServidor(503)` (el problema está del otro lado, "intenta más tarde") y el otro a `SinConexion` (el problema está en la red de la persona, "revisa tu red").

2. **¿Por qué "Vacío" no es un error?**
   Porque el servicio funcionó bien: respondió `200` con un JSON válido `{"recipes": [], "total": 0, ...}`. La búsqueda se hizo y la respuesta correcta es "no hay coincidencias". Por eso se representa con su propio estado `RecetasVacias`, que le dice a la persona qué buscó, en lugar de `RecetasFallidas` con un botón de reintentar que no cambiaría nada.

3. **La búsqueda de la persona viaja en la query. ¿Por qué tu bitácora no la escribe?**
   Porque lo que escribe una persona puede ser información privada y las bitácoras se guardan, se copian y se comparten con más gente que la que debería verla. La bitácora solo usa `options.method`, `options.path`, el código, el tipo de error y el tiempo; nunca `options.uri`, `queryParameters`, encabezados ni el cuerpo. Con eso basta para diagnosticar (qué ruta falló, con qué código y cuánto tardó) sin filtrar datos. La prueba de etapa 3 busca `enchiladas` y comprueba que no aparezca.

4. **Si DummyJSON cambiara `rating` por `score`, ¿qué archivos tendrías que modificar y por qué solo esos?**
   Solo `lib/datos/recetas_json.dart`: cambiar la llave `'rating'` por `'score'` en el patrón de `recetaDesdeJson`. Es el único archivo que conoce los nombres del JSON. El dominio (`Receta.calificacion`), el ViewModel y las vistas trabajan con el objeto Dart ya convertido, no con el JSON, así que no se enteran del cambio. Además habría que actualizar los datos de ejemplo de las pruebas, que imitan la respuesta del servidor. Esa es la ventaja de separar capas: el cambio del contrato externo se queda en la frontera de `lib/datos/`.
