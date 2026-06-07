const jwt = require('jsonwebtoken');
const crypto = require('crypto');

const signAccessToken = (userId) =>
  jwt.sign({ sub: userId }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  });

const signRefreshToken = (userId) =>
  jwt.sign({ sub: userId, type: 'refresh' }, process.env.REFRESH_TOKEN_SECRET, {
    expiresIn: process.env.REFRESH_TOKEN_EXPIRES_IN || '30d',
  });

const verifyAccessToken = (token) =>
  jwt.verify(token, process.env.JWT_SECRET);

const verifyRefreshToken = (token) =>
  jwt.verify(token, process.env.REFRESH_TOKEN_SECRET);

const hashToken = (token) =>
  crypto.createHash('sha256').update(token).digest('hex');

module.exports = {
  signAccessToken,
  signRefreshToken,
  verifyAccessToken,
  verifyRefreshToken,
  hashToken,
};
