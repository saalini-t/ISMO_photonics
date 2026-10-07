const { paginate, formatPaginatedResponse } = require('../../src/utils/pagination');

describe('Pagination Utils', () => {
  describe('paginate', () => {
    it('should return default skip and take if no arguments are provided', () => {
      const result = paginate();
      expect(result).toEqual({
        skip: 0,
        take: 10,
        page: 1,
        limit: 10
      });
    });

    it('should parse string arguments to numbers', () => {
      const result = paginate('2', '20');
      expect(result).toEqual({
        skip: 20,
        take: 20,
        page: 2,
        limit: 20
      });
    });

    it('should fall back to defaults if zero or negative arguments are provided', () => {
      const result = paginate(0, -5);
      expect(result).toEqual({
        skip: 0,
        take: 10,
        page: 1,
        limit: 10
      });
    });
  });

  describe('formatPaginatedResponse', () => {
    it('should format correctly with items, totalCount, page, and limit', () => {
      const items = [{ id: 1 }, { id: 2 }];
      const result = formatPaginatedResponse(items, 5, 1, 2);
      expect(result).toEqual({
        data: items,
        pagination: {
          page: 1,
          limit: 2,
          totalCount: 5,
          totalPages: 3
        }
      });
    });

    it('should handle zero totalCount with totalPages defaulting to 1', () => {
      const items = [];
      const result = formatPaginatedResponse(items, 0, 1, 10);
      expect(result).toEqual({
        data: items,
        pagination: {
          page: 1,
          limit: 10,
          totalCount: 0,
          totalPages: 1
        }
      });
    });
  });
});
