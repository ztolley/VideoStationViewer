//
//  CastMember+CoreDataProperties.swift
//  VideoStationViewer
//
//  Created by Zac Tolley on 12/01/2016.
//  Copyright © 2016 Scropt. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CastMember {

    @NSManaged var title: String?
    @NSManaged var media: NSSet?

}
