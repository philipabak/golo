class Admin::UsersController < AdminController
  active_scaffold :user do |config|
    list = [:login, :enabled, :email, :created_at, :updated_at, :address, :state, :postal_code, :on_mailing_list, :old_email, :username, :driver_count, :overall_weekly_mileage, :initial_weekly_mileage, :initial_annual_mileage, :baseline_percentage, :miles_reduced_total, :account_time]
    config.list.columns = list
    config.show.columns = list
    config.update.columns = list
    config.create.columns = list
    config.columns[:enabled].form_ui = :checkbox
    config.columns[:enabled].inplace_edit = true

    config.nested.add_link "Vehicles", [:vehicles]
  end
end
