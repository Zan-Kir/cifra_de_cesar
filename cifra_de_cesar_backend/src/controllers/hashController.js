const HashEntry = require('../models/HashEntry');
const crypto = require('crypto');

// Função de criptografia César
function cesarEncode(text, shift) {
  return text.split('').map(char => {
    const code = char.charCodeAt(0);
    // Letras maiúsculas A-Z
    if (code >= 65 && code <= 90) {
      return String.fromCharCode(((code - 65 + shift) % 26) + 65);
    }
    // Letras minúsculas a-z
    if (code >= 97 && code <= 122) {
      return String.fromCharCode(((code - 97 + shift) % 26) + 97);
    }
    // Outros caracteres não são alterados
    return char;
  }).join('');
}

// Função de descriptografia César
function cesarDecode(text, shift) {
  return cesarEncode(text, 26 - (shift % 26));
}

// Endpoint para criptografar
exports.encrypt = async (req, res) => {
  try {
    const { plaintext, shift } = req.body;
    if (!plaintext || shift === undefined) {
      return res.status(400).json({ message: 'plaintext and shift required' });
    }

    const userId = req.userId; // Vem do middleware auth
    const ciphertext = cesarEncode(plaintext, shift);
    
    // Gera um hash aleatório seguro
    const hash = crypto.randomBytes(16).toString('hex');

    const entry = new HashEntry({
      hash,
      passo: shift,
      ciphertext,
      usado: false,
      userId,
    });

    await entry.save();
    return res.json({ hash, ciphertext });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Server error' });
  }
};

// Endpoint para descriptografar
exports.decrypt = async (req, res) => {
  try {
    const { hash, ciphertext } = req.body;
    if (!hash) {
      return res.status(400).json({ message: 'hash required' });
    }

    const entry = await HashEntry.findOne({ hash });
    if (!entry) {
      return res.status(404).json({ message: 'Hash not found' });
    }

    if (entry.usado) {
      return res.status(400).json({ message: 'Hash already used' });
    }

    // Validar ciphertext se fornecido
    if (ciphertext && ciphertext !== entry.ciphertext) {
      return res.status(400).json({ message: 'Ciphertext does not match' });
    }

    // Descriptografa
    const plaintext = cesarDecode(entry.ciphertext, entry.passo);

    // Marca como usado
    entry.usado = true;
    await entry.save();

    return res.json({ plaintext, ciphertext: entry.ciphertext });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Server error' });
  }
};

exports.createHash = async (req, res) => {
  try {
    const { hash, passo } = req.body;
    if (!hash || passo === undefined) return res.status(400).json({ message: 'hash and passo required' });
    const existing = await HashEntry.findOne({ hash });
    if (existing) return res.status(409).json({ message: 'Hash already exists' });

    const entry = new HashEntry({ hash, passo, usado: false });
    await entry.save();
    return res.status(201).json(entry);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Server error' });
  }
};

exports.findByHash = async (req, res) => {
  try {
    const { hash } = req.query;
    if (!hash) return res.status(400).json({ message: 'hash query param required' });

    const entry = await HashEntry.findOne({ hash });
    if (!entry) return res.status(404).json({ message: 'Not found' });
    return res.json(entry);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Server error' });
  }
};

exports.findById = async (req, res) => {
  try {
    const { id } = req.params;
    const entry = await HashEntry.findById(id);
    if (!entry) return res.status(404).json({ message: 'Not found' });
    return res.json(entry);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Server error' });
  }
};

exports.markUsed = async (req, res) => {
  try {
    const { id } = req.params;
    const entry = await HashEntry.findOneAndUpdate(
      { _id: id, usado: false },
      { $set: { usado: true } },
      { new: true }
    );
    if (!entry) {
      const maybe = await HashEntry.findById(id);
      if (!maybe) return res.status(404).json({ message: 'Not found' });
      return res.status(400).json({ message: 'Already used' });
    }
    return res.json(entry);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Server error' });
  }
};

exports.consumeByHash = async (req, res) => {
  try {
    const { hash } = req.body;
    if (!hash) return res.status(400).json({ message: 'hash required' });

    const entry = await HashEntry.findOneAndUpdate(
      { hash: hash, usado: false },
      { $set: { usado: true } },
      { new: true }
    );

    if (!entry) {
      const maybe = await HashEntry.findOne({ hash });
      if (!maybe) return res.status(404).json({ message: 'Not found' });
      return res.status(400).json({ message: 'Hash already used' });
    }

    return res.json(entry);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Server error' });
  }
};
