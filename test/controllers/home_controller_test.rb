require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "Validamos ruta index" do
    get root_url
    assert_response :success
  end

  test "Ruta index sin data inicial " do
    get root_url, params: {formulario_monto: nil}
    assert_response :success
  end

  test "ruta index data en formulario " do
    get root_url, params: {formulario_monto: { 
      moneda: 'BTC',
      montoInicial: 500,
      response_monto: 45.678,
      porcentajeMensual:5,
      porcentajeAnual: 60,
      gananciaUSD: 300,
      estimacion: 13703400}
    }
  end

  test "validamos si metodo input recibe los datos adecuados" do
    post data_input_path, params: { data_estatic:[
      {
        moneda: "Bitcoin",
        interes_mensual: 5,
        balance_inicial: 250.0
      },
      {
        moneda: "Ether",
        interes_mensual: 4.2,
        balance_inicial: 250.0
      },
      {
        moneda: "Cardano",
        interes_mensual: 1,
        balance_inicial: 250.0
      }
    ] }
    assert_response :redirect
    follow_redirect!
    assert_response :success
  end

  test "validamos accion boton" do
    post boton_input_path, params: {input_activo: 1, input_activo_file:0}
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_selector "input" 
  end

  test "validamos accion boton file" do
    post boton_file_path, params: {input_activo: 0, input_activo_file:1}
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_selector "file" 
  end

  test "validamos accion descarga cvs" do #verificar porque genera el error
    get descargar_csv_path, params: {formulario_monto: { 
      moneda: 'BTC',
      montoInicial: 500,
      response_monto: 45.678,
      porcentajeMensual:5,
      porcentajeAnual: 60,
      gananciaUSD: 300,
      estimacion: 13703400}
    }
    assert_response :success
    assert_equal response.content_type, 'text/csv'
  end

  test "validamos accion descarga json" do #verificar porque genera el error 
    get descargar_json_path
     params: {formulario_monto: { 
      moneda: 'BTC',
      montoInicial: 500,
      response_monto: 45.678,
      porcentajeMensual:5,
      porcentajeAnual: 60,
      gananciaUSD: 300,
      estimacion: 13703400}
    }
    assert_response :success
    assert_equal response.content_type, 'text/json'
  end
  

end
