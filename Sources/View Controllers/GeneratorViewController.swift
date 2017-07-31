//
//  GeneratorViewController.swift
//  TOTPApp
//
//  Created by Lucas Stomberg on 7/29/17.
//  Copyright © 2017 Epic. All rights reserved.
//

import UIKit

class GeneratorViewController: UIViewController {

   private let token: ExtendedToken

   private lazy var generatorView: GeneratorView = GeneratorView()

   private lazy var timer: Timer = {

      return Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { _ in
         let seconds = Calendar.current.component(.second, from: Date())
         guard let currentPassword = self.token.token.token.currentPassword,
            !currentPassword.isEmpty else {
               //TODO: handle this error case
               return
         }

         self.generatorView.password = currentPassword
         
         let factor = self.token.token.token.generator.factor
         if case let .timer(double) = factor {
            let interval = Int(double)
            self.generatorView.passwordValidFor = (interval-1) - seconds % interval
            self.generatorView.nextPassword = (try? self.token.token.token.generator.password(at: Date(timeIntervalSinceNow: double))) ?? ""
         }
      })
   }()

   public init(token: ExtendedToken) {
      self.token = token
      super.init(nibName: nil, bundle: nil)
   }

   required init?(coder aDecoder: NSCoder) {
      fatalError("init?(coder:) is not supported")
   }


   override func loadView() {
      view = generatorView
   }

   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      timer.fire()
   }
}

class GeneratorView : UIView {

   private var passwordLabel: UILabel = {
      let label = UILabel()
      label.font = UIFont.preferredFont(forTextStyle: .title1)
      label.minimumScaleFactor = 0.5
      label.translatesAutoresizingMaskIntoConstraints = false
      return label
   }()

   private var timeLabel: UILabel = {
      let label = UILabel()
      label.font = UIFont.preferredFont(forTextStyle: .body)
      label.translatesAutoresizingMaskIntoConstraints = false
      return label
   }()

   private var nextPasswordLabel: UILabel = {
      let label = UILabel()
      label.font = UIFont.preferredFont(forTextStyle: .body)
      label.translatesAutoresizingMaskIntoConstraints = false
      return label
   }()

   public var password: String = "" {
      didSet {
         passwordLabel.text = password
      }
   }

   public var passwordValidFor: Int = 30 {
      didSet {
         timeLabel.text = "Valid For: \(passwordValidFor)"
      }
   }

   public var nextPassword: String = "" {
      didSet {
         nextPasswordLabel.text = "Next: \(nextPassword)"
      }
   }

   override init(frame: CGRect) {
      super.init(frame: frame)

      addSubview(passwordLabel)
      addSubview(timeLabel)
      addSubview(nextPasswordLabel)

      passwordLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
      passwordLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

      timeLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
      timeLabel.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor).isActive = true

      nextPasswordLabel.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
      nextPasswordLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 20).isActive = true

      backgroundColor = UIColor.white
   }

   convenience init() {
      self.init(frame: CGRect.zero)
   }

   required init(coder aDecoder: NSCoder) {
      fatalError("This class does not support NSCoding")
   }
}
