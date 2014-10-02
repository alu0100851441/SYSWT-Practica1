# -*- coding: utf-8 -*-
require 'twitter'
require 'rack'
#require 'pry-debugger'
require 'thin'
require 'erb'

class Twitts

  require './configure'

	#Inicializar variables
	def initialize
		@amigos = []
		@name = ''
		@number = 0
                		
	end

	#Acceso al HTML para mostrar los resultados
	def erb(template)
  		template_file = File.open("pop.html.erb", 'r')
  		ERB.new(File.read(template_file)).result(binding)
	end
	
	#Método call
	def call env
	    req = Rack::Request.new(env)
	    client = my_twitter_client() 
	    binding.pry if ARGV[0]
	   
	   #Si no esta vacio , no es un espacio y el usuario existe en Twitter el nombre es el introducido
	    @name = (req["firstname"] && req["firstname"] != '' && client.user?(req["firstname"]) == true ) ? req["firstname"] : ''

		@number = (req["n"] && req["n"].to_i>1 ) ? req["n"].to_i : 1
		#puts "#{req["n"]}"
		
		#Si el nombre existe buscamos sus últimos Tweets
		if @name == req["firstname"]
			#puts "#{@todo_tweet}"
			ultimos_t = client.friends(@name,{}).take(10)
			@amigos = ultimos_t.map { |i| [i.name, i.followers_count]}.sort_by { |x, y| -y }			
		end

		#Invoca a erb
		Rack::Response.new(erb('pop.html.erb'))
	end

end

if $0 == __FILE__
	Rack::Server.start(
# 		:app => Rack::ShowExceptions.new(
#        	Rack::Lint.new(
#           	Rack::Twitts.new)), 
            :app => Twitts.new,
	    :Port => 4567,
	    :server => 'thin'
  	)
end
