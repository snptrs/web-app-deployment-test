require "spec_helper"
require "rack/test"
require_relative '../../app'

describe Application do
  # This is so we can use rack-test helper methods.
  include Rack::Test::Methods

  # We need to declare the `app` value by instantiating the Application
  # class so our tests work.
  let(:app) { Application.new }

  context "GET /albums/new" do
    it 'returns 200 OK' do
      response = get('/albums/new')
      expect(response.status).to eq(200)
      expect(response.body).to include('<h1>New album</h1')
      expect(response.body).to include('<form action="/albums" method="POST">')
    end
  end
  
  context "POST /albums" do
    it 'returns 200 OK' do
      response = post('/albums', title: 'Voyage', release_year: 2022, artist_id: 2)
      expect(response.status).to eq(200)
      
      response = get('/albums')
      expect(response.body).to include('Voyage')
    end
    
    it "returns an error if the parameters aren't correct" do
      response = post('/albums', title: 'Blonde on Blonde') # No release__year or artist_id
      expect(response.status).to eq(400)
      expect(response.body).to include("Oopsie, something isn't right...")
    end
  end
  
  context "GET /albums/" do
    it 'returns 200 OK and a list of albums' do
      response = get('/albums')
      expect(response.status).to eq(200)
      expect(response.body).to include('Voyage')
      expect(response.body).to include('Folklore')
    end
    
    it 'includes a link to the individual album page' do
      response = get('/albums')
      expect(response.status).to eq(200)
      expect(response.body).to include('<a href="/albums/13">Voyage</a>')
    end
  end
  
  context "GET /albums/:id" do
    it 'returns 200 OK and a signle album' do
      response = get('/albums/13')
      expect(response.status).to eq(200)
      expect(response.body).to include('<h1>Voyage</h1>')
      expect(response.body).to include('Release year: 2022')
    end
  end
  
  context "GET /artists" do
    it "returns a list of artists" do
      response = get('/artists')
      expect(response.status).to eq(200)
      expect(response.body).to include('<a href="/artists/1">Pixies</a>').or include("Pixies, ABBA, Taylor Swift, Nina Simone, Kiasmos")
    end
  end
  
  context "GET /artists/new" do
    it "returns a new artist form" do
      response = get('/artists/new')
      expect(response.body).to include('<h1>New artist</h1')
      expect(response.body).to include('<form action="/artists" method="POST">')
    end
  end
  
  context "GET /artists/:id" do
    it "returns a single artist by ID" do
      response = get('/artists/1')
      expect(response.status).to eq(200)
      expect(response.body).to include("<h1>Pixies</h1>")
    end
  end
  
  context "POST /artists" do
    it "adds an artist to the database" do
      response = post('/artists', name: 'Wild nothing', genre: 'Indie')
      expect(response.status).to eq(200)
      
      response = get('/artists')
      expect(response.body).to include('<a href="/artists/1">Pixies</a>').or include("Pixies, ABBA, Taylor Swift, Nina Simone, Kiasmos")
    end
    
    it "returns an error if the parameters aren't correct" do
      response = post('/artists', name: 'Wild nothing') # No genre submitted
      expect(response.status).to eq(400)
      expect(response.body).to include("Oopsie, something isn't right...")
    end
  end
end
