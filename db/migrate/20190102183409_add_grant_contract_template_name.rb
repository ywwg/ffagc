class AddGrantContractTemplateName < ActiveRecord::Migration
  def change
    add_column :grants, :contract_template, :string
  end
end
