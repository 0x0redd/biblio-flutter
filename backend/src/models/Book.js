const mongoose = require('mongoose');

const bookSchema = new mongoose.Schema(
  {
    book_id: { type: Number, required: true, unique: true },
    title: { type: String, required: true, index: 'text' },
    price: { type: Number, required: true },
    price_excl_tax: { type: Number },
    price_incl_tax: { type: Number },
    tax: { type: Number },
    rating: { type: Number, min: 1, max: 5, default: 1 },
    availability: { type: String },
    in_stock: { type: Boolean, default: true },
    stock_count: { type: Number, default: 0 },
    category: { type: String, index: true },
    subcategory: { type: String },
    upc: { type: String, unique: true, sparse: true },
    product_type: { type: String },
    number_of_reviews: { type: Number, default: 0 },
    url: { type: String },
    image_url: { type: String },
    description: { type: String },
  },
  { timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' } }
);

bookSchema.index({ rating: -1 });
bookSchema.index({ in_stock: 1 });

bookSchema.methods.toPublicJSON = function toPublicJSON() {
  return {
    id: this._id.toString(),
    book_id: this.book_id,
    title: this.title,
    price: this.price,
    price_excl_tax: this.price_excl_tax,
    price_incl_tax: this.price_incl_tax,
    tax: this.tax,
    rating: this.rating,
    availability: this.availability,
    in_stock: this.in_stock,
    stock_count: this.stock_count,
    category: this.category,
    subcategory: this.subcategory,
    upc: this.upc,
    product_type: this.product_type,
    number_of_reviews: this.number_of_reviews,
    url: this.url,
    image_url: this.image_url,
    description: this.description,
    created_at: this.created_at,
    updated_at: this.updated_at,
  };
};

module.exports = mongoose.model('Book', bookSchema);
