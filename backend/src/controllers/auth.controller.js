const bcrypt = require('bcryptjs');
const User = require('../models/User');
const Session = require('../models/Session');
const ApiError = require('../utils/ApiError');
const {
  signAccessToken,
  signRefreshToken,
  verifyRefreshToken,
  hashToken,
} = require('../utils/token');

const buildAuthResponse = async (user) => {
  const accessToken = signAccessToken(user._id.toString());
  const refreshToken = signRefreshToken(user._id.toString());
  const expiresAt = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);

  await Session.create({
    user_id: user._id,
    refresh_token: hashToken(refreshToken),
    expires_at: expiresAt,
  });

  return {
    accessToken,
    refreshToken,
    user: user.toPublicJSON(),
  };
};

const register = async (req, res, next) => {
  try {
    const { name, email, password } = req.body;
    const existing = await User.findOne({ email: email.toLowerCase() });
    if (existing) {
      throw new ApiError(409, 'Email already registered');
    }

    const password_hash = await bcrypt.hash(password, 10);
    const user = await User.create({ name, email, password_hash });
    const auth = await buildAuthResponse(user);
    res.status(201).json({ success: true, ...auth });
  } catch (err) {
    next(err);
  }
};

const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;
    const user = await User.findOne({ email: email.toLowerCase() });
    if (!user) {
      throw new ApiError(401, 'Invalid email or password');
    }

    const valid = await bcrypt.compare(password, user.password_hash);
    if (!valid) {
      throw new ApiError(401, 'Invalid email or password');
    }

    const auth = await buildAuthResponse(user);
    res.json({ success: true, ...auth });
  } catch (err) {
    next(err);
  }
};

const logout = async (req, res, next) => {
  try {
    const { refreshToken } = req.body;
    if (refreshToken) {
      await Session.deleteOne({ refresh_token: hashToken(refreshToken) });
    }
    res.json({ success: true, message: 'Logged out' });
  } catch (err) {
    next(err);
  }
};

const refresh = async (req, res, next) => {
  try {
    const { refreshToken } = req.body;
    if (!refreshToken) {
      throw new ApiError(400, 'Refresh token required');
    }

    const payload = verifyRefreshToken(refreshToken);
    const session = await Session.findOne({
      user_id: payload.sub,
      refresh_token: hashToken(refreshToken),
      expires_at: { $gt: new Date() },
    });

    if (!session) {
      throw new ApiError(401, 'Invalid refresh token');
    }

    const user = await User.findById(payload.sub);
    if (!user) {
      throw new ApiError(401, 'User not found');
    }

    await Session.deleteOne({ _id: session._id });
    const auth = await buildAuthResponse(user);
    res.json({ success: true, ...auth });
  } catch (err) {
    if (err.name === 'JsonWebTokenError') {
      return next(new ApiError(401, 'Invalid refresh token'));
    }
    next(err);
  }
};

module.exports = { register, login, logout, refresh };
