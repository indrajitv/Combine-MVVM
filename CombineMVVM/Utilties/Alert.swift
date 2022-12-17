//
//  Alert.swift
//  CombineMVVM
//
//  Created by Indrajit Chavda on 14/12/22.
//

import UIKit

final class Alert {
    static func show(on: UIViewController, message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "Ok", style: .default))
        on.present(alert, animated: true)
    }
}
