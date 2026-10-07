const paginate = (page = 1, limit = 10) => {
  const parsedPage = parseInt(page, 10) > 0 ? parseInt(page, 10) : 1;
  const parsedLimit = parseInt(limit, 10) > 0 ? parseInt(limit, 10) : 10;
  
  const skip = (parsedPage - 1) * parsedLimit;
  
  return {
    skip,
    take: parsedLimit,
    page: parsedPage,
    limit: parsedLimit
  };
};

const formatPaginatedResponse = (items, totalCount, page, limit) => {
  return {
    data: items,
    pagination: {
      page: page,
      limit: limit,
      totalCount: totalCount,
      totalPages: Math.ceil(totalCount / limit) || 1
    }
  };
};

module.exports = {
  paginate,
  formatPaginatedResponse
};
