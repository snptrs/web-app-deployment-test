# file: app.rb
require 'sinatra'
require "sinatra/reloader"
require_relative 'lib/database_connection'
require_relative 'lib/album_repository'
require_relative 'lib/artist_repository'

DatabaseConnection.connect

class Application < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    also_reload 'lib/album_repository'
    also_reload 'lib/artist_repository'
  end
  
  get '/albums/new' do
    return erb(:new_album)
  end
  
  post '/albums' do
    def invalid_request_parameters?
      return true if params[:title] == nil || params[:release_year] == nil || params[:artist_id] == nil
      return true if params[:title] == "" || params[:release_year] == "" || params[:artist_id] == ""
      return false
    end
    
    if invalid_request_parameters?
      status 400
      return "Oopsie, something isn't right..."
    end
    
    repo = AlbumRepository.new
    album = Album.new
    album.title = params[:title]
    album.release_year = params[:release_year]
    album.artist_id = params['artist_id']
    
    repo.create(album)
    return "Album #{album.title} added"
  end
  
  get '/albums' do
    repo = AlbumRepository.new
    @albums = repo.all
    
    return erb(:albums)
  end
  
  get '/albums/:id' do
    album_id = params[:id]
    repo = AlbumRepository.new
    album = repo.find(album_id)
    @album_title = album.title
    @release_year = album.release_year
    artist_id = album.artist_id
    
    repo = ArtistRepository.new
    artist = repo.find(artist_id)
    @artist_name = artist.name
    
    return erb(:album)
  end
  
  get '/artists/new' do
    return erb(:new_artist)
  end
  
  get '/artists' do
    repo = ArtistRepository.new
    @artists = repo.all
    
    return erb(:artists)
  end
  
  get '/artists/:id' do
    artist_id = params[:id]
    repo = ArtistRepository.new
    @artist = repo.find(artist_id)

    return erb(:artist)
  end
  
  post '/artists' do
    def invalid_request_parameters?
      return true if params[:name] == nil || params[:genre] == nil
      return true if params[:genre] == "" || params[:genre] == ""
      return false
    end
    
    if invalid_request_parameters?
      status 400
      return "Oopsie, something isn't right..."
    end
    
    repo = ArtistRepository.new
    artist = Artist.new
    artist.name = params[:name]
    artist.genre = params[:genre]
    
    repo.create(artist)
    return "Artist #{artist.name} added."
  
  end
  
end
