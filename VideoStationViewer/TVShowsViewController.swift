import UIKit

class TVShowsViewController: UICollectionViewController {
	// MARK: Properties
	
	private static let minimumEdgePadding = CGFloat(90.0)
	var showRepository:ShowRepository!
	private var shows = [Show]()
	private var listType = "Show"
	
	// MARK: UIViewController
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let coreDataHelper = CoreDataHelper.sharedInstance
		self.showRepository = ShowRepository(moc: coreDataHelper.managedObjectContext!)
		
		// Make sure their is sufficient padding above and below the content.
		guard let collectionView = collectionView, layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
		
		collectionView.contentInset.top = TVShowsViewController.minimumEdgePadding - layout.sectionInset.top
		collectionView.contentInset.bottom = TVShowsViewController.minimumEdgePadding - layout.sectionInset.bottom
	}
	
	override func viewWillAppear(animated: Bool) {
		
		super.viewWillAppear(animated)
		NSLog("View will appear")
		// Get a list of genres and then reload the collection, which in turn will load the media items for each genre
		self.shows = self.showRepository!.getShows()
		self.collectionView!.reloadData()
	}
	
	// MARK: UICollectionViewDataSource
	
	override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return shows.count
	}
	
	override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		// Each section contains a single `CollectionViewContainerCell`.
		return 1
	}
	
	override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		// Dequeue a cell from the collection view.
		return collectionView.dequeueReusableCellWithReuseIdentifier(PosterStrip.reuseIdentifier, forIndexPath: indexPath)
	}
	
	// MARK: UICollectionViewDelegate
	
	override func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
		//print("Poster Collection: will display cell \(indexPath)")
		guard let cell = cell as? PosterStrip else { fatalError("Expected to display a `CollectionViewContainerCell`.") }
		let show = shows[indexPath.section]
		let episodes = show.sortedEpisodes()
        if let episodesValue = episodes {
            cell.configureWithMediaItems(episodesValue)
        }

	}
	
	override func collectionView(collectionView: UICollectionView, canFocusItemAtIndexPath indexPath: NSIndexPath) -> Bool {
		/*
		Return `false` because we don't want this `collectionView`'s cells to
		become focused. Instead the `UICollectionView` contained in the cell
		should become focused.
		*/
		return false
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		
		let cell = sender as! PosterCell
		let controller = segue.destinationViewController as! MovieDetailViewController
		controller.mediaItem = nil
		
        let episodeRepository = EpisodeRepository.sharedInstance

        episodeRepository.getEpisode((cell.representedDataItem?.id?.integerValue)!) { (episode, error) -> Void in
            controller.mediaItem = episode
        }
		
	}
	
	// Todo find a way to display a section title
	
	func setTitleAndType(title:String, type:String) {
		self.title = title
		self.listType = type
	}
	
	override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
		
		switch kind {
		case UICollectionElementKindSectionHeader:
			let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "PosterHeaderView", forIndexPath: indexPath) as! PosterHeaderCollectionReusableView
			headerView.title.text = shows[indexPath.section].title
			return headerView
		default:
			assert(false, "Unexpected element kind")
		}
	}
	
}
