const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const { Pool } = require('pg');
const Redis = require('ioredis');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const path = require('path');

// Configuration
const app = express();
const PORT = process.env.PORT || 3000;

// Database pools
const pgPool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    database: process.env.DB_NAME || 'familyties',
    user: process.env.DB_USER || 'familyties',
    password: process.env.DB_PASSWORD || '',
    max: 20,
});

const redis = new Redis({
    host: process.env.REDIS_HOST || 'localhost',
    port: process.env.REDIS_PORT || 6379,
});

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json({ limit: '50mb' }));

// Authentication middleware
const authenticate = async (req, res, next) => {
    const token = req.headers.authorization?.split(' ')[1];
    if (!token) return res.status(401).json({ error: 'Unauthorized' });
    
    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET || 'dev_secret');
        req.user = decoded;
        next();
    } catch (err) {
        res.status(401).json({ error: 'Invalid token' });
    }
};

// Simple health check
app.get('/health', (req, res) => {
    res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

// Minimal route imports (placeholders)
app.use('/api/auth', require('./routes/auth'));

// Start server
app.listen(PORT, () => {
    console.log(`Family Ties server running on port ${PORT}`);
});

module.exports = { app, pgPool, redis };
