const bcrypt = require('bcryptjs');
const User = require('../models/User');

function sanitize(user) {
  if (!user) return null;
  const obj = user.toObject ? user.toObject() : user;
  delete obj.passwordHash;
  return obj;
}

exports.getMe = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);
    if (!user) return res.status(404).json({ message: 'User not found' });
    return res.json(sanitize(user));
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Server error' });
  }
};

exports.getById = async (req, res) => {
  try {
    const { id } = req.params;
    if (id !== req.user.id) return res.status(403).json({ message: 'Forbidden' });
    const user = await User.findById(id);
    if (!user) return res.status(404).json({ message: 'User not found' });
    return res.json(sanitize(user));
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Server error' });
  }
};

exports.update = async (req, res) => {
  try {
    const { id } = req.params;
    if (id !== req.user.id) return res.status(403).json({ message: 'Forbidden' });

    const { email, password } = req.body;
    const updates = {};
    if (email) updates.email = email;
    if (password) {
      const salt = await bcrypt.genSalt(10);
      updates.passwordHash = await bcrypt.hash(password, salt);
    }

    const user = await User.findByIdAndUpdate(id, updates, { new: true });
    if (!user) return res.status(404).json({ message: 'User not found' });
    return res.json(sanitize(user));
  } catch (err) {
    console.error(err);
    if (err.code === 11000) return res.status(409).json({ message: 'Email already in use' });
    return res.status(500).json({ message: 'Server error' });
  }
};

exports.remove = async (req, res) => {
  try {
    const { id } = req.params;
    if (id !== req.user.id) return res.status(403).json({ message: 'Forbidden' });
    await User.findByIdAndDelete(id);
    return res.json({ message: 'User deleted' });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ message: 'Server error' });
  }
};
