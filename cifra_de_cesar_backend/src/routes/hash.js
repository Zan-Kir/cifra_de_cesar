const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const { encrypt, decrypt, createHash, findByHash, markUsed, findById, consumeByHash } = require('../controllers/hashController');

// Novos endpoints para o frontend Flutter
router.post('/encrypt', auth, encrypt);
router.post('/decrypt', auth, decrypt);

// Endpoints existentes
router.post('/', auth, createHash);
router.post('/consume', auth, consumeByHash);
router.get('/', findByHash);
router.get('/:id', findById);
router.post('/:id/use', auth, markUsed);

module.exports = router;
