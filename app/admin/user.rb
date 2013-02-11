ActiveAdmin.register User do
  index do
    column :name
    column :login
    column :uid
    column :provider
    column :clue_points
    column :prize_points
    column :updated_at
  end
end                                   
