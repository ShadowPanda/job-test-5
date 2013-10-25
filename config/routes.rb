JobTest5::Application.routes.draw do
  root "main#index"
  get "/search" => "main#search", as: :search
end
