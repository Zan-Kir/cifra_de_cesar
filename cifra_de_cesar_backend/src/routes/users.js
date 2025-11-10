const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const { getMe, getById, update, remove } = require('../controllers/userController');

router.use(auth);

router.get('/me', getMe);
router.get('/:id', getById);
router.put('/:id', update);
router.delete('/:id', remove);

module.exports = router;
