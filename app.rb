require 'logger'
require 'slack'
require 'open3'

$logger = Logger.new(STDOUT)

def format_msg(method, text)
	return "[#{method}]\t#{text}"
end

def info(method, text)
	msg = format_msg(method, text)
	$logger.info(msg)
end

def debug(method, text)
	msg = format_msg(method, text)
	$logger.debug(msg)
end

def shell_escape(text)
	return text.gsub(/"/, '\"')
end

def nlc(text)
	debug(__method__, "text=#{text}")
	result = ''
	Open3.popen3("cd /home/ubuntu/workspace/watson; sh moc_brain.sh \"#{shell_escape(text)}\"") do |i, o, e, w|
		i.close
		o.each do |line|
			result += line
		end
	end
	result.sub!(/\n$/, '')
	return result
end

def proc_cmd(text)
	debug(__method__, "text=#{text}")
	msg = ''
	Open3.popen3("sh proc_cmd.sh \"#{shell_escape(text)}\"") do |i, o, e, w|
		i.close
		o.each do |line|
			msg += line
		end
	end
	msg.sub!(/\n$/, '')
	send_msg(msg)
end

TOKEN = 'xoxp-36514911301-36512771616-65733444118-621f0a4c0d'
CHANNEL='G1XLCD3GC' 
USERNAME='Kaz WATSON'

def send_msg(text)
	debug(__method__, "text=#{text}")
	params = {
		token: TOKEN,
		channel: CHANNEL,
		username: USERNAME,
		text: text
	}
	Slack.chat_postMessage params
end

Slack.configure do |config|
	config.token = TOKEN
end

client = Slack.realtime

client.on :hello do
	info('main', 'Successfully connected.')
end

client.on :message do |data|
	if data['channel'] == CHANNEL # For bottest
		unless data['subtype'] == 'bot_message'
			info('main', "data=#{data.inspect}")

			cl = nlc(data['text'])
			proc_cmd(cl)
			send_msg('他に御用はございますか？')
		end
	end
end

send_msg('MOC BRAINサービスへようこそ！')

client.start
