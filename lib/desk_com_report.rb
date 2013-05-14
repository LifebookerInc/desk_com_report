require 'restclient'
require 'csv'
require 'chronic'
require 'trollop'
require 'json'

class DeskComReport

  def initialize(opts)
    @opts = opts
  end


  def run
    self.get_data
    self.write_csv
    puts "Created #{self.csv_file_name}"
    `open #{self.csv_file_name}`
  end

  protected

  def csv_file_name
    @csv_file_name ||= File.expand_path(
      File.join(
        "~", "Desktop", "#{Time.now.strftime("%Y%m%d_%H%M%S")}.csv"
      )
    )
  end

  def get_field_names(line)
    names = line.select{|k,v| !v.is_a?(Hash)}.keys
    names += line["custom_fields"].keys
  end

  def get_field_values(line)
    values = line.select{|k,v| !v.is_a?(Hash)}.values
    values += line["custom_fields"].values
    # convert arrays to ;-delimited string
    values.collect{|v| v.is_a?(Array) ? v.join("; ") : v}
  end

  def generate_csv_string
    CSV.generate do |csv|
      csv << self.get_field_names(@data["_embedded"]["entries"].first)
      @data["_embedded"]["entries"].each do |line|
        csv << self.get_field_values(line)
      end
    end
  end

  def get_data
    @data ||= begin
      req = RestClient::Request.new(
        :url => "https://lifebooker.desk.com/api/v2/cases/search?since_created_at=#{self.since.to_i}",
        :user => self.user,
        :password => self.password,
        :method => :get,
        :headers => { :accept => :json, :content_type => :json }
      )
      JSON.parse(req.execute)
    end
  end

  def password
    @opts[:password]
  end

  def since
    @since ||= Chronic.parse(@opts[:since])
  end

  def user
    @opts[:user]
  end

  def write_csv
    File.open(self.csv_file_name, "w+") do |f|
      f.puts(self.generate_csv_string)
    end
  end

end