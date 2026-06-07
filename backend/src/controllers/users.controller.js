const Book = require('../models/Book');
const User = require('../models/User');
const ApiError = require('../utils/ApiError');

const getMe = async (req, res) => {
  res.json({ success: true, data: req.user.toPublicJSON() });
};

const updateMe = async (req, res, next) => {
  try {
    const { name, avatar_url } = req.body;
    if (name) req.user.name = name;
    if (avatar_url !== undefined) req.user.avatar_url = avatar_url;
    await req.user.save();
    res.json({ success: true, data: req.user.toPublicJSON() });
  } catch (err) {
    next(err);
  }
};

const updateSettings = async (req, res, next) => {
  try {
    const { theme, language, notifications_enabled } = req.body;
    if (theme) req.user.settings.theme = theme;
    if (language) req.user.settings.language = language;
    if (notifications_enabled !== undefined) {
      req.user.settings.notifications_enabled = notifications_enabled;
    }
    req.user.markModified('settings');
    await req.user.save();
    res.json({ success: true, data: req.user.toPublicJSON() });
  } catch (err) {
    next(err);
  }
};

const resolveBook = async (bookId) => {
  let book = await Book.findById(bookId);
  if (!book) {
    book = await Book.findOne({ book_id: parseInt(bookId, 10) });
  }
  if (!book) {
    throw new ApiError(404, 'Book not found');
  }
  return book;
};

const addFavorite = async (req, res, next) => {
  try {
    const book = await resolveBook(req.params.bookId);
    const id = book._id.toString();
    if (!req.user.favorites.some((f) => f.toString() === id)) {
      req.user.favorites.push(book._id);
      await req.user.save();
    }
    res.json({ success: true, data: req.user.toPublicJSON() });
  } catch (err) {
    next(err);
  }
};

const removeFavorite = async (req, res, next) => {
  try {
    const book = await resolveBook(req.params.bookId);
    req.user.favorites = req.user.favorites.filter(
      (f) => f.toString() !== book._id.toString()
    );
    await req.user.save();
    res.json({ success: true, data: req.user.toPublicJSON() });
  } catch (err) {
    next(err);
  }
};

const addReadingList = async (req, res, next) => {
  try {
    const book = await resolveBook(req.params.bookId);
    const id = book._id.toString();
    if (!req.user.reading_list.some((f) => f.toString() === id)) {
      req.user.reading_list.push(book._id);
      await req.user.save();
    }
    res.json({ success: true, data: req.user.toPublicJSON() });
  } catch (err) {
    next(err);
  }
};

const removeReadingList = async (req, res, next) => {
  try {
    const book = await resolveBook(req.params.bookId);
    req.user.reading_list = req.user.reading_list.filter(
      (f) => f.toString() !== book._id.toString()
    );
    await req.user.save();
    res.json({ success: true, data: req.user.toPublicJSON() });
  } catch (err) {
    next(err);
  }
};

const deleteAccount = async (req, res, next) => {
  try {
    await User.deleteOne({ _id: req.user._id });
    res.json({ success: true, message: 'Account deleted' });
  } catch (err) {
    next(err);
  }
};

const getFavoriteBooks = async (req, res, next) => {
  try {
    const user = await User.findById(req.user._id).populate('favorites');
    res.json({
      success: true,
      data: (user.favorites || []).map((b) => b.toPublicJSON()),
    });
  } catch (err) {
    next(err);
  }
};

const getReadingListBooks = async (req, res, next) => {
  try {
    const user = await User.findById(req.user._id).populate('reading_list');
    res.json({
      success: true,
      data: (user.reading_list || []).map((b) => b.toPublicJSON()),
    });
  } catch (err) {
    next(err);
  }
};

module.exports = {
  getMe,
  updateMe,
  updateSettings,
  addFavorite,
  removeFavorite,
  addReadingList,
  removeReadingList,
  deleteAccount,
  getFavoriteBooks,
  getReadingListBooks,
};
