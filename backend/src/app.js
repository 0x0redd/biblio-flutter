const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');

const authRoutes = require('./routes/auth.routes');
const booksRoutes = require('./routes/books.routes');
const usersRoutes = require('./routes/users.routes');
const reviewsRoutes = require('./routes/reviews.routes');
const errorHandler = require('./middleware/errorHandler');

const app = express();

app.use(helmet());
app.use(cors());
app.use(morgan('dev'));
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.use('/api/auth', authRoutes);
app.use('/api/books', booksRoutes);
app.use('/api/users', usersRoutes);
app.use('/api/reviews', reviewsRoutes);

app.use(errorHandler);

module.exports = app;
