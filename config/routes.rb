JobTest5::Application.routes.draw do
  root "main#index"
  get "main/search" => "main#search", as: :search
end
