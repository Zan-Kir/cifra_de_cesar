const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const { createHash, findByHash, markUsed, findById, consumeByHash } = require('../controllers/hashController');

router.post('/', auth, createHash);
router.post('/consume', auth, consumeByHash);
router.get('/', findByHash);
router.get('/:id', findById);
router.post('/:id/use', auth, markUsed);

module.exports = router;
