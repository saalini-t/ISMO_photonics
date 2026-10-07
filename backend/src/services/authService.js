const bcrypt = require('bcryptjs');
const prisma = require('../utils/prisma');
const jwtUtils = require('../utils/jwt');
const ApiError = require('../utils/ApiError');

const register = async ({ fullName, email, password }) => {
  const hashedPassword = await bcrypt.hash(password, 10);
  
  const user = await prisma.user.create({
    data: {
      fullName,
      email,
      password: hashedPassword
    }
  });

  const { password: _, ...userWithoutPassword } = user;
  return userWithoutPassword;
};

const login = async ({ email, password }) => {
  const user = await prisma.user.findUnique({
    where: { email }
  });

  if (!user) {
    throw ApiError.unauthorized('Invalid email or password');
  }

  const isPasswordValid = await bcrypt.compare(password, user.password);
  if (!isPasswordValid) {
    throw ApiError.unauthorized('Invalid email or password');
  }

  const token = jwtUtils.generateToken({ userId: user.id });
  const { password: _, ...userWithoutPassword } = user;

  return {
    user: userWithoutPassword,
    token
  };
};

const getCurrentUser = async (userId) => {
  const user = await prisma.user.findUnique({
    where: { id: userId }
  });

  if (!user) {
    throw ApiError.notFound('User not found');
  }

  const { password: _, ...userWithoutPassword } = user;
  return userWithoutPassword;
};

module.exports = {
  register,
  login,
  getCurrentUser
};
