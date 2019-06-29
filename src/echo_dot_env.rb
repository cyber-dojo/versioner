

DOT_ENV = begin
  src = IO.read('/app/.env')
  lines = src.lines.reject do |line|
    line.start_with?('#') || line.strip.empty?
  end
  lines.map { |line| line.split('=').map(&:strip) }.to_h
end

def tag_name(key)
  parts = key.split('_')[0..-2] << 'TAG'
  parts.join('_')
end

def tag_value(sha)
  sha[0...7]
end

def dont_tag?(key)
  %w(
    CYBER_DOJO_PORT
    CYBER_DOJO_CUSTOM
    CYBER_DOJO_EXERCISES
    CYBER_DOJO_LANGUAGES
  ).include?(key)
end

# - - - - - - - - - - - - - - - - - - - - - - - -

DOT_ENV.each do |key,value|
  puts "#{key}=#{value}"
end

DOT_ENV.each do |key,value|
  unless dont_tag?(key)
    puts "#{tag_name(key)}=#{tag_value(value)}"
  end
end
