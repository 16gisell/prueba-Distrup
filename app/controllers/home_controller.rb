class HomeController < ApplicationController

  append_view_path "#{Rails.root}/app/views"
  require 'csv'
  require 'rest-client'

  def index
    if session[:formulario_monto] === nil
      inicial(500)
    else
      @data = session[:formulario_monto]
      @active_input = session[:input_activo]
      @active_input_file = session[:input_activo_file]
      @bsi = session[:bsi]
      @tabla = session[:array_tabla]
    end 
  end

  def inicial(monto) 
    data_estatic = [
      {
        moneda: "Bitcoin",
        interes_mensual: 5,
        balance_inicial: (monto).to_f
      },
      {
        moneda: "Ether",
        interes_mensual: 4.2,
        balance_inicial: (monto).to_f
      },
      {
        moneda: "Cardano",
        interes_mensual: 1,
        balance_inicial: (monto).to_f
      },     
    ]
    calcular_inversion(data_estatic)
  end

  def data_input
    data_estatic = [
      {
        moneda: "Bitcoin",
        interes_mensual: 5,
        balance_inicial: (params[:monto]).to_f
      },
      {
        moneda: "Ether",
        interes_mensual: 4.2,
        balance_inicial: (params[:monto]).to_f
      },
      {
        moneda: "Cardano",
        interes_mensual: 1,
        balance_inicial: (params[:monto]).to_f
      },      
    ]

    calcular_inversion(data_estatic)
  end

  def boton_input
    session[:input_activo] = 1
    session[:input_activo_file] = 0
    @active_input_file
    puts "holaaaa"
    redirect_to root_path
  end

  def boton_file
    session[:input_activo] = 0
    session[:input_activo_file] = 1
    redirect_to root_path
  end

  def descargar_csv
    @info=session[:formulario_monto]
    @active_input = session[:input_activo]
    respond_to do |format|
      format.json { render json: @info.to_json }
      format.xml { render xml: @info.to_xml }
      format.csv do
        response.headers['Content-Type'] = 'text/csv'
        response.headers['Content-Disposition'] = "attachment; filename=report-#{@active_input}.csv" 
        render csv: @info.to_json,  template: "csv/report"
      end
    end
  end


  def descargar_json
    @info=session[:formulario_monto]
    @active_input = session[:input_activo]
    respond_to do |format|
      # format.json { render json: @info.to_json }
      format.xml { render xml: @info.to_xml }
      format.json do
        response.headers['Content-Type'] = 'text/json'
        response.headers['Content-Disposition'] = "attachment; filename=report-#{@active_input}.json" 
        render json: @info.to_json,  template: "csv/report"
      end
    end
  end

  def importar_csv
    file_path = File.read(params[:file])
    cc= CSV.parse(file_path, headers: true)
    if cc[0].length === 3
    
      data=[]

      cc.each do |row|
        data.push({
          moneda: row["Moneda"],
          interes_mensual: row["Interes_mensual"],
          balance_inicial: row["balance_ini"]
        })
        # debugger
      end
      calcular_inversion(data)

    else
      redirect_to root_path, alert: "Error de documento, verifique la data los headers deben ser: Moneda, Interes_mensual, balance_ini (solo tres columnas) "
    end
  end

  def calcular_inversion(data_estatic)
    # reset_session
    # session.delete(:formulario_monto)
    session[:formulario_monto] =[]
    array_static = []
    array_tabla = []

    data_estatic.each do |d|
      case d[:moneda]
      when 'Bitcoin'
        puts "hola 1"
          response = soporte('BTC')
          montoResponse = response["rate"]
          array_tabla.push(response)
          
          puts montoResponse
      when 'Ether'
        puts "hola 2"
        response = soporte('ETH')
        montoResponse = response["rate"]
        array_tabla.push(response)
      when 'Cardano'
        puts "hola 3"
        response = soporte('ADA')
        montoResponse = response["rate"]
        array_tabla.push(response)
      else
        "Error en datos para calcular"
      end

        moneda= d[:moneda], #nombre de moneda  - dato
        montoInicial= d[:balance_inicial].to_f, #monto inicial  - dato
        porcentajeMensual=  d[:interes_mensual].to_f, #interes mensual - dato 

        porcentajeAnual= (porcentajeMensual/100)*12*100, # calculamos el porcentaje anual - calculo
        gananciaUSD= (porcentajeAnual/100)*montoInicial, # calculamos monto inicial por el porcentaje anual  obtenemos estimacion anual  - calculo
        estimacion= montoResponse*gananciaUSD, # multiplicamos ganancia anual por balance de moneda - calculo 
        response_monto = montoResponse #monto arrijado por la aplicacion segun el caso - dato        

      array_static.push(
        {
          moneda: d[:moneda],
          montoInicial: montoInicial,
          response_monto: response_monto,
          porcentajeMensual:porcentajeMensual,
          porcentajeAnual: porcentajeAnual,
          gananciaUSD: gananciaUSD,
          estimacion: estimacion,
        }
      )
    end
    # debugger
    session[:formulario_monto] = array_static
    session[:array_tabla] = array_tabla
    
    session[:input_activo] = 0
    session[:input_activo_file] = 0

    redirect_to root_path, alert: "Error de api, los datos retornados estaran a destiempo. Para valoracion de prueba se utilizara datos de soporte"
  end

  def coinApi(moneda) 
   response = RestClient.get("https://rest.coinapi.io/v1/exchangerate/#{moneda}/USD", 
    headers={
        'Accept' => "application/json",
        'Content-Type' =>"application/json",
        'X-CoinAPI-Key'=> "314EF134-05AC-4168-A3B6-FA46FB95BDFB"
    })
    rescue RestClient::TooManyRequests => e
      sleep(60)
      retry
    # end

    puts response.code
    return JSON.parse(response)
    # debugger
    # if response.code === 200
    #   return JSON.parse(response)
    # else      
    #   # session[:formulario_monto] = array_static
    #   redirect_to root_path, alert: "Error de api, los datos retornados estaran a destiempo"
    # end
    # session[:bsi] = json
  end

  def soporte(moneda)
    case moneda
    when 'BTC'
      response ={
        "time"=>"2024-02-02T03:40:25.0000000Z",
        "asset_id_base"=>"BTC",
        "asset_id_quote"=>"USD",
        "rate"=>43021.32
      }
      return response
    when 'ETH'
      response ={
        "time"=>"2024-02-02T03:40:25.0000000Z",
        "asset_id_base"=>"ETH",
        "asset_id_quote"=>"USD",
        "rate"=>2300.53
      }
      return response
    when 'ADA'
      response ={
        "time"=>"2024-02-02T03:40:25.0000000Z",
        "asset_id_base"=>"ADA",
        "asset_id_quote"=>"USD",
        "rate"=>0.51
      }
      return response
    else
      "Error en datos para calcular"
    end
  end

  # def coinApi_info_completa(moneda) 
  #   response = RestClient.get("https://rest.coinapi.io/v1/assets/#{moneda}", 
  #    headers={
  #        'Accept' => "application/json",
  #        'Content-Type' =>"application/json",
  #        'X-CoinAPI-Key'=> "1C25E9E3-33FB-40BD-8858-CF9459BE1C7A"
  #    })
  #    return JSON.parse(response)
  #    # session[:bsi] = json
  #  end


  private
end
