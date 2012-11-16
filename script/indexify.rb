#!/usr/bin/env ruby

outfile = File.open(File.join(File.dirname(__FILE__), "..", "index.html"), 'w')

infiles = Dir::glob(File.join(File.dirname(__FILE__), "..", "*.md"))

postings = []

class Posting
  def initialize(data, slug)
    @data = data
    @slug = slug
    @location = nil
    @name = nil
    @opportunities = nil
  end
  
  def slug
    @slug
  end
  
  def name
    @name ||= @data.scan(/^#([^\n]+)$/)[0]   
  end
  
  def location
    @location ||= @data.scan(/Location: ([^\n]+)$/)[0]
  end
  
  def opportunities
    @opportunities ||= @data.scan(/##What kind of opportunities are available at your organization\?(.*)##/m)[0][0].gsub(/[\r\n]+/, "<br/>") rescue "" 
  end
  
end

for file in infiles do
  postings << Posting.new(File.read(file), File.basename(file))
end

puts "parsed postings: #{postings.size}"

outfile.puts <<-EOF
<html>
  <head>
    <meta charset='utf-8' />
    <title>Nov 7 Job Listings</title>
    <link href="http://twitter.github.com/bootstrap/assets/css/bootstrap.css" rel="stylesheet">
    <link href="http://twitter.github.com/bootstrap/assets/css/bootstrap-responsive.css" rel="stylesheet">
    <style type="text/css">body{ font-family:helvetica;} td, th{ padding: 10px; }</style>
  </head>
  <body>
    <table class="table table-striped table-hover">
      <tr>
        <th style="width:15%;">Name</th>
        <th style="width:15%;">Location</th>
        <th style="width:70%;">Opportunities</th>
      </tr>
EOF

postings.each do |post|
  print "."
  outfile.puts "<tr><td><a href='https://github.com/ofa-alumni/job_listings/blob/master/#{post.slug}'>#{post.name}</a></td><td>#{post.location}</td><td>#{post.opportunities}</td></tr>"
end

outfile.puts <<-EOF
    </table>
  <p>Last Updated at: #{Time.now} | HEAD is: #{`git log | head -n 1`}</p>
  </body>
</html>
EOF

puts "wrote index.html. Done."
