const express = require('express');
const booksController = require('../controllers/books.controller');

const router = express.Router();

router.get('/search', booksController.searchBooks);
router.get('/categories', booksController.getCategories);
router.get('/category/:name', booksController.getBooksByCategory);
router.get('/', booksController.listBooks);
router.get('/:id', booksController.getBook);

module.exports = router;
