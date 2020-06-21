//
//  LogPresenter.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/20/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

protocol LogPresenter {
    func presentDocuments(at documentURLs: [URL])
    func createDocument(at documentURL: URL, completion: ((Result<BabyLog, BabyError>) -> Void)?)
}
