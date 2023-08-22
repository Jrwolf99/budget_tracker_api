categories = {
  "food": "Food",
  "goods": "Goods",
  "insurance": "Insurance",
  "gas_and_car": "Gas and Car",
  "gift": "Gift",
  "subscriptions": "Subscriptions",
  "refunds": "Refunds",
  "rent": "Rent",
  "utilities": "Utilities",
  "income": "Income",
  "transfers": "Transfers",
  "fun_activities": "Fun Activities"
}
  categories.each do |key, value|
    Category.create(category_name: value, identifier: key)
  end
