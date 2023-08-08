categories = [
    "Goods",
    "Insurance",
    "Gas",
    "Savings",
    "Gift",
    "Subscriptions",
    "Refunds",
    "Rent",
    "Utilities",
    "Transfers"
  ]
  
  categories.each do |category_name|
    Category.create(category_name: category_name)
    # todo: add an identifier here
  end

  



  # What are these numbers multiplied by 12 each?
  # 118.59
  # 1029.39
  #175.52
  # 569.25
  # 213.47
  # 332.06
  # 118.59
  # 479.12

  # totals are
  # 118.59 * 12 = 1423.08 for subscriptions
  # 1029.39 * 12 = 12352.68 for rent
  # 175.52 * 12 = 2106.24 for utilities
  # 569.25 * 12 = 6831 for food
  # 213.47 * 12 = 2561.64 for goods
  # 332.06 * 12 = 3984.72 for gas and car
  # 118.59 * 12 = 1423.08 for gifts
  # 479.12 * 12 = 5749.44 for insurance


