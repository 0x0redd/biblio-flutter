const mongoose = require('mongoose');

const reviewSchema = new mongoose.Schema(
  {
    book_id: { type: mongoose.Schema.Types.ObjectId, ref: 'Book', required: true, index: true },
    user_id: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
    rating: { type: Number, required: true, min: 1, max: 5 },
    comment: { type: String, required: true, trim: true },
  },
  { timestamps: { createdAt: 'created_at', updatedAt: false } }
);

reviewSchema.index({ book_id: 1, user_id: 1 }, { unique: true });

reviewSchema.methods.toPublicJSON = function toPublicJSON(user) {
  return {
    id: this._id.toString(),
    book_id: this.book_id.toString(),
    user_id: this.user_id.toString(),
    rating: this.rating,
    comment: this.comment,
    created_at: this.created_at,
    user: user
      ? { id: user._id.toString(), name: user.name, avatar_url: user.avatar_url }
      : undefined,
  };
};

module.exports = mongoose.model('Review', reviewSchema);
