Rails.application.routes.draw do

  root "home#index"
  # get '/' to: 'home#index'
  post 'data_input', to: 'home#data_input'
  post 'boton_input', to: 'home#boton_input'
  post 'boton_file', to: 'home#boton_file'
  get  'descargar_csv',  to: 'home#descargar_csv'
  get  'descargar_json', to: 'home#descargar_json'
  post 'importar_csv', to: 'home#importar_csv'

end

