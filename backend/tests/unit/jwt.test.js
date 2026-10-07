const jwt = require('jsonwebtoken');
const { generateToken, verifyToken } = require('../../src/utils/jwt');
const config = require('../../src/config');

describe('JWT Utility', () => {
  const payload = { userId: 1 };

  it('Should generate a valid token with payload', () => {
    const token = generateToken(payload);
    expect(typeof token).toBe('string');
    const decoded = verifyToken(token);
    expect(decoded.userId).toBe(payload.userId);
  });

  it('Should verify a valid token and return payload', () => {
    const token = jwt.sign(payload, config.jwtSecret || 'test-secret', { expiresIn: config.jwtExpiresIn || '1h' });
    const decoded = verifyToken(token);
    expect(decoded.userId).toBe(1);
  });

  it('Should throw on invalid token', () => {
    expect(() => verifyToken('invalid-token')).toThrow();
  });

  it('Should throw on expired token', async () => {
    const token = jwt.sign(payload, config.jwtSecret || 'test-secret', { expiresIn: '1ms' });
    
    // Wait for 2ms to ensure token is expired
    await new Promise(resolve => setTimeout(resolve, 2));
    
    expect(() => verifyToken(token)).toThrow();
  });

  it('Token should contain userId in payload', () => {
    const token = generateToken(payload);
    const decoded = verifyToken(token);
    expect(decoded).toHaveProperty('userId', payload.userId);
  });
});
