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

   func fakeURL() -> URL? {
      let ackURL = "http://EPIC.com/acceptTokenPush"
      let registrationURL = "http://www.google.com/RegisterDevice"
      let registrationToken = "hunter2"
      let secret = "JBSWY3DPEHPK3PXP"
      let issuer = "Epic"
      let digits = "8"
      let period = "60"
      let algorithm = "SHA512"
      let organization = "Epic"
      let username = "lstomber"

      let url = URL(string: "otpauth://totp/\(organization):\(username)?secret=\(secret)&issuer=\(issuer)&digits=\(digits)&period=\(period)&algorithm=\(algorithm)&ack=\(ackURL)&registration=\(registrationURL)&registrationToken=\(registrationToken)")
      return url
   }

   func fakeURL2() -> URL? {
      let organization = "Epic"
      let username = "lstomber"
      let secret = "*******************************************"
      let issuer = "Epic"
      let digits = "6"
      let period = "30"
      let algorithm = "SHA256"
      let registrationURL = "http://vs-icx.epic.com/Interconnect-CDE/internal/Mobile/Unauthenticated/Epic.Mobile.Security.TwoFactorAuthentication.RegisterDevice"
      let ackURL = "http://EPIC.com/acceptTokenPush"
      let registrationToken = "sSbC4xB7MEKx/yhJJjlztpGHzv8D1vIgIpapcmTDZXCRbxYTYeI5Z58vKofrbHRWN1Y1g3ir/2WJFwJky8RvBaBruuW5BuFO2c30v6ObaKwFDRLk1n/5mz512dBtDunz"

      let url = URL(string: "otpauth://totp/\(organization):\(username)?secret=\(secret)&issuer=\(issuer)&digits=\(digits)&period=\(period)&algorithm=\(algorithm)&ack=\(ackURL)&registration=\(registrationURL)&registrationToken=\(registrationToken)")
      return url
   }

   @objc
   func helpButtonTapped() {
      if let url = fakeURL2() {
         UIApplication.shared.open(url, options: [:], completionHandler: nil)
      }
   }
}











/*
 example otpauth://totp/Epic:lstomber?secret=JBSWY3DPEHPK3PXP&issuer=Epic&digits=8&period=60&algorithm=SHA512&ack=http://interconnect/path/service/2/3&registration=http://interconnect/path/service/1/1/1​&registrationToken=sdlfkjlkjTHISISAREGISTRATIONTOKENlksdjflksj

 generated QR CODE here:
 https://chart.googleapis.com/chart?cht=qr&chl=otpauth%3A%2F%2Ftotp%2FEpic%3Alstomber%3Fsecret%3DJBSWY3DPEHPK3PXP%26issuer%3DEpic%26digits%3D8%26period%3D60%26algorithm%3DSHA512%26ack%3Dhttp%3A%2F%2Finterconnect%2Fpath%2Fservice%2F2%2F3%26registration%3Dhttp%3A%2F%2Finterconnect%2Fpath%2Fservice%2F1%2F1%2F1%E2%80%8B%26registrationToken%3DsdlfkjlkjTHISISAREGISTRATIONTOKENlksdjflksj&chs=180x180&choe=UTF-8&chld=L|2


 otpauth://totp/Epic:lstomber?secret=JBSWY3DPEHPK3PXP&issuer=Epic&digits=8&period=60&algorithm=SHA512&ack=http://www.EPIC.com/acceptTokenPush&registration=http://www.google.com/registerDevice&registrationToken=hunter2

 https://chart.googleapis.com/chart?cht=qr&chl=otpauth%3A%2F%2Ftotp%2FEpic%3Alstomber%3Fsecret%3DJBSWY3DPEHPK3PXP%26issuer%3DEpic%26digits%3D8%26period%3D60%26algorithm%3DSHA512%26ack%3Dhttp%3A%2F%2Fwww.EPIC.com%2FacceptTokenPush%26registration%3Dhttp%3A%2F%2Fwww.google.com%2FregisterDevice%26registrationToken%3Dhunter2&chs=180x180&choe=UTF-8&chld=L|2
 */











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
