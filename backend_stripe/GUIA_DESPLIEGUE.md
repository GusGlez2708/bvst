# Guía de Despliegue del Backend (Stripe)

Este backend es necesario para generar los "Payment Intents" de Stripe de forma segura. No debes guardar tus claves secretas en la app móvil.

## Opción Recomendada: Render (Gratis)

Render ofrece un tier gratuito para servicios web que es perfecto para este caso de uso.

### Pasos:

1.  **Sube este código a GitHub/GitLab**:
    *   Asegúrate de que la carpeta `backend_stripe` esté en tu repositorio (o crea un repo separado solo para esto si prefieres).
    *   **IMPORTANTE**: NO subas el archivo `.env` con tus claves reales. Usa `.env.example` como guía.

2.  **Crea una cuenta en [Render.com](https://render.com/)**.

3.  **Nuevo Web Service**:
    *   Haz clic en "New +" -> "Web Service".
    *   Conecta tu repositorio de GitHub.

4.  **Configuración**:
    *   **Name**: `bvst-backend` (o lo que quieras).
    *   **Root Directory**: `backend_stripe` (Si está dentro de una carpeta en tu repo).
    *   **Runtime**: Node
    *   **Build Command**: `npm install`
    *   **Start Command**: `node server.js`

5.  **Variables de Entorno (Environment Variables)**:
    *   En la sección "Advanced" o "Environment", añade las siguientes variables con TUS claves de Stripe (búscalas en tu Dashboard de Stripe):
        *   `STRIPE_SECRET_KEY`: `sk_test_...`
        *   `STRIPE_PUBLISHABLE_KEY`: `pk_test_...`

6.  **Desplegar**:
    *   Haz clic en "Create Web Service".
    *   Render te dará una URL (ej: `https://bvst-backend.onrender.com`).

### Conectar la App Móvil

Una vez tengas la URL de Render:

1.  Ve a `lib/screens/shop_screen.dart` en tu proyecto Flutter.
2.  Busca la variable o constante donde se define la URL del backend.
3.  Cámbiala por tu nueva URL de Render:
    ```dart
    final String _backendUrl = 'https://bvst-backend.onrender.com';
    ```
