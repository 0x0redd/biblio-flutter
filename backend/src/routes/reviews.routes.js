const express = require('express');
const { body } = require('express-validator');
const reviewsController = require('../controllers/reviews.controller');
const auth = require('../middleware/auth');
const validate = require('../middleware/validate');

const router = express.Router();

router.get('/book/:bookId', reviewsController.getReviewsForBook);

router.post(
  '/',
  auth,
  [
    body('book_id').notEmpty().withMessage('book_id required'),
    body('rating').isInt({ min: 1, max: 5 }).withMessage('Rating must be 1-5'),
    body('comment').trim().notEmpty().withMessage('Comment required'),
  ],
  validate,
  reviewsController.createReview
);

router.delete('/:id', auth, reviewsController.deleteReview);

module.exports = router;
