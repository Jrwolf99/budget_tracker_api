
Spend.all.each do |spend|
    spend.update!(import_combo_identifier: "#{spend.date_of_spend} #{spend.amount} #{spend.description}")
end