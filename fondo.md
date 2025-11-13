


### 🔧 Corrección del fondo (quitar marcos blancos)

- Elimina cualquier `padding`, `Center` o `SizedBox` alrededor del fondo.
- El fondo debe ir como **primera capa de un `Stack`**, ocupando el 100% del ancho y alto de la pantalla.
- Reemplaza la forma en la que se pinta el fondo por este esquema:

```dart
return Scaffold(
  // Para que, si algo queda descubierto, no se vea blanco
  backgroundColor: Colors.black,
  body: SafeArea(
    // No agregues espacios extra arriba/abajo
    top: false,
    bottom: false,
    child: Stack(
      children: [
        // 🔹 Fondo a pantalla completa, sin marcos:
        Positioned.fill(
          child: Image.asset(
            'assets/images/fondo.png',
            fit: BoxFit.cover, // IMPORTANTE: que sea cover, NO contain
          ),
        ),

        // 🔹 Encima de esto ya va todo el juego:
        // jugador, enemigo, balas, botones, HUD, etc.
      ],
    ),
  ),
);
```


* Si en lugar de `Positioned.fill` usas un `Container`, asegúrate de que sea así:

```dart
Container(
  width: double.infinity,
  height: double.infinity,
  decoration: const BoxDecoration(
    image: DecorationImage(
      image: AssetImage('assets/images/fondo.png'),
      fit: BoxFit.cover, // también cover aquí
    ),
  ),
)
```


Regla: la imagen de fondo **siempre debe cubrir toda la pantalla** sin dejar bordes visibles; si la relación de aspecto no coincide, se recorta la imagen antes que dejar marcos blancos.
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
