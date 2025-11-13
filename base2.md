


## 🖥️ Ajuste de proporciones y controles en pantalla

### 🎯 Objetivo

Mejorar la escala de todos los elementos del juego para que:

- El personaje, enemigo y proyectiles se vean más pequeños y proporcionados.
- Haya más **espacio visual** para moverse dentro del escenario.
- El estilo se asemeje al segundo ejemplo mostrado (con entorno amplio y personajes en escala más reducida).

---

### 🧩 Reglas para las proporciones

- El **personaje** debe ocupar aproximadamente **el 10–12% de la altura total de la pantalla**.
- El **enemigo** debe ocupar entre **15–20% de la altura total**, centrado horizontalmente en la parte superior.
- Las **balas** deben ser pequeñas, aproximadamente **3–4% de la altura total**.
- El **fondo** (`fondo.png`) debe **cubrir completamente la pantalla**, sin deformarse:
  ```dart
  Image.asset(
    'assets/images/fondo.png',
    fit: BoxFit.cover,
    width: double.infinity,
    height: double.infinity,
  )
  ```


* El escenario debe usar un `Stack` o un `Positioned` para manejar los tamaños relativos mediante porcentajes (`MediaQuery` o `LayoutBuilder`).

---

### 🕹️ Distribución de controles

#### Controles de movimiento (izquierda)

Colocar los botones de **izquierda** y **derecha** en la esquina inferior izquierda:

* Forma circular.
* Color base azul (#2196F3) con opacidad al 80%.
* Tamaño recomendado: 65–75 px de diámetro.
* Espaciado interno entre ellos: 10–15 px.

```dart
Positioned(
  bottom: 30,
  left: 20,
  child: Row(
    children: [
      _buildButton(Icons.arrow_left, onPressed: moverIzquierda),
      const SizedBox(width: 20),
      _buildButton(Icons.arrow_right, onPressed: moverDerecha),
    ],
  ),
)
```

#### Botón de disparo (derecha)

Colocar el **botón de disparo** en la esquina inferior derecha, separado de los otros:

* Forma circular, color  **naranja (#FF9500)** .
* Tamaño: 80 px de diámetro.
* Icono de flecha hacia arriba (simbolizando el disparo).

```dart
Positioned(
  bottom: 30,
  right: 30,
  child: _buildButton(
    Icons.arrow_upward,
    color: Colors.orange,
    onPressed: disparar,
  ),
)
```

#### Ejemplo de `_buildButton`

```dart
Widget _buildButton(IconData icon, {Color color = Colors.blue, required VoidCallback onPressed}) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: color.withOpacity(0.8),
      shape: const CircleBorder(),
      padding: const EdgeInsets.all(20),
      elevation: 4,
    ),
    onPressed: onPressed,
    child: Icon(icon, color: Colors.white, size: 30),
  );
}
```

---

### ⚙️ Ajuste del área visible y escalado dinámico

Para que todo se adapte bien a distintos tamaños de pantalla y evitar deformaciones:

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final screenHeight = constraints.maxHeight;
    final screenWidth = constraints.maxWidth;

    final enemyHeight = screenHeight * 0.18; // 18% del alto total
    final playerHeight = screenHeight * 0.12; // 12% del alto total

    return Stack(
      children: [
        // Fondo
        Positioned.fill(
          child: Image.asset(
            'assets/images/fondo.png',
            fit: BoxFit.cover,
          ),
        ),
        // Enemigo
        Positioned(
          top: 50,
          left: screenWidth / 2 - 50,
          child: SizedBox(
            height: enemyHeight,
            child: Image.asset('assets/images/enemigo.png'),
          ),
        ),
        // Personaje
        Positioned(
          bottom: 80,
          left: screenWidth / 2 - 50,
          child: SizedBox(
            height: playerHeight,
            child: Image.asset('assets/images/personaje.png'),
          ),
        ),
      ],
    );
  },
)
```

---

### 🧱 Reglas adicionales

* Todo el contenido debe estar dentro de un `SafeArea` y con `resizeToAvoidBottomInset: false` para evitar errores de “Bottom overflowed”.
* Usar `FractionallySizedBox`, `SizedBox` o porcentajes relativos para mantener escalas consistentes.
* Priorizar el **espacio libre en pantalla** (al menos un 30% del alto entre el enemigo y el personaje).
* Las colisiones deben actualizarse de acuerdo con los nuevos tamaños reducidos.

---

### ✅ Resultado esperado

* El personaje y enemigo tienen proporciones más realistas y equilibradas.
* Los botones están distribuidos ergonómicamente (movimiento a la izquierda, disparo a la derecha).
* Se mantiene la jugabilidad fluida y sin desbordamientos visuales.
* Visualmente se asemeja más a un juego tipo  **plataforma ligera** , con espacio para ver el escenario y proyectiles.
