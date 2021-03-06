import XCTest
import CoreData

class MovieRepositoryTests: XCTestCase {
	
	let coreDataHelper = TestCoreDataHelper()
	var movieRepository:MovieRepository?
	
    override func setUp() {
		super.setUp()
        self.movieRepository = MovieRepository(moc: self.coreDataHelper.managedObjectContext!)
        self.movieRepository?.movieImportService = TestMovieImportService(moc: self.coreDataHelper.managedObjectContext!)
    }
    
    override func tearDown() {
		super.tearDown()
		coreDataHelper.reset()
    }
    
	func testGetMovieCallsAPIIfOnlyHasSummary() {
		
		let expectation = expectationWithDescription("testGetMovieCallsAPIIfOnlyHasSummary")
		
		// Setup a movie in the moc that is only partly populated.
		let entity =  NSEntityDescription.entityForName("Movie", inManagedObjectContext: coreDataHelper.managedObjectContext!)
		let dbMovie = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: coreDataHelper.managedObjectContext!) as! Movie
		dbMovie.id = 1
		dbMovie.title = "TEST TEST TEST"
		dbMovie.summary = "This is a summary"
		dbMovie.containsDetail = false
	
		movieRepository!.getMovie(1) { (movie, error) -> Void in
			if let movieValue = movie {
				XCTAssertEqual(movieValue.id?.integerValue, 1)
				XCTAssertEqual(movieValue.title!, "Movie Detail")
				XCTAssertEqual(movieValue.summary!, "Movie Summary")
				XCTAssertEqual(movieValue.fileId?.integerValue, 99)
			} else {
				XCTFail()
			}
			expectation.fulfill()
		}
		
		waitForExpectationsWithTimeout(500, handler: {
			error in XCTAssertNil(error, "Oh, we got timeout")
		})
		
	}
	
	func testGetMovieDoesntCallAPIIfHasDetail() {
		
		let expectation = expectationWithDescription("Get Movie From DB")
		let entity =  NSEntityDescription.entityForName("Movie", inManagedObjectContext: coreDataHelper.managedObjectContext!)
		let dbMovie = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: coreDataHelper.managedObjectContext!) as! Movie
		
		dbMovie.id = 88
		dbMovie.title = "TEST FROM DB"
		dbMovie.summary = "Test Summary"
		dbMovie.fileId = 99
		dbMovie.containsDetail = true
		
		movieRepository!.getMovie(88) { (movie, error) -> Void in
			if let movieValue = movie {
				XCTAssert(movieValue.fileId?.integerValue == 99)
			} else {
				XCTFail()
			}
			expectation.fulfill()
		}
		
		waitForExpectationsWithTimeout(500, handler: {
			error in XCTAssertNil(error, "Oh, we got timeout")
		})
		
		
	}
    
    func testGetMovieGenresOnlyReturnsGenresWithMovies() {
        self.setupModel()
        
        let genres = self.movieRepository!.getGenres()
        XCTAssertEqual(1, genres.count)
    }
	
    func testGetMoviesForGenre() {
		
		let expectation = expectationWithDescription("Get comedy movies")
		
		self.setupModel()
        
		self.movieRepository!.getSummariesForGenre("Comedy") { (movies, error) -> Void in
			
			if let movieValues = movies {
				for movie in movieValues {
					let genres = movie.genres?.allObjects as! [Genre]
					XCTAssertEqual(1, genres.count)
					XCTAssertEqual(genres[0].genre, "Comedy")
				}
			} else {
				XCTFail()
			}
			
			expectation.fulfill()
		}
		
		waitForExpectationsWithTimeout(500, handler: {
			error in XCTAssertNil(error, "Oh, we got timeout")
		})
    }
	
    func setupModel() {
        // Create a genre, a movie and a tv show with an episode.
        let genreEntity =  NSEntityDescription.entityForName("Genre", inManagedObjectContext: self.coreDataHelper.managedObjectContext!)
        let movieEntity =  NSEntityDescription.entityForName("Movie", inManagedObjectContext: self.coreDataHelper.managedObjectContext!)
        let showEntity =  NSEntityDescription.entityForName("Show", inManagedObjectContext: self.coreDataHelper.managedObjectContext!)
        let episodeEntity =  NSEntityDescription.entityForName("Episode", inManagedObjectContext: self.coreDataHelper.managedObjectContext!)
        
        let genre = NSManagedObject(entity: genreEntity!, insertIntoManagedObjectContext: self.coreDataHelper.managedObjectContext!) as! Genre
        genre.genre = "Comedy"
        
        let movie = NSManagedObject(entity: movieEntity!, insertIntoManagedObjectContext: self.coreDataHelper.managedObjectContext!) as! Movie
        movie.id = 1
        movie.title = "Movie Title"
        movie.summary = "Movie Summary"
        
        
        let show = NSManagedObject(entity: showEntity!, insertIntoManagedObjectContext: self.coreDataHelper.managedObjectContext!) as! Show
        show.id = 2
        show.title = "Show Title"
        show.summary = "Show Summary"
        
        
        let episode = NSManagedObject(entity: episodeEntity!, insertIntoManagedObjectContext: self.coreDataHelper.managedObjectContext!) as! Episode
        episode.id = 3
        episode.title = "Episode Title"
        episode.summary = "Episode Summary"
        
        
        // Link the episode to the show and vice versa
        episode.show = show
        show.episodes = NSSet(array: [episode])
        
        // Link the episode to the genre, and vice versa
        // Link the movie to the genre, and vice versa
        movie.genres = NSSet(array: [genre])
        episode.genres = NSSet(array: [genre])
        
        genre.media = NSSet(array: [movie,episode])
        
    }
    
}
