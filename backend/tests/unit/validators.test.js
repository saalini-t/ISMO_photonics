const { registerSchema, loginSchema } = require('../../src/validators/authValidator');

describe('Auth Validators', () => {
  describe('registerSchema', () => {
    it('should pass with valid data', () => {
      const data = { fullName: 'John Doe', email: 'john@example.com', password: 'password123' };
      const result = registerSchema.safeParse(data);
      expect(result.success).toBe(true);
    });

    it('should fail without fullName', () => {
      const data = { email: 'john@example.com', password: 'password123' };
      const result = registerSchema.safeParse(data);
      expect(result.success).toBe(false);
    });

    it('should fail with invalid email', () => {
      const data = { fullName: 'John Doe', email: 'invalid-email', password: 'password123' };
      const result = registerSchema.safeParse(data);
      expect(result.success).toBe(false);
    });

    it('should fail with short password (< 8 chars)', () => {
      const data = { fullName: 'John Doe', email: 'john@example.com', password: 'short' };
      const result = registerSchema.safeParse(data);
      expect(result.success).toBe(false);
    });

    it('should trim and lowercase email', () => {
      const data = { fullName: 'John Doe', email: ' JOHN@EXAMPLE.COM ', password: 'password123' };
      const result = registerSchema.parse(data);
      expect(result.email).toBe('john@example.com');
    });
  });

  describe('loginSchema', () => {
    it('should pass with valid data', () => {
      const data = { email: 'john@example.com', password: 'password123' };
      const result = loginSchema.safeParse(data);
      expect(result.success).toBe(true);
    });

    it('should fail without email', () => {
      const data = { password: 'password123' };
      const result = loginSchema.safeParse(data);
      expect(result.success).toBe(false);
    });

    it('should fail without password', () => {
      const data = { email: 'john@example.com' };
      const result = loginSchema.safeParse(data);
      expect(result.success).toBe(false);
    });
  });
});
