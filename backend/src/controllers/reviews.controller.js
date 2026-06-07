const Review = require('../models/Review');
const Book = require('../models/Book');
const User = require('../models/User');
const ApiError = require('../utils/ApiError');

const getReviewsForBook = async (req, res, next) => {
  try {
    const book = await Book.findById(req.params.bookId);
    if (!book) {
      throw new ApiError(404, 'Book not found');
    }

    const reviews = await Review.find({ book_id: book._id })
      .sort({ created_at: -1 })
      .limit(50);

    const userIds = reviews.map((r) => r.user_id);
    const users = await User.find({ _id: { $in: userIds } });
    const userMap = Object.fromEntries(users.map((u) => [u._id.toString(), u]));

    res.json({
      success: true,
      data: reviews.map((r) =>
        r.toPublicJSON(userMap[r.user_id.toString()])
      ),
    });
  } catch (err) {
    next(err);
  }
};

const createReview = async (req, res, next) => {
  try {
    const { book_id, rating, comment } = req.body;
    const book = await Book.findById(book_id);
    if (!book) {
      throw new ApiError(404, 'Book not found');
    }

    const existing = await Review.findOne({
      book_id: book._id,
      user_id: req.user._id,
    });
    if (existing) {
      throw new ApiError(409, 'You already reviewed this book');
    }

    const review = await Review.create({
      book_id: book._id,
      user_id: req.user._id,
      rating,
      comment,
    });

    const count = await Review.countDocuments({ book_id: book._id });
    book.number_of_reviews = count;
    await book.save();

    res.status(201).json({
      success: true,
      data: review.toPublicJSON(req.user),
    });
  } catch (err) {
    next(err);
  }
};

const deleteReview = async (req, res, next) => {
  try {
    const review = await Review.findById(req.params.id);
    if (!review) {
      throw new ApiError(404, 'Review not found');
    }
    if (review.user_id.toString() !== req.user._id.toString()) {
      throw new ApiError(403, 'Not authorized to delete this review');
    }

    await review.deleteOne();
    const book = await Book.findById(review.book_id);
    if (book) {
      book.number_of_reviews = await Review.countDocuments({ book_id: book._id });
      await book.save();
    }

    res.json({ success: true, message: 'Review deleted' });
  } catch (err) {
    next(err);
  }
};

module.exports = { getReviewsForBook, createReview, deleteReview };
