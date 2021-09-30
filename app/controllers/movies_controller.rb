class MoviesController < ApplicationController

    def show
      id = params[:id] # retrieve movie ID from URI route
      @movie = Movie.find(id) # look up movie by unique ID
      # will render app/views/movies/show.<extension> by default
    end
  
    def index
      @sortedBy = nil
      @filterRatings = nil
      @query = Movie
      @movies = @query.all
      @allRatings = Movie.uniq.pluck('rating')
      
      if !params.has_key?('ratings_filter') and !params.has_key?('sort_by') and (session.has_key?('ratings_filter') or session.has_key?('sort_by'))
        puts "[X] Redirection + Populating from session - #{session[:ratings_filter]} #{session[:sort_by]}"
        if session.has_key?('ratings_filter')
          params[:ratings_filter] = session[:ratings_filter]
        end
        if session.has_key?('sort_by')
          params[:sort_by] = session[:sort_by]
        end
        redirect_to movies_path(params)
      end
      
      if params.has_key?('ratings_filter')
        puts "filter tags #{@filterRatings} #{params[:ratings_filter]}"
        @filterRatings = params[:ratings_filter].keys
        @query = @query.where(rating: @filterRatings)
        session[:ratings_filter] = params[:ratings_filter]
        puts "[X] Collecting ratings_filter from request - #{@filterRatings}"
      elsif session.has_key?('ratings_filter')
        @filterRatings = session[:ratings_filter].keys
        @query = @query.where(rating: @filterRatings)
        puts "[X] Collecting ratings_filter from session - #{@filterRatings}"
      else
        @filterRatings = @allRatings
        @query = @query.where(rating: @filterRatings)
        puts "[X] Collecting ratings_filter from default - #{@filterRatings}"
      end
      
      if (params.has_key?('sort_by') and Movie.column_names.include?(params[:sort_by]))
        @sortedBy = params[:sort_by] 
        @movies = @query.all.order("#{@sortedBy}")
        session[:sort_by] = @sortedBy
        puts "[X] Explicit sort_by from request - #{@sortedBy}"
      elsif session.has_key?('sort_by')
        @sortedBy = session[:sort_by] 
        @movies = @query.all.order("#{@sortedBy}")
        puts "[X] Collecting sort_by from session - #{@sortedBy}"
      else
        @movies = @query.all
      end
    
    end
  
    def new
      # default: render 'new' template
    end
  
    def create
      @movie = Movie.create!(movie_params)
      flash[:notice] = "#{@movie.title} was successfully created."
      redirect_to movies_path
    end
  
    def edit
      @movie = Movie.find params[:id]
    end
  
    def update
      @movie = Movie.find params[:id]
      @movie.update_attributes!(movie_params)
      flash[:notice] = "#{@movie.title} was successfully updated."
      redirect_to movie_path(@movie)
    end
  
    def destroy
      @movie = Movie.find(params[:id])
      @movie.destroy
      flash[:notice] = "Movie '#{@movie.title}' deleted."
      redirect_to movies_path
    end
  
    private
    # Making "internal" methods private is not required, but is a common practice.
    # This helps make clear which methods respond to requests, and which ones do not.
    def movie_params
      params.require(:movie).permit(:title, :rating, :description, :release_date)
    end
  end