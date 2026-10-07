const jwtUtils = require('../utils/jwt');
const ApiError = require('../utils/ApiError');
const prisma = require('../utils/prisma');

const authenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw ApiError.unauthorized('Authentication required');
    }

    const token = authHeader.split(' ')[1];
    const decoded = jwtUtils.verifyToken(token);

    const user = await prisma.user.findUnique({
      where: { id: decoded.userId }
    });

    if (!user) {
      throw ApiError.unauthorized('User not found');
    }

    const { password, ...userWithoutPassword } = user;
    req.user = userWithoutPassword;

    next();
  } catch (error) {
    next(error);
  }
};

authenticate.authenticate = authenticate;
module.exports = authenticate;
