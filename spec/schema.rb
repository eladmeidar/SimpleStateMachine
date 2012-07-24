ActiveRecord::Schema.define(:version => 0) do

  %w{gates readers writers transients simples simple_new_dsls thieves localizer_test_models}.each do |table_name|
    create_table table_name, :force => true do |t|
      t.string "status"
      t.string "better_status"
    end
  end
end
