//
//  DocumentView.swift
//  Accountant
//
//  Created by Hisashi Ishihara on 2019/11/12.
//  Copyright © 2019 Hisashi Ishihara. All rights reserved.
//

import SwiftUI

struct DocumentView: View {
    var document: UIDocument
    var dismiss: () -> Void

    var body: some View {
        VStack {
            HStack {
                Text("File Name")
                    .foregroundColor(.secondary)

                Text(document.fileURL.lastPathComponent)
            }

            Button("Done", action: dismiss)
        }
    }
}
