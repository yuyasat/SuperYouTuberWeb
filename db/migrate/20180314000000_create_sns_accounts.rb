class CreateSnsAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :sns_accounts do |t|
      t.string :type, null: false
      t.references :video_artist, null: false
      t.string :account, null: false

      t.timestamps null: false
    end
  end
end
