//
//  ViewController.swift
//  FBMessanger
//
//  Created by SEUNG-WON KIM on 2018/03/22.
//  Copyright © 2018 SEUNG-WON KIM. All rights reserved.
//

import UIKit

class FriendsViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

  private let cellId = "cellId"
  
  var messages: [Message]?
  

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    tabBarController?.tabBar.isHidden = false
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationItem.title = "Recent"
    collectionView?.backgroundColor = .white
    collectionView?.alwaysBounceVertical = true
    collectionView?.register(MessageCell.self, forCellWithReuseIdentifier: cellId)
    
    setupData()
    
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if let count = messages?.count {
      return count
    }
    return 0
  }

  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MessageCell
    let message = messages![indexPath.item]
    cell.message = message
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: view.frame.width, height: 100)
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let layout = UICollectionViewFlowLayout()
    let controller = ChatLogViewController(collectionViewLayout: layout)
    controller.friend = messages?[indexPath.item].friend
    navigationController?.pushViewController(controller, animated: true)
  }
}


class MessageCell: BaseCell {

  override var isHighlighted: Bool {
    didSet {
      backgroundColor = isHighlighted ? UIColor(red: 0, green: 134/255, blue: 249/255, alpha: 1) : .white
      
      nameLabel.textColor = isHighlighted ? .white : .black
      timeLabel.textColor = isHighlighted ? .white : .black
      messageLabel.textColor = isHighlighted ? .white : .black
    }
  }
  
  var message: Message? {
    didSet {
      nameLabel.text = message?.friend?.name
      if let profileImageName = message?.friend?.profileImageName {
        profileImageView.image = UIImage(named: profileImageName)
        hasReadImageView.image = UIImage(named: profileImageName)
      }
    
      messageLabel.text = message?.text
      
      if let date = message?.date {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "h:mm a"
        
        let elapsedTimeInSeconds = NSDate().timeIntervalSince(date as Date)
        
        let secondInDays: TimeInterval = 60 * 60 * 24
        if elapsedTimeInSeconds > secondInDays {
          dateformatter.dateFormat = "EEE"
        } else if elapsedTimeInSeconds > 7 * secondInDays {
          dateformatter.dateFormat = "MM/dd/yy"
        }
        timeLabel.text = dateformatter.string(for: date)
      }
    }
  }
  
  let profileImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFill
    imageView.layer.cornerRadius = 34
    imageView.layer.masksToBounds = true
    return imageView
  }()
  
  let dividerLineView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
    return view
  }()
  
  let nameLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.systemFont(ofSize: 18)
    label.text = "Friend Name"
    return label
  }()
  
  let messageLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.systemFont(ofSize: 14)
    label.text = "Your frind's message and something else..."
    label.textColor = .darkGray
    return label
  }()
  
  let timeLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.font = UIFont.systemFont(ofSize: 16)
    label.text = "12:05 pm"
    label.textAlignment = .right
    return label
  }()
  
  let hasReadImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.image = UIImage(named: "canada")
    return imageView
  }()
  
  override func setupViews() {
//    backgroundColor = .blue
    
    addSubview(profileImageView)
    addSubview(dividerLineView)
    setupContainerView()
    
    profileImageView.image = UIImage(named: "canada")
    
    NSLayoutConstraint.activate([
      profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 12),
      profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
      profileImageView.widthAnchor.constraint(equalToConstant: 68),
      profileImageView.heightAnchor.constraint(equalToConstant: 68)])
    
    NSLayoutConstraint.activate([
      dividerLineView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
      dividerLineView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8),
      dividerLineView.widthAnchor.constraint(equalTo: self.widthAnchor),
      dividerLineView.heightAnchor.constraint(equalToConstant: 1)])
    

//    addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-12-[v0(68)]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":profileImageView]))
//    addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-12-[v0(68)]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["v0":profileImageView]))
  }
  
  private func setupContainerView() {
    let containerView = UIView()
//    containerView.backgroundColor = .red
    containerView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(containerView)
    
    NSLayoutConstraint.activate([
      containerView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 12),
      containerView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
      containerView.rightAnchor.constraint(equalTo: self.rightAnchor),
      containerView.heightAnchor.constraint(equalTo: profileImageView.heightAnchor)
      ])
    
    containerView.addSubview(nameLabel)
    containerView.addSubview(messageLabel)
    containerView.addSubview(timeLabel)
    containerView.addSubview(hasReadImageView)
    
    NSLayoutConstraint.activate([
      nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
      nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      nameLabel.rightAnchor.constraint(equalTo: timeLabel.leftAnchor),
//      nameLabel.widthAnchor.constraint(equalToConstant: 50),
      nameLabel.heightAnchor.constraint(equalToConstant: 20)])
  
    NSLayoutConstraint.activate([
      timeLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
      timeLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -14),
      timeLabel.widthAnchor.constraint(equalToConstant: 80),
      timeLabel.heightAnchor.constraint(equalToConstant: 20)])
    
    NSLayoutConstraint.activate([
      messageLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8),
      messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      messageLabel.rightAnchor.constraint(equalTo: hasReadImageView.leftAnchor, constant: -5),
      messageLabel.heightAnchor.constraint(equalToConstant: 20)])
    
    NSLayoutConstraint.activate([
      hasReadImageView.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 10),
      hasReadImageView.rightAnchor.constraint(equalTo: containerView.rightAnchor, constant: -14),
      hasReadImageView.widthAnchor.constraint(equalToConstant: 20),
      hasReadImageView.heightAnchor.constraint(equalToConstant: 20)
      ])
    
  }
}

class BaseCell: UICollectionViewCell {
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupViews()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func setupViews() {
//    backgroundColor = .blue
  }
}

