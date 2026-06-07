const express = require('express');
const { body } = require('express-validator');
const usersController = require('../controllers/users.controller');
const auth = require('../middleware/auth');
const validate = require('../middleware/validate');

const router = express.Router();

router.use(auth);

router.get('/me', usersController.getMe);
router.put('/me', usersController.updateMe);
router.delete('/me', usersController.deleteAccount);
router.put(
  '/me/settings',
  [
    body('theme').optional().isIn(['light', 'dark', 'system']),
    body('language').optional().isString(),
    body('notifications_enabled').optional().isBoolean(),
  ],
  validate,
  usersController.updateSettings
);

router.get('/me/favorites', usersController.getFavoriteBooks);
router.get('/me/reading-list', usersController.getReadingListBooks);
router.post('/me/favorites/:bookId', usersController.addFavorite);
router.delete('/me/favorites/:bookId', usersController.removeFavorite);
router.post('/me/reading-list/:bookId', usersController.addReadingList);
router.delete('/me/reading-list/:bookId', usersController.removeReadingList);

module.exports = router;
