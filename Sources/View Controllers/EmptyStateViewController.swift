//
//  EmptyStateViewController.swift
//  TOTPApp
//
//  Created by Lucas Stomberg on 7/30/17.
//  Copyright © 2017 Epic. All rights reserved.
//

import UIKit

class EmptyStateViewController : UIViewController {
   let emptyView = EmptyStateView()
   
   override func loadView() {
      self.view = emptyView
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      emptyView.help.addTarget(self, action: #selector(helpButtonTapped), for: .touchUpInside)
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      self.navigationController?.setNavigationBarHidden(true, animated: animated)
   }
}

extension EmptyStateViewController {
   @objc
   func helpButtonTapped() {
      let ackURL = "THIS_IS_ACK_URL"
      let registrationURL = "THIS_IS_REGISTRATION_URL"
      let registrationToken = "THIS_IS_REGISTRATION_TOKEN"
      let secret = "JBSWY3DPEHPK3PXP"
      let issuer = "Epic"
      let digits = "8"
      let period = "60"
      let algorithm = "SHA512"
      let organization = "Epic"
      let username = "lstomber"
      guard let url = URL(string: "otpauth://totp/\(organization):\(username)?secret=\(secret)&issuer=\(issuer)&digits=\(digits)&period=\(period)&algorithm=\(algorithm)&ack=\(ackURL)&registration=\(registrationURL)&registrationToken=\(registrationToken)") else {
         return
      }
      
      UIApplication.shared.open(url, options: [:], completionHandler: nil)
   }
}


class EmptyStateView : UIView {
   
   let logo: UIView = {
      let view = UILabel()
      view.font = UIFont.boldSystemFont(ofSize: 52)
      view.text = "Epic"
      view.textColor = UIColor.red
      return view
   }()
   
   let title: UILabel = {
      let view = UILabel()
      view.font = UIFont.preferredFont(forTextStyle: .title2)
      view.text = "Not Enrolled"
      view.textColor = UIColor.gray
      return view
   }()
   
   let subtitle: UILabel = {
      let view = UILabel()
      view.font = UIFont.preferredFont(forTextStyle: .callout)
      view.adjustsFontSizeToFitWidth = true
      view.minimumScaleFactor = 0.7
      view.text = "Scan a QR code with your camera to get started."
      view.textColor = UIColor.gray
      return view
   }()
   
   public let help: UIButton = {
      let view = UIButton(type: .roundedRect)
      view.setTitle("View Tutorial", for: .normal)
      return view
   }()
   
   override init(frame: CGRect) {
      super.init(frame: frame)
      
      let stack = UIStackView(arrangedSubviews: [logo,title,subtitle,help])
      stack.axis = .vertical
      stack.alignment = .center
      stack.setCustomSpacing(20, after: logo)
      stack.setCustomSpacing(5, after: title)
      stack.setCustomSpacing(10, after: subtitle)
      
      stack.translatesAutoresizingMaskIntoConstraints = false
      addSubview(stack)
      stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5).isActive = true
      stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5).isActive = true
      stack.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
   }
   
   required init?(coder aDecoder: NSCoder) {
      fatalError()
   }
}

private extension UIFont {
   
   var italicised: UIFont? {
      guard let italicDescriptor = fontDescriptor.withSymbolicTraits(.traitItalic) else { return nil }
      return UIFont(descriptor: italicDescriptor, size: pointSize)
   }
}
