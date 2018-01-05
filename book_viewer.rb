require "tilt/erubis"
require "sinatra"
require "sinatra/reloader"

before do 
  @toc = File.readlines("data/toc.txt")
end

helpers do
  def in_paragraphs(text)
    text.split("\n\n").each_with_index.map do |par, index|
      "<p id=paragraph#{index}>#{par}</p>"
    end
  end

  def generate_results(query)
    results = {}

    return results if !query || query.strip.empty?

    @toc.each_with_index do |chap, idx|
      text = File.read("data/chp#{idx + 1}.txt")
      results[idx + 1] = chap if text.include?(query)
    end
    results
  end

  def make_strong(text, query)
    text.gsub(query, "<strong>#{query}</strong>")
    #start = text.index(query)
    #text.insert(start, "<strong>")
    #ending = text.index(query) + query.length
    #text.insert(ending, "</strong>")
  end
end

get "/" do
  @title = "The Adventures of Sherlock Holmes"
  erb :home
end

get "/chapters/:number" do
  chap_num = params[:number].to_i

  redirect "/" unless (1..@toc.size).cover?(chap_num)

  @title = "Chapter #{chap_num}: " + @toc[chap_num - 1]
  @chapter = File.read("data/chp#{chap_num}.txt")

  erb :chapter
end

get "/search" do
  @search = params[:query]
  @results = generate_results(@search)
  erb :search
end

not_found do
  redirect "/"
end
