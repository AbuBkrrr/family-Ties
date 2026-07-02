const express = require('express');
const router = express.Router();
const { v4: uuidv4 } = require('uuid');

// NOTE: This is a minimal placeholder implementation for registration.
// It should be replaced by a production-ready implementation (validation, hashing, email checks, etc.).

// POST /api/auth/register
router.post('/register', async (req, res) => {
    try {
        const { email, phone, fullName, birthDate, location } = req.body;
        if (!email || !fullName) return res.status(400).json({ error: 'email and fullName required' });

        // TODO: persist user in DB. For now return a mocked user and token.
        const user = {
            user_id: uuidv4(),
            email,
            phone,
            full_name: fullName,
            birth_date: birthDate || null,
            location_city: location?.city || null,
            location_country: location?.country || null,
            created_at: new Date().toISOString()
        };

        // Create a simple JWT (dev only)
        const token = require('jsonwebtoken').sign({ user_id: user.user_id, email: user.email }, process.env.JWT_SECRET || 'dev_secret', { expiresIn: '7d' });

        res.json({ user, token });
    } catch (err) {
        console.error('Register error', err);
        res.status(500).json({ error: 'server_error' });
    }
});

module.exports = router;
