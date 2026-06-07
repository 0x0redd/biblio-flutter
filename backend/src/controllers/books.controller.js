const Book = require('../models/Book');
const ApiError = require('../utils/ApiError');

const listBooks = async (req, res, next) => {
  try {
    const page = Math.max(1, parseInt(req.query.page, 10) || 1);
    const limit = Math.min(100, parseInt(req.query.limit, 10) || 20);
    const skip = (page - 1) * limit;

    const filter = {};
    if (req.query.category) {
      filter.category = req.query.category;
    }
    if (req.query.in_stock !== undefined) {
      filter.in_stock = req.query.in_stock === 'true';
    }
    if (req.query.rating) {
      filter.rating = parseInt(req.query.rating, 10);
    }

    const [books, total] = await Promise.all([
      Book.find(filter).sort({ book_id: -1 }).skip(skip).limit(limit),
      Book.countDocuments(filter),
    ]);

    res.json({
      success: true,
      data: books.map((b) => b.toPublicJSON()),
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    });
  } catch (err) {
    next(err);
  }
};

const getBook = async (req, res, next) => {
  try {
    const book = await Book.findById(req.params.id);
    if (!book) {
      throw new ApiError(404, 'Book not found');
    }
    res.json({ success: true, data: book.toPublicJSON() });
  } catch (err) {
    next(err);
  }
};

const searchBooks = async (req, res, next) => {
  try {
    const q = (req.query.q || '').trim();
    if (!q) {
      return res.json({ success: true, data: [] });
    }

    const books = await Book.find({
      $text: { $search: q },
    }).limit(50);

    if (books.length === 0) {
      const regex = new RegExp(q, 'i');
      const fallback = await Book.find({
        $or: [{ title: regex }, { category: regex }],
      }).limit(50);
      return res.json({ success: true, data: fallback.map((b) => b.toPublicJSON()) });
    }

    res.json({ success: true, data: books.map((b) => b.toPublicJSON()) });
  } catch (err) {
    next(err);
  }
};

const getCategories = async (req, res, next) => {
  try {
    const categories = await Book.distinct('category');
    res.json({ success: true, data: categories.filter(Boolean).sort() });
  } catch (err) {
    next(err);
  }
};

const getBooksByCategory = async (req, res, next) => {
  try {
    const page = Math.max(1, parseInt(req.query.page, 10) || 1);
    const limit = Math.min(100, parseInt(req.query.limit, 10) || 20);
    const skip = (page - 1) * limit;
    const category = req.params.name;

    const filter = { category: new RegExp(`^${category}$`, 'i') };
    const [books, total] = await Promise.all([
      Book.find(filter).sort({ book_id: -1 }).skip(skip).limit(limit),
      Book.countDocuments(filter),
    ]);

    res.json({
      success: true,
      data: books.map((b) => b.toPublicJSON()),
      pagination: { page, limit, total, totalPages: Math.ceil(total / limit) },
    });
  } catch (err) {
    next(err);
  }
};

module.exports = {
  listBooks,
  getBook,
  searchBooks,
  getCategories,
  getBooksByCategory,
};
