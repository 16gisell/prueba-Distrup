Rails.application.routes.draw do
  get 'home/index'
  post 'save_data', to: 'home#save_data'
  post 'calcular_inversion', to: 'home#calcular_inversion'
  post 'promedio_csv', to: 'home#promedio_csv'
  get  'descargar_csv',  to: 'home#descargar_csv'
  post 'importar_csv', to: 'home#importar_csv'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
