//
//  ChatLogViewController.swift
//  FBMessanger
//
//  Created by SEUNG-WON KIM on 2018/03/23.
//  Copyright © 2018 SEUNG-WON KIM. All rights reserved.
//

import UIKit
import CoreData

class ChatLogViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, NSFetchedResultsControllerDelegate {

  private let cellId = "cellId"
  
  var friend: Friend? {
    didSet {
      navigationItem.title = friend?.name
    }
  }
  
  let messageInputContainerView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  let inputTextField: UITextField = {
    let textField = UITextField()
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.placeholder = "Enter message..."
    return textField
  }()
  
  lazy var sendButton: UIButton = {
    let button = UIButton()
    button.setTitle("Send", for: .normal)
    button.translatesAutoresizingMaskIntoConstraints = false
    let color = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
    button.setTitleColor(color, for: .normal)
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
    return button
  }()
  
  @objc func handleSend() {
    guard let text = inputTextField.text else { return }
    if  text.count == 0 { return }
    
    let delegate = UIApplication.shared.delegate as? AppDelegate
    guard let context = delegate?.persistentContainer.viewContext else { return }

    FriendsViewController.createMessageWithText(text: text, friend: friend!, context: context, isSender: true)
    do {
      try context.save()
      inputTextField.text = nil
      
    }catch let err {
      print(err)
    }
  }
  
  lazy var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> = {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Message")
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
    fetchRequest.predicate = NSPredicate(format: "friend.name = %@", friend!.name!)
    let delegate = UIApplication.shared.delegate as? AppDelegate
    let context = delegate?.persistentContainer.viewContext
    let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context!, sectionNameKeyPath: nil, cacheName: nil)
    frc.delegate = self
    return frc
  }()
  
  var blockOperations = [BlockOperation]()
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    if type == .insert {
      blockOperations.append(BlockOperation(block: {
        self.collectionView?.insertItems(at: [newIndexPath!])
      }))
    }
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    collectionView?.performBatchUpdates({
      for operation in self.blockOperations {
        operation.start()
      }
    }, completion: { (completed) in
      
      let lastItem = self.fetchedResultsController.sections![0].numberOfObjects - 1
      let indexPath = IndexPath(item: lastItem, section: 0)
      self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
    })
  }
  
  // MARK: - variables
  var bottomConstraint: NSLayoutConstraint?
  
  @objc func simulate() {
    let delegate = UIApplication.shared.delegate as? AppDelegate
    guard let context = delegate?.persistentContainer.viewContext else { return }

    FriendsViewController.createMessageWithText(text: "Where's a text message that was sent a few minutes ago...", friend: friend!, context: context)
    do {
      try context.save()
      inputTextField.text = nil
      
    }catch let err {
      print(err)
    }
  }
  
  // MARK: - functions
  override func viewDidLoad() {
    super.viewDidLoad()
    
    do {
      try fetchedResultsController.performFetch()
    } catch let err {
      print(err)
    }
    
    navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Simulate", style: .plain, target: self, action: #selector(simulate))
    
    tabBarController?.tabBar.isHidden = true
    
    collectionView?.backgroundColor = .white
    collectionView?.register(ChatLogMessageCell.self, forCellWithReuseIdentifier: cellId)
    collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: messageInputContainerView.bounds.height + 40, right: 0)
    
    if #available(iOS 11.0, *) {
      collectionView?.contentInsetAdjustmentBehavior = .always
    } else {
      automaticallyAdjustsScrollViewInsets = true
    }
    
    view.addSubview(messageInputContainerView)
    
    bottomConstraint =  messageInputContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
    bottomConstraint?.isActive = true
    messageInputContainerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    messageInputContainerView.heightAnchor.constraint(equalToConstant: 40).isActive = true
    
    setupInputComponents()
    
    NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name:Notification.Name.UIKeyboardWillShow , object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name:Notification.Name.UIKeyboardWillHide , object: nil)
    
    // move to end
    let lastItem = self.fetchedResultsController.sections![0].numberOfObjects - 1
    let indexPath = IndexPath(item: lastItem, section: 0)
    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
  }
  
  @objc func handleKeyboardNotification(notification: NSNotification) {
    if let userInfo = notification.userInfo {
      let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect
      let isKeyboardShowing = notification.name == Notification.Name.UIKeyboardWillShow
      
      bottomConstraint?.constant = isKeyboardShowing ? -keyboardFrame.height : 0
      
      UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
        self.view.layoutIfNeeded()
      }, completion: { (completed) in
        if isKeyboardShowing {
          let lastItem = self.fetchedResultsController.sections![0].numberOfObjects - 1
          let indexPath = IndexPath(item: lastItem, section: 0)
          self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
        }
      })
      
      
    }
  }
  
  private func setupInputComponents() {
    let topBorderView = UIView()
    topBorderView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
    topBorderView.translatesAutoresizingMaskIntoConstraints = false
    
    messageInputContainerView.addSubview(inputTextField)
    messageInputContainerView.addSubview(sendButton)
    messageInputContainerView.addSubview(topBorderView)
    
    NSLayoutConstraint.activate([
      inputTextField.topAnchor.constraint(equalTo: topBorderView.bottomAnchor),
      inputTextField.leadingAnchor.constraint(equalTo: messageInputContainerView.leadingAnchor, constant: 8),
      inputTextField.trailingAnchor.constraint(equalTo: messageInputContainerView.trailingAnchor),
      inputTextField.heightAnchor.constraint(equalTo: messageInputContainerView.heightAnchor)])
    
    NSLayoutConstraint.activate([
      sendButton.topAnchor.constraint(equalTo: inputTextField.topAnchor),
      sendButton.trailingAnchor.constraint(equalTo: messageInputContainerView.trailingAnchor, constant: 2),
      sendButton.widthAnchor.constraint(equalToConstant: 60),
      sendButton.heightAnchor.constraint(equalTo: inputTextField.heightAnchor)])
    
    NSLayoutConstraint.activate([
      topBorderView.topAnchor.constraint(equalTo: messageInputContainerView.topAnchor),
      topBorderView.leadingAnchor.constraint(equalTo: messageInputContainerView.leadingAnchor),
      topBorderView.trailingAnchor.constraint(equalTo: messageInputContainerView.trailingAnchor),
      topBorderView.heightAnchor.constraint(equalToConstant: 0.5)])
  }
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    inputTextField.endEditing(true)
  }
  
  // MARK: UICollectionViewDataSource
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    
    if let count = fetchedResultsController.sections?[0].numberOfObjects {
      return count
    }
    return 0
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatLogMessageCell
    
    let message = fetchedResultsController.object(at: indexPath) as! Message
    cell.messageTextView.text = message.text
    
    if let messageText = message.text, let profileImageName = message.friend?.profileImageName {
      cell.profileImageView.image = UIImage(named: profileImageName)
      
      let size = CGSize(width: 250, height: 1000)
      let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
      let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [kCTFontAttributeName as NSAttributedStringKey : UIFont.systemFont(ofSize: 18)], context: nil)
     
      if !message.isSender {
        cell.messageTextView.frame = CGRect(x: 48 + 8, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
        
        cell.textBubbleView.frame =  CGRect(x: 48 - 10, y: -4, width: estimatedFrame.width  + 16 + 8 + 16, height: estimatedFrame.height + 20 + 6)
        
        cell.profileImageView.isHidden = false
        
        cell.bubbleImageView.image = ChatLogMessageCell.grayBubbleImage
        cell.textBubbleView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        cell.messageTextView.textColor = .black
        
      } else {
        cell.messageTextView.frame = CGRect(x: view.frame.width - estimatedFrame.width - 16 - 16 - 8, y: 0, width: estimatedFrame.width + 16, height: estimatedFrame.height + 20)
        
        cell.textBubbleView.frame =  CGRect(x: view.frame.width - estimatedFrame.width - 16 - 8 - 16 - 10, y: -4, width: estimatedFrame.width + 16 + 8, height: estimatedFrame.height + 20)
        
        cell.profileImageView.isHidden = true
        
        cell.bubbleImageView.image = ChatLogMessageCell.blueBubbleImage
        cell.textBubbleView.backgroundColor = UIColor(red: 0, green: 137/255, blue: 249/255, alpha: 1)
        cell.messageTextView.textColor = .white
      }
      
    }
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    
    let message = fetchedResultsController.object(at: indexPath) as! Message
    if let messageText = message.text {
      let size = CGSize(width: 250, height: 1000)
      let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
      let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [kCTFontAttributeName as NSAttributedStringKey : UIFont.systemFont(ofSize: 18)], context: nil)
      return CGSize(width: view.frame.width, height: estimatedFrame.height + 20)
    }
    return CGSize(width: view.frame.width, height: 100)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsetsMake(0, 0, 0, 0)
  }
}



class ChatLogMessageCell: BaseCell {
  
  let messageTextView: UITextView = {
    let textView = UITextView()
    textView.font = UIFont.systemFont(ofSize: 18)
    textView.text = "Sample message"
    textView.translatesAutoresizingMaskIntoConstraints = false
    textView.backgroundColor = .clear
    textView.isEditable = false
    return textView
  }()
  
  let textBubbleView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor(white: 0.95, alpha: 1)
    view.layer.cornerRadius = 15
    view.layer.masksToBounds = true
    return view
  }()
  
  let profileImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.layer.cornerRadius = 15
    imageView.layer.masksToBounds = true
    return imageView
  }()
  
  static let grayBubbleImage = UIImage(named: "chat-bubble-gray3")?.resizableImage(withCapInsets: UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15), resizingMode: .stretch).withRenderingMode(.alwaysTemplate)
  
  static let blueBubbleImage = UIImage(named: "bubble-gray")?.resizableImage(withCapInsets: UIEdgeInsets(top: 17, left: 21, bottom: 17, right: 21), resizingMode: .stretch).withRenderingMode(.alwaysTemplate)
  
  let bubbleImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "bubble-gray")?.resizableImage(withCapInsets: UIEdgeInsets(top: 22, left: 26, bottom: 22, right: 26), resizingMode: .stretch).withRenderingMode(.alwaysTemplate)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  

  override func setupViews() {
    super.setupViews()
    
    addSubview(textBubbleView)
    addSubview(messageTextView)
    addSubview(profileImageView)
    textBubbleView.addSubview(bubbleImageView)
    
    NSLayoutConstraint.activate([
      profileImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
      profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8),
      profileImageView.widthAnchor.constraint(equalToConstant: 30),
      profileImageView.heightAnchor.constraint(equalToConstant: 30)])

    NSLayoutConstraint.activate([
      bubbleImageView.topAnchor.constraint(equalTo: textBubbleView.topAnchor),
      bubbleImageView.leftAnchor.constraint(equalTo: textBubbleView.leftAnchor, constant: 0),
      bubbleImageView.rightAnchor.constraint(equalTo: textBubbleView.rightAnchor),
      bubbleImageView.bottomAnchor.constraint(equalTo: textBubbleView.bottomAnchor)])
    
//    NSLayoutConstraint.activate([
//        messageTextView.topAnchor.constraint(equalTo: self.topAnchor),
//        messageTextView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
//        messageTextView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
//        messageTextView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
//      ])
    
  }
}
