This is a simple rails 3.2 app for grabbing and parsing XBRL files (and a few others) from the SEC's edgar site.

A few useful commands:

- to clone the repo from github:
git clone https://github.com/markoblad/edgar.git

- install version of rails for app
gem install rails -v '3.2.19'

or use rbenv or rvm

- install gems
bundle install

- start a local development server on http://localhost:3000
rails server

- start a development console
rails console

- add role to database changing "edgarxbrl" to your application name
psql postgres;
CREATE ROLE edgarxbrl;
ALTER USER edgarxbrl WITH LOGIN SUPERUSER CREATEDB CREATEROLE REPLICATION;

- create the database
rake db:create:all


To understand how SEC filing exhibits are classified see Reg SK here: http://www.law.cornell.edu/cfr/text/17/229.601

To get links for accessing edgar data, go to http://www.sec.gov/edgar/searchedgar/ftpusers.htm
Daily Index (FTP)
ftp://ftp.sec.gov/edgar/daily-index/


Examples of using Edgar FTP to write files locally:

EdgarFtp.get_daily_index_text_file('edgar/daily-index/2013/QTR4', 'sitemap.20131120.xml', opts={})

EdgarFtp.get_daily_index_bin_file('edgar/daily-index/2013/QTR4', 'company.20131120.idx.gz', opts={})

The SEC's edgar site is massive source of very valuable information on companies, funds and investors.  The common way to use the information is to go to the site at
www.sec.gov, click on Company Filings, search a company and click through their filings.

Some of the most used information are annual and quarterly reports of public companies (10Ks and 10Qs); proxy statements for public companies;  13G, 13D and 13F ownership disclosures by significant shareholders and large funds; 8Ks for material events for public companies; Form D filings for new financings; and exhibits to various filings.  

All of this information can be obtained in nicely formatted, readable formats.  There are also other formats that make the information much more accessible for software to process the information: 
- most files are available in a text format with styling removed;
- the financial statements and notes in 10Ks, 10Qs, some 8Ks and some 20-Fs are available in a structured format called XBRL; and
- some filings (e.g., more recent Form Ds) and indexes are available in XML formats.

Since there is so much information there, the filings are indexed several different ways.  This is great if you want to systematically go through all of the information, but it takes a little more work narrow the information to just that you're looking for.

There's nothing new under the sun--people have been using these datasets for years.  Interesting though, that it is sufficiently difficult that investors pay significant amounts to get better access to the information (think Bloomberg, FactSet, CapIQ).

Some interesting things to do with the data might be:
- gather Form Ds to plot investment trends
- gather public company charters and apply NLP libraries to determine a company's governance and/or security rights.
- gather merger and acquisition agreements to compile information on terms or acquisition trends
- gather the XBRL data and generate financial statements to run valuations and or build investing algorithms
- general contract search functions
- build a current set of company contracts (e.g., the current charter, bylaws and equity plans)











