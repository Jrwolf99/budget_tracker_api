# frozen_string_literal: true

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
  category = SpendCategory.find_or_initialize_by(identifier: identifier.to_s)
  category.assign_attributes(category_hash)
  category.save! if category.changed?
end

guest_email = ENV.fetch('GUEST_EMAIL', 'jrwolf99+guest@outlook.com')
guest_password = ENV.fetch('GUEST_PASSWORD', 'guest-password-123')

guest_user = User.find_or_initialize_by(email: guest_email)
guest_user.password = guest_password if guest_user.password_digest.blank?
guest_user.verified = true
guest_user.save!

guest_spend_account = SpendAccount.find_or_create_by!(user: guest_user)

today = Date.current
this_month = today.month
this_year = today.year
last_month_date = today.prev_month

def ensure_goal!(spend_account:, spend_category_identifier:, month:, year:, target_value:)
  category = SpendCategory.find_by!(identifier: spend_category_identifier)
  goal = spend_account.goals.find_or_initialize_by(
    month:,
    year:,
    spend_category_id: category.id
  )
  goal.target_value = target_value
  goal.save!
end

ensure_goal!(spend_account: guest_spend_account, spend_category_identifier: 'rent', month: this_month, year: this_year, target_value: 1800)
ensure_goal!(spend_account: guest_spend_account, spend_category_identifier: 'utilities', month: this_month, year: this_year, target_value: 250)
ensure_goal!(spend_account: guest_spend_account, spend_category_identifier: 'groceries_food', month: this_month, year: this_year, target_value: 500)
ensure_goal!(spend_account: guest_spend_account, spend_category_identifier: 'gas_and_car', month: this_month, year: this_year, target_value: 180)
ensure_goal!(spend_account: guest_spend_account, spend_category_identifier: 'other_food', month: this_month, year: this_year, target_value: 220)
ensure_goal!(spend_account: guest_spend_account, spend_category_identifier: 'fun_activities', month: this_month, year: this_year, target_value: 160)

seed_spends = [
  {
    import_combo_identifier: "seed:guest:#{today.strftime('%Y-%m')}:paycheck",
    date_of_spend: Date.new(this_year, this_month, 1),
    amount: 4200,
    description: 'Paycheck',
    spend_category_identifier: 'income',
    notes: nil,
    last_four: '1234'
  },
  {
    import_combo_identifier: "seed:guest:#{today.strftime('%Y-%m')}:rent",
    date_of_spend: Date.new(this_year, this_month, 2),
    amount: -1750,
    description: 'Rent',
    spend_category_identifier: 'rent',
    notes: nil,
    last_four: '1234'
  },
  {
    import_combo_identifier: "seed:guest:#{today.strftime('%Y-%m')}:electric",
    date_of_spend: Date.new(this_year, this_month, 5),
    amount: -118.42,
    description: 'Electric bill',
    spend_category_identifier: 'utilities',
    notes: nil,
    last_four: '1234'
  },
  {
    import_combo_identifier: "seed:guest:#{today.strftime('%Y-%m')}:grocery",
    date_of_spend: Date.new(this_year, this_month, 6),
    amount: -86.73,
    description: 'Grocery store',
    spend_category_identifier: 'groceries_food',
    notes: nil,
    last_four: '1234'
  },
  {
    import_combo_identifier: "seed:guest:#{today.strftime('%Y-%m')}:gas",
    date_of_spend: Date.new(this_year, this_month, 7),
    amount: -52.19,
    description: 'Gas station',
    spend_category_identifier: 'gas_and_car',
    notes: nil,
    last_four: '1234'
  },
  {
    import_combo_identifier: "seed:guest:#{today.strftime('%Y-%m')}:coffee",
    date_of_spend: Date.new(this_year, this_month, 8),
    amount: -6.25,
    description: 'Coffee',
    spend_category_identifier: 'other_food',
    notes: nil,
    last_four: '1234'
  },
  {
    import_combo_identifier: "seed:guest:#{today.strftime('%Y-%m')}:movie",
    date_of_spend: Date.new(this_year, this_month, 10),
    amount: -28.00,
    description: 'Movie tickets',
    spend_category_identifier: 'fun_activities',
    notes: nil,
    last_four: '1234'
  },
  {
    import_combo_identifier: "seed:guest:#{today.strftime('%Y-%m')}:uncat",
    date_of_spend: Date.new(this_year, this_month, 11),
    amount: -19.99,
    description: 'Online purchase',
    spend_category_identifier: nil,
    notes: nil,
    last_four: '1234'
  },
  {
    import_combo_identifier: "seed:guest:#{last_month_date.strftime('%Y-%m')}:paycheck",
    date_of_spend: Date.new(last_month_date.year, last_month_date.month, 1),
    amount: 4200,
    description: 'Paycheck',
    spend_category_identifier: 'income',
    notes: nil,
    last_four: '1234'
  },
  {
    import_combo_identifier: "seed:guest:#{last_month_date.strftime('%Y-%m')}:groceries",
    date_of_spend: Date.new(last_month_date.year, last_month_date.month, 12),
    amount: -132.58,
    description: 'Groceries',
    spend_category_identifier: 'groceries_food',
    notes: nil,
    last_four: '1234'
  },
  {
    import_combo_identifier: "seed:guest:#{last_month_date.strftime('%Y-%m')}:refund",
    date_of_spend: Date.new(last_month_date.year, last_month_date.month, 15),
    amount: 24.50,
    description: 'Refund',
    spend_category_identifier: 'refunds',
    notes: nil,
    last_four: '1234'
  }
]

seed_spends.each do |attrs|
  category_id =
    if attrs[:spend_category_identifier].present?
      SpendCategory.find_by!(identifier: attrs[:spend_category_identifier]).id
    end

  spend = guest_spend_account.spends.find_or_initialize_by(import_combo_identifier: attrs[:import_combo_identifier])
  spend.assign_attributes(
    date_of_spend: attrs[:date_of_spend],
    amount: attrs[:amount],
    description: attrs[:description],
    notes: attrs[:notes],
    last_four: attrs[:last_four],
    spend_category_id: category_id
  )
  spend.save! if spend.changed?
end
