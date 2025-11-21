require('dotenv').config();
const express = require('express');
const cors = require('cors');
const Stripe = require('stripe');

const app = express();
const stripe = Stripe(process.env.STRIPE_SECRET_KEY);

app.use(cors());
app.use(express.json());

// Endpoint para crear el Payment Sheet
app.post('/payment-sheet', async (req, res) => {
  try {
    const { amount, currency = 'mxn' } = req.body;

    // 1. Crear un Customer (Opcional: podrías reutilizar customers si tuvieras auth)
    const customer = await stripe.customers.create();

    // 2. Crear una Ephemeral Key (Necesaria para el Payment Sheet en móvil)
    const ephemeralKey = await stripe.ephemeralKeys.create(
      { customer: customer.id },
      { apiVersion: '2023-10-16' } // Usa la versión más reciente o la que coincida con tu SDK
    );

    // 3. Crear el PaymentIntent con el monto y moneda
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount, // En centavos (ej: 1000 = $10.00)
      currency: currency,
      customer: customer.id,
      automatic_payment_methods: {
        enabled: true,
      },
    });

    // 4. Devolver los secretos al cliente
    res.json({
      paymentIntent: paymentIntent.client_secret,
      ephemeralKey: ephemeralKey.secret,
      customer: customer.id,
      publishableKey: process.env.STRIPE_PUBLISHABLE_KEY
    });

  } catch (error) {
    console.error('Error al crear payment sheet:', error);
    res.status(500).json({ error: error.message });
  }
});

// Endpoint de prueba
app.get('/', (req, res) => {
  res.send('BVST Stripe Backend is running!');
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Servidor corriendo en el puerto ${PORT}`);
});
