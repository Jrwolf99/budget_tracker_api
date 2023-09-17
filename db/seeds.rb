categories = {
  "groceries_food": {
    "name": 'Groceries',
    "is_standard_expense": true,
    "is_needed": true
  },
  "needed_goods": {
    "name": 'Needed Goods',
    "is_standard_expense": true,
    "is_needed": true
  },
  "insurance": {
    "name": 'Insurance',
    "is_standard_expense": true,
    "is_needed": true
  },
  "gas_and_car": {
    "name": 'Gas and Car',
    "is_standard_expense": true,
    "is_needed": true
  },
  "rent": {
    "name": 'Rent',
    "is_standard_expense": true,
    "is_needed": true
  },
  "utilities": {
    "name": 'Utilities',
    "is_standard_expense": true,
    "is_needed": true
  },
  "other_food": {
    "name": 'Other Food (Restaurants, etc.)',
    "is_standard_expense": true,
    "is_needed": false
  },
  "wanted_goods": {
    "name": 'Wanted Goods',
    "is_standard_expense": true,
    "is_needed": false
  },
  "gift": {
    "name": 'Gift',
    "is_standard_expense": true,
    "is_needed": false
  },
  "subscriptions": {
    "name": 'Subscriptions',
    "is_standard_expense": true,
    "is_needed": false
  },
  "fun_activities": {
    "name": 'Fun Activities',
    "is_standard_expense": true,
    "is_needed": false
  },
  "refunds": {
    "name": 'Refunds',
    "is_standard_expense": false,
    "is_needed": nil
  },
  "income": {
    "name": 'Income',
    "is_standard_expense": false,
    "is_needed": nil
  },
  "credit_card_payments": {
    "name": 'Credit Card Payments',
    "is_standard_expense": false,
    "is_needed": nil
  },
  "other_transfers": {
    "name": 'Other Transfers',
    "is_standard_expense": false,
    "is_needed": nil
  }
}

categories.each do |identifier, category_hash|
  next if SpendCategory.find_by(identifier: identifier.to_s)

  category = SpendCategory.new(category_hash)
  category.identifier = identifier.to_s
  category.save!
end
