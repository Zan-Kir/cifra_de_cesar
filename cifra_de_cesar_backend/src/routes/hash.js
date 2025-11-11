const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const { encrypt, decrypt, createHash, findByHash, markUsed, findById, consumeByHash } = require('../controllers/hashController');

router.post('/encrypt', auth, encrypt);
router.post('/decrypt', auth, decrypt);

router.post('/', auth, createHash);
router.post('/consume', auth, consumeByHash);
router.get('/', findByHash);
router.get('/:id', findById);
router.post('/:id/use', auth, markUsed);

module.exports = router;
