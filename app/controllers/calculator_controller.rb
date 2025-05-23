class CalculatorController < ApplicationController
  protect_from_forgery with: :null_session
  
  def index
  end

  def calculate
    expression = params[:expression]
    numbers = expression.scan(/\d+\.?\d*/).map(&:to_f)
    operator = expression.scan(/[\+\-\*\/]/).first

    result = case operator
    when '+'
      numbers[0] + numbers[1]
    when '-'
      numbers[0] - numbers[1]
    when '*'
      numbers[0] * numbers[1]
    when '/'
      numbers[1] != 0 ? numbers[0] / numbers[1] : 'Erro: Divisão por zero'
    else
      'Erro: Operação inválida'
    end

    render json: { result: result }
  rescue => e
    render json: { result: 'Erro' }
  end
end 