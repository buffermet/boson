require 'colorize'
require 'active_support/key_generator'
require 'active_support/message_encryptor'
require 'active_support/message_verifier'

CWDIR = File.dirname( File.expand_path(__FILE__) )

puts "Get lost or found?".yellow + " lost" + "/".yellow + "found"
@answer = gets.chomp
puts "Wrong answer.".yellow unless @answer == "lost" || @answer == "found"
exit unless @answer == "lost" || @answer == "found"

puts "Load particle:".yellow
@file = gets.chomp

puts "Load pattern:".yellow
@key = gets.chomp
@salt = 'Ej\xC2\xD4\x9E>)\xD9\'\x81\xE4\xB0\x04\x00\x931\xE8\xAC\x92V\xAF\xC0\x95.U\xEBq\xC8+R\x9D\xAC\xA8\xCD\xD7\'\xAD\xA3b\xD8\x931\xE1\x97\xFD\xE3\xB4M\x8F\xBC6_.\xD3X\xAAc\xC1%\xF4\x1Dg7\xAA'
@cryptkey = ActiveSupport::KeyGenerator.new(@key).generate_key(@salt, 32)
@crypt = ActiveSupport::MessageEncryptor.new(@cryptkey)

def encrypt(data)
	return @crypt.encrypt_and_sign(data)
end

def decrypt(data)
	return @crypt.decrypt_and_verify(data)
end

if @answer == "lost"
	puts "Encrypting...".yellow

	File.write("#{CWDIR}/encrypted-#{@file}", "")

	timer_start = Time.now

	File.open("#{CWDIR}/encrypted-#{@file}", "r+") do |writefile|
		File.open("#{CWDIR}/#{@file}", "r") do |readfile|
			readfile.each do |line|
				writefile.puts encrypt(line)
			end
			readfile.close
			writefile.close
		end
	end
elsif @answer == "found"
	puts "Decrypting...".yellow

	File.write("#{CWDIR}/decrypted-#{@file}", "")

	timer_start = Time.now

	File.open("#{CWDIR}/decrypted-#{@file}", "r+") do |writefile|
		File.open("#{CWDIR}/#{@file}", "r") do |readfile|
			readfile.each do |line|
				writefile.puts decrypt(line.chomp)
			end
			readfile.close
			writefile.close
		end
	end
end

timer_finish = Time.now

duration = timer_finish - timer_start
readable_duration = "#{duration} seconds" if duration < 60
readable_duration = "#{duration/60} minutes" if duration > 60
readable_duration = "#{duration/3600} hours" if duration > 3600
readable_duration = "#{duration/86400} days" if duration > 86400
readable_duration = "time to get a new computer" if duration > 604800

transfer_speed =  "#{( File.size("#{CWDIR}/#{@file}") / 1000 )/duration} KB/s"

puts "Done. Time to wake up.".yellow + " (#{readable_duration} - #{transfer_speed})" if @answer == "lost"
puts "Done. Time to go to bed.".yellow + " (#{readable_duration} - #{transfer_speed})" if @answer == "found"
