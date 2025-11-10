const HashEntry = require('../models/HashEntry');

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
