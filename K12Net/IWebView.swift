//
//  IWebView.swift
//  K12Net Mobile
//
//  Created by Ilhami Sisnelioglu on 19.02.2019.
//  Copyright © 2019 K12Net. All rights reserved.
//

import Foundation

protocol IWebView {
    func loadView() -> Void
    func viewDidLoad() -> Void
    func configureView() -> Void
    func homeView(_ sender: AnyObject) -> Void
    func refreshView(_ sender: AnyObject) -> Void
    func backView(_ sender: AnyObject) -> Void
    func nextView(_ sender: AnyObject) -> Void
    func signoutView() -> Void
    func webViewDidFinishLoad() -> Void
}
