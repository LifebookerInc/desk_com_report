require 'rubygems'

require 'restclient'
require 'chronic'
require 'trollop'
require 'json'

if RUBY_VERSION.to_f < 1.9
  require 'fastercsv'
  CSV = FCSV
else
  require 'csv'
end

class DeskComReport

  ENDPOINT = "https://lifebooker.desk.com"

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

  def fetch_data(page = 1)
    make_request(
      :url => "#{ENDPOINT}/api/v2/cases/search?since_created_at=#{self.since.to_i}&page=#{page}"
    )
  end

  def get_field_names(line)
    names = line.dup.delete_if{|k,v| v.is_a?(Hash)}.keys
    names += line["custom_fields"].keys
    names << "Assigned User"
  end

  def get_field_values(line)
    values = line.dup.delete_if{|k,v| v.is_a?(Hash)}.values
    values += line["custom_fields"].values
    values << self.get_user_name(line)
    # convert arrays to ;-delimited string
    values = values.collect{|v| v.is_a?(Array) ? v.join("; ") : v}
    values = values.collect{|v| v.to_s.gsub(/[;\|]/,";")}
    values
  end

  # fetch the user's name based on his href
  def get_user_name(line)

    if line["_links"]["assigned_user"].is_a?(Hash)
      href = line["_links"]["assigned_user"]["href"]
    else
      return "Not Assigned"
    end

    @map ||= {}
    @map[href] ||= begin
      self.make_request(:url => "#{ENDPOINT}#{href}")["name"]
    end
  end

  def generate_csv_string
    CSV.generate do |csv|
      csv << self.get_field_names(@data.first)
      @data.each do |line|
        csv << self.get_field_values(line)
      end
    end
  end

  def get_data
    @data ||= begin
      puts "Fetching data since #{self.since.strftime("%m/%d/%Y %H:%M:%S %Z")}"
      first_response = self.fetch_data
      total = first_response["total_entries"]
      pages = (total / 100.0).ceil

      res = first_response["_embedded"]["entries"]
      (2..pages).each do |page|
        puts "Fetching page #{page} of #{pages}"
        res += self.fetch_data(page)["_embedded"]["entries"]
      end

      res
    end
  end

  def make_request(opts)
    req = RestClient::Request.new(opts.merge(
      :user => self.user,
      :password => self.password,
      :method => :get,
      :headers => { :accept => :json, :content_type => :json }
    ))
    JSON.parse(req.execute)
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