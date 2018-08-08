class CreateMemos < ActiveRecord::Migration[5.1]
  def change
    create_table :memos do |t|
      t.references :target, polymorphic: true, index: true
      t.text :content, null: false

      t.timestamps
    end
  end
end
