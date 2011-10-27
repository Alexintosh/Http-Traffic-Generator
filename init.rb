require 'rubygems'
require 'mechanize'
require 'timeout'
require "safariwatir"

class HttpTrafficGenerator

	def initialize
		@agent = Mechanize.new
		@proxy_port = 80
		@userAgent = 'Opera/9.80 (Windows NT 6.1; U; es-ES) Presto/2.9.181 Version/12.00'
	end

	def buildRequest( index, proxy, target, userAgent = @userAgent )

		@agent.user_agent = userAgent
		@agent.set_proxy( proxy, @proxy_port.to_s)
		#puts "Req at: #{Time.now}"
		
		begin
			Timeout.timeout(9) {				
				return @agent.get(target)				  	
			}			
		rescue Timeout::Error
			puts "\nProxy #{proxy} timed out"		
		rescue	
		end


	end

	def loadFile(file)
		# apertura e lettura di un file di testo
		f = File.open(file, 'r') or die "Impossibile leggere il file"
		proxyList = []
		f.each_line { |row| proxyList.push row.gsub(/\n/, "") }

		#puts proxyList.inspect
		return proxyList
				
	end
		
	def checkProxy (proxyList, target)

		puts "\n** Checking availability of proxies **"

		puts "\nInfo : You have loaded #{proxyList.length} proxies\n"

		proxyList.each do |proxy|

			#puts "Testing: #{proxy} \n"
			res = buildRequest( proxy, target )
					
			if !res.respond_to?('links') then
				puts "Warning : Proxy #{proxy} is not available"
				proxyList.delete( proxy )
			end			

		end

		puts "\nInfo : #{proxyList.length} avaibles\n"

		return proxyList

	end
end


#Main
def prima
		
	if ARGV.length < 1 then
		puts 'numero di parametri insufficenti'
		puts "\n Example: ./gen.rb http://example.com 10"
	else
		#Variables
		target = ARGV[0]
		numIteration = ARGV[1].to_i
		
		puts "\n** Targetting #{target} for #{numIteration} requests **"
		proxy_addr = '122.72.2.190'
				
		g = HttpTrafficGenerator.new

		proxyList = g.loadFile( $fileProxy )
		userAgents = g.loadFile( $fileUserAgent )

		puts "\nInfo : You have loaded #{userAgents.length} useragents \n"
		
		avaibleProxiesList = g.checkProxy( proxyList, target )

		puts "\n** Sending requests to target using #{numIteration}  processes **"
		
		numIteration.times { |i|
			#Thread.new{ g.buildRequest( i, avaibleProxiesList[0], target ) }
			g.buildRequest( i, avaibleProxiesList[0], target )
			#puts ( numIteration * (i+1) ).to_s + '%'
			#puts "Req at: #{Time.now}"		
		}			
			
	end	
end

$fileProxy = "list-proxy.txt"
$fileUserAgent = "list-user-agent.txt"
prima()
