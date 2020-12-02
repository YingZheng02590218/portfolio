//
//  Document.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2019/11/12.
//  Copyright © 2019 Hisashi Ishihara. All rights reserved.
//

import UIKit

class Document: UIDocument {
    
    override func contents(forType typeName: String) throws -> Any {
        // Encode your document with an instance of NSData or NSFileWrapper
        return Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
    }
}

