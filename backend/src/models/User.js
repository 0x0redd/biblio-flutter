const mongoose = require('mongoose');

const settingsSchema = new mongoose.Schema(
  {
    theme: { type: String, enum: ['light', 'dark', 'system'], default: 'system' },
    language: { type: String, default: 'en' },
    notifications_enabled: { type: Boolean, default: true },
  },
  { _id: false }
);

const userSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, trim: true },
    email: { type: String, required: true, unique: true, lowercase: true, trim: true },
    password_hash: { type: String, required: true },
    avatar_url: { type: String, default: null },
    role: { type: String, enum: ['user', 'admin'], default: 'user' },
    favorites: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Book' }],
    reading_list: [{ type: mongoose.Schema.Types.ObjectId, ref: 'Book' }],
    settings: { type: settingsSchema, default: () => ({}) },
  },
  { timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' } }
);

userSchema.index({ created_at: -1 });

userSchema.methods.toPublicJSON = function toPublicJSON() {
  return {
    id: this._id.toString(),
    name: this.name,
    email: this.email,
    avatar_url: this.avatar_url,
    role: this.role,
    favorites: this.favorites.map((id) => id.toString()),
    reading_list: this.reading_list.map((id) => id.toString()),
    settings: this.settings,
    created_at: this.created_at,
    updated_at: this.updated_at,
  };
};

module.exports = mongoose.model('User', userSchema);
