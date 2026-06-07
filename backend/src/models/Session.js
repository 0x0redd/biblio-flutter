const mongoose = require('mongoose');

const sessionSchema = new mongoose.Schema(
  {
    user_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    refresh_token: { type: String, required: true },
    expires_at: { type: Date, required: true },
  },
  { timestamps: { createdAt: 'created_at', updatedAt: false } }
);

module.exports = mongoose.model('Session', sessionSchema);
