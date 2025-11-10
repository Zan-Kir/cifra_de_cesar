const mongoose = require('mongoose');

const hashSchema = new mongoose.Schema({
  hash: { type: String, required: true, index: true, unique: true },
  passo: { type: Number, required: true },
  usado: { type: Boolean, default: false },
}, { timestamps: true });

module.exports = mongoose.model('HashEntry', hashSchema);
