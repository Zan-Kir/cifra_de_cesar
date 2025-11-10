const mongoose = require('mongoose');

const hashSchema = new mongoose.Schema({
  hash: { type: String, required: true, index: true, unique: true },
  passo: { type: Number, required: true },
  ciphertext: { type: String, required: true },
  usado: { type: Boolean, default: false },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
}, { timestamps: true });

module.exports = mongoose.model('HashEntry', hashSchema);
