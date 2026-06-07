require('dotenv').config();

const fs = require('fs');
const path = require('path');
const csv = require('csv-parser');
const mongoose = require('mongoose');
const Book = require('../src/models/Book');

const uri = process.env.MONGODB_URI || 'mongodb://localhost:27017/bookshelf_db';
const csvPath = path.resolve(
  __dirname,
  '..',
  process.env.CSV_PATH || '../scrapebooks/books.csv'
);

async function seedBooks() {
  await mongoose.connect(uri);
  console.log('Connected to MongoDB');

  const books = [];

  await new Promise((resolve, reject) => {
    fs.createReadStream(csvPath)
      .pipe(csv())
      .on('data', (row) => {
        const imageUrl = (row.image_url || '').replace(/^http:\/\//, 'https://');
        const url = (row.url || '').replace(/^http:\/\//, 'https://');

        books.push({
          book_id: parseInt(row.id, 10),
          title: row.title,
          price: parseFloat(row.price),
          price_excl_tax: parseFloat(row.price_excl_tax),
          price_incl_tax: parseFloat(row.price_incl_tax),
          tax: parseFloat(row.tax),
          rating: parseInt(row.rating, 10) || 1,
          availability: row.availability,
          in_stock: row.in_stock === 'True' || row.in_stock === 'true',
          stock_count: parseInt(row.stock_count, 10) || 0,
          category: row.category,
          subcategory: row.subcategory,
          upc: row.upc,
          product_type: row.product_type,
          number_of_reviews: parseInt(row.number_of_reviews, 10) || 0,
          url,
          image_url: imageUrl,
          description: row.description,
          created_at: new Date(),
          updated_at: new Date(),
        });
      })
      .on('end', resolve)
      .on('error', reject);
  });

  console.log(`Parsed ${books.length} books from CSV`);

  let upserted = 0;
  for (const book of books) {
    await Book.updateOne({ book_id: book.book_id }, { $set: book }, { upsert: true });
    upserted += 1;
  }

  await Book.collection.createIndex({ book_id: 1 }, { unique: true });
  await Book.collection.createIndex({ title: 'text' });
  await Book.collection.createIndex({ category: 1 });
  await Book.collection.createIndex({ rating: -1 });
  await Book.collection.createIndex({ in_stock: 1 });

  console.log(`Upserted ${upserted} books into bookshelf_db`);
  await mongoose.disconnect();
}

seedBooks().catch((err) => {
  console.error(err);
  process.exit(1);
});
