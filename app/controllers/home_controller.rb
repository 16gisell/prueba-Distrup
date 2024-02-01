class HomeController < ApplicationController

  append_view_path "#{Rails.root}/app/views"
  require 'csv'

  def index
    @data = session[:formulario_monto]
    @active_input = session[:input_activo]
  end

  def save_data
    data_estatic = [
      {
        moneda: "Binance",
        interes_mensual: row["Interes_mensual"],
        balance_inicial: (params[:monto]).to_f
      },
      {
        moneda: "Ether",
        interes_mensual: row["Interes_mensual"],
        balance_inicial: (params[:monto]).to_f
      },
      {
        moneda: "Cardano",
        interes_mensual: row["Interes_mensual"],
        balance_inicial: (params[:monto]).to_f
      },
      
    ]

    Array_static =[]

    data_estatic.each do |d|

    end
    
    monto = (params[:monto]).to_f

    porcentajeMensual_B = 5.to_f
    porcentajeAnual_B = (porcentajeMensual_B/100)*12*100
    gananciaUSD_B = porcentajeAnual_B*monto
    gananciaBinance = 1523*gananciaUSD_B

    porcentajeMensual_E = 4.2 
    porcentajeAnual_E = (porcentajeMensual_E/100)*12*100
    gananciaUSD_E = porcentajeAnual_E*monto
    gananciaETher = gananciaUSD_E * 520


    porcentajeMensual_C = 1.to_f
    porcentajeAnual_C = (porcentajeMensual_C/100)*12*100
    gananciaUSD_C = porcentajeAnual_C*monto
    gananciaCandaun = gananciaUSD_C * 100

    session[:formulario_monto]= {
      monto: monto,
      binance:{
        porcentajeMensual_B: porcentajeMensual_B,
        porcentajeAnual_B: porcentajeAnual_B,
        gananciaUSD_B: gananciaUSD_B,
        gananciaBinance:gananciaBinance
      }, 
      ether:{
        porcentajeMensual_E: porcentajeMensual_E,
        porcentajeAnual_E: porcentajeAnual_E,
        gananciaUSD_E: gananciaUSD_E,
        gananciaETher: gananciaETher
      }, 
      candaum:{
        porcentajeMensual_C: porcentajeMensual_C,
        porcentajeAnual_C: porcentajeAnual_C,
        gananciaUSD_C: gananciaUSD_C,
        gananciaCandaun: gananciaCandaun
      }
    }
    @data = monto
    redirect_to home_index_path
  end

  def calcular_inversion
    session[:input_activo] = 1
    puts "holaaaa"
    redirect_to home_index_path
  end

  def promedio_csv
    session[:input_activo] = 0
    redirect_to home_index_path
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

  def importar_csv
    file_path = File.read(params[:file])
    cc= CSV.parse(file_path, headers: true)
    
    puts params[:file]
    puts cc
    session[:input_activo] = 0
    data=[]
    cc.each do |row|
      # Data.create!(row.to_hash)
      puts row
      
      data.push({
        moneda: row["Moneda"],
        interes_mensual: row["Interes_mensual"],
        balance_inicial: row["balance_ini"]
      })
      # debugger
    end
    puts data
    redirect_to home_index_path, notice: "Datos importados correctamente"
  end


  private
end
