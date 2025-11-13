# 🎮 Especificaciones del juego base en Flutter: "Battle Chase"

## 📱 Plataforma de destino

- Android y iOS
- Orientación: **horizontal fija (Landscape only)**

---

## 🧩 Descripción general

El juego consiste en una batalla entre un **enemigo (arriba)** y un **personaje (abajo)**.

- El **enemigo** se moverá automáticamente **de izquierda a derecha y viceversa**, disparando hacia abajo.
- El **personaje** se controla tocando un **botón de disparo**, enviando proyectiles hacia arriba.
- Ambos pueden dañarse entre sí mediante colisiones de proyectiles.
- Al recibir cierta cantidad de impactos, uno u otro muere.
- Cuando el personaje gana o pierde, aparecerá una pantalla con el resultado y un botón para volver al menú principal.

---

## 🖼️ Elementos gráficos

El juego usará imágenes (que el desarrollador añadirá luego) para representar:

- `fondo.png` → Fondo del escenario.
  - **Dimensiones recomendadas:** 1920x1080 px (para cubrir pantallas horizontales completas).
  - El fondo debe **ajustarse a toda la pantalla** con `BoxFit.cover` o `BoxFit.fill`.
- `enemigo.png` → Imagen del enemigo.
- `personaje.png` → Imagen del jugador.
- `bala_enemigo.png` → Imagen de la bala disparada por el enemigo.
- `bala_personaje.png` → Imagen de la bala disparada por el personaje.

---

## 🎮 Mecánica del juego

### Enemigo

- Se mueve horizontalmente **automático** de izquierda a derecha.
- Dispara hacia abajo cada cierto intervalo (por ejemplo, cada 1.5 segundos).
- Su bala viaja en **línea recta hacia abajo** hasta salir de pantalla o colisionar.
- Tiene **15 puntos de vida**.
- Cuando su vida llega a 0, aparece la pantalla **“YOU WIN”**.

### Personaje

- Se encuentra fijo en la parte inferior de la pantalla.
- Tiene un **botón en pantalla** para disparar.
- Al disparar, su bala va **recto hacia arriba** desde su posición actual.
- Tiene **3 puntos de vida**.
- Si recibe 3 impactos del enemigo, aparece **“GAME OVER”**.

---

## 💥 Lógica de colisión

- Cuando una bala del personaje impacta al enemigo:
  - La bala desaparece.
  - Se resta 1 punto de vida al enemigo.
- Cuando una bala del enemigo impacta al personaje:
  - La bala desaparece.
  - Se resta 1 punto de vida al personaje.
- Al llegar a 0 puntos, se detiene el juego y se muestra la pantalla correspondiente.

---

## 🧠 Flujo del juego

1. **Pantalla de inicio (Main Menu):**

   - Título del juego: “Battle Chase”.
   - Botón principal: “JUGAR”.
   - Fondo con el mismo `fondo.png` o una variante oscurecida.
   - Colores llamativos: azul eléctrico (#1E90FF) y naranja (#FF9500).
2. **Contador inicial:**

   - Al presionar “JUGAR”, aparece un contador animado **3, 2, 1, ¡YA!** antes de comenzar el juego.
3. **Pantalla de juego (Game Screen):**

   - Fondo completo con la imagen ajustada al tamaño total de la pantalla.
   - Enemigo en la parte superior, moviéndose automáticamente.
   - Personaje en la parte inferior, con botón de disparo visible (por ejemplo, en la esquina inferior derecha).
   - Marcadores de vida en texto o íconos.
4. **Pantalla final:**

   - Si el jugador gana: “YOU WIN 🎉”.
   - Si pierde: “GAME OVER 💀”.
   - Botón de “Regresar al menú”.

---

## 🧱 Reglas técnicas

- Usar el paquete `flame` para gestionar sprites, posiciones, colisiones y animaciones básicas.
- Evitar errores de **Bottom Overflowed**:
  ```dart
  SafeArea(
    child: Scaffold(
      resizeToAvoidBottomInset: false,
      body: ...
    ),
  )
  ```


* Asegurar que todos los widgets principales estén dentro de `SafeArea` y usen `Stack` para posicionar elementos (fondo, enemigo, personaje, botones y balas).
* Utilizar `MediaQuery` para obtener dimensiones de pantalla y posicionar correctamente todos los objetos.

---

## 🔊 Estilo visual moderno

* Usar colores vibrantes, interfaz limpia y moderna.
* Fuentes tipo **Orbitron** o **Press Start 2P** (retro moderno).
* Botones redondeados con sombras suaves.
* Agregar una pequeña animación al presionar “JUGAR” y al mostrar “YOU WIN” o “GAME OVER”.

---

## 🕹️ Estructura sugerida del proyecto

```
lib/
│
├─ main.dart                # Punto de entrada
├─ screens/
│   ├─ menu_screen.dart     # Pantalla de inicio
│   ├─ game_screen.dart     # Pantalla principal del juego
│   └─ result_screen.dart   # Pantalla de resultado
│
├─ game/
│   ├─ battle_game.dart     # Lógica principal (Flame)
│   ├─ player.dart          # Clase del personaje
│   ├─ enemy.dart           # Clase del enemigo
│   ├─ bullet.dart          # Clase de balas (enemigo y jugador)
│   └─ utils.dart           # Funciones auxiliares
│
└─ assets/
    ├─ images/
    │   ├─ fondo.png
    │   ├─ enemigo.png
    │   ├─ personaje.png
    │   ├─ bala_enemigo.png
    │   └─ bala_personaje.png
    └─ fonts/
```

---

## 🧩 Dependencias recomendadas en `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  flame: ^1.16.0
  google_fonts: ^6.2.0
```

---

## ✅ Reglas finales

* El juego debe **funcionar completamente**:

  * Movimiento del enemigo.
  * Disparos del enemigo y del personaje.
  * Colisiones detectadas correctamente.
  * Pantallas de inicio, juego y resultado enlazadas.
* Todos los assets deben cargarse desde `/assets/images/`.
* Asegurar compatibilidad con cualquier tamaño de pantalla horizontal.
* No incluir funciones vacías o sin uso.
* Evitar cualquier error visual o de overflow.

---

## 🧠 Objetivo de esta versión

Este documento define la **versión base funcional** del juego.
No requiere arte avanzado ni sonido, solo la lógica, navegación, y mecánica base bien implementada y estable para seguir construyendo sobre ella.

---
