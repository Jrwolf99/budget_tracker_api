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
  end
  