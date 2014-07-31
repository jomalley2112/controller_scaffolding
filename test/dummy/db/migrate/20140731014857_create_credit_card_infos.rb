class CreateCreditCardInfos < ActiveRecord::Migration
  def change
    create_table :credit_card_infos do |t|
      t.string :cardholder
      t.date :exp_date
      t.string :secret_code

      t.timestamps
    end
  end
end
