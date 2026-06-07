const jwt = require('jsonwebtoken');
const User = require('../models/User');
const ApiError = require('../utils/ApiError');
const { verifyAccessToken } = require('../utils/token');

const auth = async (req, res, next) => {
  try {
    const header = req.headers.authorization;
    if (!header || !header.startsWith('Bearer ')) {
      throw new ApiError(401, 'Authentication required');
    }

    const token = header.slice(7);
    const payload = verifyAccessToken(token);
    const user = await User.findById(payload.sub);
    if (!user) {
      throw new ApiError(401, 'User not found');
    }

    req.user = user;
    next();
  } catch (err) {
    if (err instanceof ApiError) {
      return next(err);
    }
    if (err instanceof jwt.JsonWebTokenError) {
      return next(new ApiError(401, 'Invalid token'));
    }
    return next(err);
  }
};

module.exports = auth;
